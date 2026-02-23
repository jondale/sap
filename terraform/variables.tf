variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox username for API access"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox password for API access"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "vm_id" {
  description = "VM ID (also used as last octet of IP address)"
  type        = number
}

variable "vm_hostname" {
  description = "VM hostname"
  type        = string
}

variable "vm_template_id" {
  description = "Template VM ID to clone from"
  type        = number
}

variable "vm_disk_size" {
  description = "Root disk size in GB"
  type        = number
  default     = 120
}

variable "vm_memory" {
  description = "Memory in MB"
  type        = number
  default     = 32768
}

variable "vm_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 4
}

variable "vm_storage" {
  description = "Storage for VM disk"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge name"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway IP"
  type        = string
}

variable "vm_ip_address" {
  description = "Static IP address for the VM (CIDR notation, e.g. 10.100.100.225/24)"
  type        = string
}

variable "vm_mac_address" {
  description = "MAC address for the VM network interface"
  type        = string
}

variable "ssh_public_keys" {
  description = "SSH public keys to add to the VM"
  type        = string
}
