resource "azurerm_virtual_network" "vnet" {
  name                = "${var.lab_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet00" {
  name                 = "${var.lab_name}-subnet-00"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  service_endpoints    = ["Microsoft.AzureActiveDirectory", "Microsoft.KeyVault", "Microsoft.Storage"]
  address_prefixes     = ["10.0.1.0/24"]
}
