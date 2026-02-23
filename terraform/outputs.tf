output "vm_id" {
  description = "The ID of the created VM"
  value       = var.vm_id
}

output "vm_ip" {
  description = "The IP address of the VM"
  value       = "10.100.100.${var.vm_id}"
}

output "vm_hostname" {
  description = "The hostname of the VM"
  value       = var.vm_hostname
}
