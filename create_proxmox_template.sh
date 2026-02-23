#!/bin/bash
#
# Create a VM template in Proxmox from a cloud image
# Run this script on your Proxmox host
#

set -e

# Defaults
DEFAULT_TEMPLATE_ID=9000
DEFAULT_STORAGE="local-lvm"
DEFAULT_BRIDGE="vmbr0"

TEMPLATE_NAME="rhel9-sap-template"
# RHEL image must be downloaded manually from Red Hat Customer Portal
# or built with Image Builder (requires subscription)
IMAGE_FILE="rhel-9-x86_64-20260222-1855.qcow2"

# Prompt for configuration
echo "Creating RHEL 9 for SAP template..."
echo ""

read -p "Template ID [$DEFAULT_TEMPLATE_ID]: " TEMPLATE_ID
TEMPLATE_ID=${TEMPLATE_ID:-$DEFAULT_TEMPLATE_ID}

read -p "Storage [$DEFAULT_STORAGE]: " STORAGE
STORAGE=${STORAGE:-$DEFAULT_STORAGE}

read -p "Network bridge [$DEFAULT_BRIDGE]: " BRIDGE
BRIDGE=${BRIDGE:-$DEFAULT_BRIDGE}

echo ""
echo "Configuration:"
echo "  Template ID: $TEMPLATE_ID"
echo "  Template Name: $TEMPLATE_NAME"
echo "  Storage: $STORAGE"
echo "  Bridge: $BRIDGE"
echo ""

# Check if image exists (must be manually downloaded/built)
if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: RHEL image not found: $IMAGE_FILE"
    echo ""
    echo "Download the RHEL 9 Virtual Guest image from:"
    echo "  https://access.redhat.com/downloads/content/rhel"
    echo ""
    echo "Or build a custom image with RHEL Image Builder."
    exit 1
fi

# Check if template already exists
if qm status "$TEMPLATE_ID" &>/dev/null; then
    echo "Error: VM $TEMPLATE_ID already exists"
    exit 1
fi

# Create VM
echo "Creating VM..."
qm create "$TEMPLATE_ID" \
    --name "$TEMPLATE_NAME" \
    --memory 2048 \
    --cores 2 \
    --net0 "virtio,bridge=$BRIDGE"

# Import disk
echo "Importing disk..."
qm importdisk "$TEMPLATE_ID" "$IMAGE_FILE" "$STORAGE"

# Configure VM
echo "Configuring VM..."
qm set "$TEMPLATE_ID" --scsihw virtio-scsi-pci --scsi0 "$STORAGE:vm-$TEMPLATE_ID-disk-0"
qm set "$TEMPLATE_ID" --boot c --bootdisk scsi0
qm set "$TEMPLATE_ID" --ide2 "$STORAGE:cloudinit"
qm set "$TEMPLATE_ID" --serial0 socket --vga std

# Convert to template
echo "Converting to template..."
qm template "$TEMPLATE_ID"

echo ""
echo "Template created successfully!"
echo "Use template ID $TEMPLATE_ID in your Terraform configuration"
