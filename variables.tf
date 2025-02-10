variable "subscription_id" {
  description = "The subscription id to deploy the Azure Automation"
  default     = "YOUR_SUBSCRIPTION_ID"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  default     = "RG-UDR-LIMIT-CHECKER"
  type        = string
}

variable "location" {
  description = "The Azure region"
  default     = "eastus"
  type        = string
}

variable "storage_account_name" {
  description = "The name of the storage account"
  default     = "udrlimitchecker01"
  type        = string
}

variable "container_name" {
  description = "The name of the storage container"
  default     = "udr-limit-checker"
  type        = string
}

variable "automation_account_name" {
  description = "The name of the automation account"
  default     = "UDR-Limit-Checker"
  type        = string
}

variable "subscription_ids" {
  description = "List of Azure Subscription IDs where the automation account needs Network Contributor role"
  type        = list(string)
  default     = []
}
