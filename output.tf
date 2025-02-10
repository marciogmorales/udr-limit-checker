output "resource_group_name" {
  description = "The name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "The name of the Azure Storage Account"
  value       = azurerm_storage_account.storage.name
}

output "storage_container_name" {
  description = "The name of the Azure Storage Container"
  value       = azurerm_storage_container.container.name
}

output "automation_account_name" {
  description = "The name of the Azure Automation Account"
  value       = azurerm_automation_account.automation.name
}