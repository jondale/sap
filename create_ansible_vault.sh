#!/bin/bash
cd "$(dirname "$0")"

echo -n "Enter vault password: "
read -s VAULT_PASS
echo

echo -n "Confirm vault password: "
read -s VAULT_PASS_CONFIRM
echo

if [ "$VAULT_PASS" != "$VAULT_PASS_CONFIRM" ]; then
    echo "Error: Vault passwords do not match"
    exit 1
fi

echo -n "Enter HANA master password: "
read -s HANA_PASS
echo

echo -n "Confirm HANA master password: "
read -s HANA_PASS_CONFIRM
echo

if [ "$HANA_PASS" != "$HANA_PASS_CONFIRM" ]; then
    echo "Error: HANA passwords do not match"
    exit 1
fi

echo -n "Enter SAP HANA host (IP or hostname): "
read HANA_HOST

echo -n "Enter SAP domain (e.g., sap.example.com): "
read SAP_DOMAIN

mkdir -p ansible/group_vars/all

cat <<EOF | ansible-vault encrypt --vault-password-file=<(echo "$VAULT_PASS") --output=ansible/group_vars/all/vault.yml
vault_hana_master_password: "$HANA_PASS"
vault_ansible_host: "$HANA_HOST"
vault_sap_domain: "$SAP_DOMAIN"
EOF

if [ $? -eq 0 ]; then
    echo "Vault file created at ansible/group_vars/all/vault.yml"
else
    echo "Error creating vault file"
    exit 1
fi
