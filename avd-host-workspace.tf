# Create AVD workspace
resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = "avd-workspace-${var.lab_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = "Workspace - ${var.lab_name}"
  description         = "Workspace - ${var.lab_name}"
}

