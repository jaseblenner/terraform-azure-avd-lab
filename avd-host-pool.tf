# Create AVD host pool
resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = "avd-hostpool-${var.lab_name}"
  friendly_name            = "Host Pool - ${var.lab_name}"
  validate_environment     = true
  custom_rdp_properties    = "drivestoredirect:s:*;enablerdsaadauth:i:1;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:*;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:0;"
  description              = "Terraform HostPool - ${var.lab_name}"
  type                     = "Pooled"
  maximum_sessions_allowed = 5
  load_balancer_type       = "DepthFirst" #[BreadthFirst DepthFirst]
  start_vm_on_connect      = true

  public_network_access = "Disabled"
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registrationinfo" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.rfc3339
}
