module "azure-bastion" {
  source  = "kumarvna/azure-bastion/azurerm"
  version = "1.2.0"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  # Azure bastion server requireemnts
  azure_bastion_service_name          = "${var.lab_name}-bastion"
  azure_bastion_subnet_address_prefix = ["10.0.2.0/26"]
  bastion_host_sku                    = "Basic"
  #scale_units                         = 10

}