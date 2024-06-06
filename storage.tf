
## Azure Storage Accounts requires a globally unique names
## https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
## Create a File Storage Account 
resource "azurerm_storage_account" "storage" {
  name                      = "${var.lab_name}stor${random_string.randomstring.id}"
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.storageumi.id
    ]
  }

  azure_files_authentication {
    directory_type = "AADKERB"
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Metrics", "Logging"]
    ip_rules                   = ["${chomp(data.http.myip.response_body)}"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet00.id]
  }

  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

resource "azurerm_storage_share" "FSShare" {
  name                 = "fslogix"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 100 # Premium Storage account quota must be between 100-102400
  depends_on           = [azurerm_storage_account.storage]
}

resource "azurerm_role_assignment" "af_role" {
  scope                = azurerm_storage_account.storage.id
  role_definition_name = "Storage File Data SMB Share Contributor"
  principal_id         = azuread_group.avdusers.id
}