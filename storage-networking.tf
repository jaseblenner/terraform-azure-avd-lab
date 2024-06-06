/*
resource "azurerm_private_endpoint" "filesprivendpoint" {
  name                = "${var.lab_name}-privendpoint-file"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet00.id

  private_service_connection {
    name                           = "${var.lab_name}-privsvcconnection-file"
    private_connection_resource_id = azurerm_storage_account.storage.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }
  private_dns_zone_group {
    name                 = "${var.lab_name}-dns-file"
    private_dns_zone_ids = [azurerm_private_dns_zone.filesdns.id]
  }
}

resource "azurerm_private_dns_zone" "filesdns" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "filesdnslink" {
  name                  = "${var.lab_name}-vnet-link-${azurerm_private_dns_zone.filesdns.name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.filesdns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
*/