resource "azurerm_key_vault" "kv" {
  name                        = "${var.lab_name}-kv"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku_name                    = "standard"
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
  enabled_for_deployment      = true
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 7

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_virtual_desktop_workspace.workspace,
    azurerm_virtual_desktop_application_group.dag
  ]


  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["${chomp(data.http.myip.response_body)}/32"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet00.id]
  }

}

resource "azurerm_role_assignment" "kv_useraad" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_group.avdadmins.id
}

# Create Key Vault Secret
resource "azurerm_key_vault_secret" "localpassword" {
  name         = "vmlocalpassword"
  value        = var.local_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "Password"

  lifecycle { ignore_changes = [tags] }

}