resource "azurerm_user_assigned_identity" "storageumi" {
  name                = "${var.lab_name}-aad-user-mi-storage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault_access_policy" "uai" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey"
  ]
  secret_permissions = [
    "Get"
  ]
}

resource "azurerm_role_assignment" "encstor" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.storageumi.principal_id

}
