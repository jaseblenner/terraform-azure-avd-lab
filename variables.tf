variable "resource_group_location" {
  type        = string
  default     = "australiaeast"
  description = "Location for all resources."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "lab_name" {
  type        = string
  description = "The name of the new lab instance to be created"
  default     = "avdlab"
}

variable "rfc3339" {
  type        = string
  default     = "2024-05-30T12:43:13Z"
  description = "Registration token expiration"
}

variable "rdsh_count" {
  description = "Number of AVD machines to deploy"
  default     = 1
}

variable "vm_size" {
  description = "Size of the machine to deploy"
  default     = "Standard_DS1_v2"
}

variable "local_admin_username" {
  type        = string
  default     = "localadm"
  description = "local admin username"
}

variable "local_admin_password" {
  type        = string
  default     = "ChangeMe123!"
  description = "local admin password"
  sensitive   = true
}

variable "avd_users" {
  description = "AVD users" # Add the required user UPNs here
  default = [
  ]
}

variable "avd_admins" {
  description = "AVD Admins" # Add the required user UPNs here
  default = [
  ]
}

variable "host_pool_log_categories" {
  default     = ["Checkpoint", "Management", "Connection", "HostRegistration", "AgentHealthStatus", "NetworkData", "SessionHostManagement", "ConnectionGraphicsData", "Error"]
  description = "value of the log categories to be enabled for the host pool"
}

variable "dag_log_categories" {
  default     = ["Checkpoint", "Management", "Error"]
  description = "value of the log categories to be enabled for the desktop app group"
}

variable "ws_log_categories" {
  default     = ["Checkpoint", "Management", "Error"]
  description = "value of the log categories to be enabled for the workspace"
}