terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create an Azure Storage Account with anonymous access disabled
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Storage Container
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

# Upload config.json to the storage container
resource "azurerm_storage_blob" "config_blob" {
  name                   = "config.json"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  source                 = "${path.module}/source/config.json"
  depends_on             = [azurerm_storage_container.container]
}


# Create an Automation Account with System-Assigned Identity
resource "azurerm_automation_account" "automation" {
  name                = var.automation_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

# Assign Role: Network Contributor at Subscription Level
resource "azurerm_role_assignment" "network_contributor" {
  for_each             = local.subscription_ids
  scope                = "/subscriptions/${each.value}"
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_automation_account.automation.identity.0.principal_id
  depends_on           = [azurerm_automation_account.automation]
}

# Assign Role: Storage Blob Data Contributor to Automation Account
resource "azurerm_role_assignment" "storage_blob_data" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_automation_account.automation.identity.0.principal_id
  depends_on           = [azurerm_automation_account.automation]
}

# Assign Role: Automation Contributor to Automation Account
resource "azurerm_role_assignment" "automation_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Automation Contributor"
  principal_id         = azurerm_automation_account.automation.identity.0.principal_id
  depends_on           = [azurerm_automation_account.automation]
}

# Import Python Packages into Automation Account
resource "azurerm_automation_python3_package" "python_packages" {
  for_each                = local.python_packages
  name                    = each.key
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation.name
  content_uri             = each.value
  depends_on              = [azurerm_automation_account.automation]
}

# Store Storage Account Name in Automation Variables
resource "azurerm_automation_variable_string" "storage_account" {
  name                    = "AZURE_STORAGE_ACCOUNT"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation.name
  value                   = azurerm_storage_account.storage.name
  encrypted               = true
}

# Store Storage Container Name in Automation Variables
resource "azurerm_automation_variable_string" "container_name" {
  name                    = "AZURE_CONTAINER_NAME"
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation.name
  value                   = azurerm_storage_container.container.name
  encrypted               = true
}

# Create an Automation Runbook
resource "azurerm_automation_runbook" "runbook" {
  name                    = "UDR-Limit-Checker"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.automation.name
  log_verbose             = true
  log_progress            = true
  runbook_type            = "Python3"
  content                 = file("${path.module}/source/script.py")
}