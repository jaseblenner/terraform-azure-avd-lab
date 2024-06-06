data "azuread_user" "aad_user" {
  for_each            = toset(var.avd_users)
  user_principal_name = format("%s", each.key)
}

data "azuread_user" "aad_admin" {
  for_each            = toset(var.avd_admins)
  user_principal_name = format("%s", each.key)
}

# AVDUsers
resource "azuread_group" "avdusers" {
  display_name     = "${var.lab_name}-group-AVDUsers"
  security_enabled = true
}

resource "azuread_group_member" "aad_group_member" {
  for_each         = data.azuread_user.aad_user
  group_object_id  = azuread_group.avdusers.id
  member_object_id = each.value["id"]
}

resource "azurerm_role_assignment" "role" {
  scope                = azurerm_virtual_desktop_application_group.dag.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.avdusers.id
}

# ASG
resource "azurerm_application_security_group" "asg" {
  name                = "${var.lab_name}-appsecgroup-avd"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# AVDAdmins
resource "azuread_group" "avdadmins" {
  display_name     = "${var.lab_name}-group-AVDAdmins"
  security_enabled = true
}

resource "azuread_group_member" "aad_group_member_admins" {
  for_each         = data.azuread_user.aad_admin
  group_object_id  = azuread_group.avdadmins.id
  member_object_id = each.value["id"]
}

resource "azurerm_role_assignment" "vm_useraad" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = azuread_group.avdusers.id
}

