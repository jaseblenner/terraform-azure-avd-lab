resource "azurerm_role_definition" "scaling" {
  name        = "avd-autoscaling-role-${var.lab_name}"
  scope       = azurerm_resource_group.rg.id
  description = "avd-autoscaling-${var.lab_name}-role"
  permissions {
    actions = [
      "Microsoft.Insights/eventtypes/values/read",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.DesktopVirtualization/hostpools/read",
      "Microsoft.DesktopVirtualization/hostpools/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/read",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/sendMessage/action",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read"
    ]
    not_actions = []
  }
  assignable_scopes = [
    azurerm_resource_group.rg.id,
  ]
}

#Autoscale is currently only available in the public cloud.
resource "random_uuid" "scaling" {}

data "azurerm_role_definition" "scaling" {
  name = "Desktop Virtualization Power On Off Contributor"
}

data "azuread_service_principal" "spn" {
  # Azure Enterprise Application - Azure Virtual Desktop (Built In)
  client_id = "9cdead84-a844-4324-93f2-b2e6bb768d07"
}

resource "azurerm_role_assignment" "scaling" {
  name                             = random_uuid.scaling.result
  scope                            = data.azurerm_subscription.current.id              #azurerm_resource_group.rg.id
  role_definition_name             = "Desktop Virtualization Power On Off Contributor" #data.azurerm_role_definition.scaling.role_definition_id
  principal_id                     = data.azuread_service_principal.spn.id
  skip_service_principal_aad_check = true
}

resource "azurerm_virtual_desktop_scaling_plan" "scaling" {
  name                = "avd-autoscaling-plan-${var.lab_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  friendly_name       = "avd-autoscaling-plan-${var.lab_name}"
  description         = "avd-autoscaling-plan-${var.lab_name}"
  time_zone           = "AUS Eastern Standard Time"
  schedule {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "07:00"
    ramp_up_load_balancing_algorithm     = "DepthFirst"
    ramp_up_minimum_hosts_percent        = 20
    ramp_up_capacity_threshold_percent   = 10
    peak_start_time                      = "08:00"
    peak_load_balancing_algorithm        = "DepthFirst"
    ramp_down_start_time                 = "19:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Please log off in the next 45 minutes..."
    ramp_down_capacity_threshold_percent = 5
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "20:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }
  host_pool {
    hostpool_id          = azurerm_virtual_desktop_host_pool.hostpool.id
    scaling_plan_enabled = true
  }
}