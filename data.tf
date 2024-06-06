data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}