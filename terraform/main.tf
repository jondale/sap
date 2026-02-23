resource "proxmox_virtual_environment_vm" "sap_hana" {
  node_name   = var.proxmox_node
  vm_id       = var.vm_id
  name        = var.vm_hostname
  description = "SAP HANA VM"

  clone {
    vm_id = var.vm_template_id
  }

  cpu {
    cores = var.vm_cores
    type  = "host"
  }

  memory {
    dedicated = var.vm_memory
  }

  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = var.vm_disk_size
  }

  network_device {
    bridge      = var.network_bridge
    mac_address = var.vm_mac_address
  }

  initialization {
    datastore_id = var.vm_storage

    ip_config {
      ipv4 {
        address = var.vm_ip_address
        gateway = var.network_gateway
      }
    }

    user_account {
      username = "root"
      keys     = [var.ssh_public_keys]
    }
  }

  started = true
}
