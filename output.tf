
output "resource_group_name" {
  description = "Azure resource group created for the assignment"
  value       = azurerm_resource_group.sakshi.name
}

output "windows_vm_name" {
  description = "Name of the Windows virtual machine"
  value       = azurerm_windows_virtual_machine.sakshi.name
}

output "public_ip_address" {
  description = "Public IP address of the Windows VM"
  value       = azurerm_public_ip.sakshi.ip_address
}

output "website_url" {
  description = "URL to test the IIS website"
  value       = "http://${azurerm_public_ip.sakshi.ip_address}"
}

