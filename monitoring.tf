# Creates Log Anaylytics Workspace
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.lab_name}-log-analytics-workspace"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Creates Azure Virtual Desktop Insights Log Analytics Workspace
module "avdi" {
  source      = "./modules/insights"
  avdLocation = var.resource_group_location
  prefix      = var.lab_name
  law_name    = azurerm_log_analytics_workspace.law.name
  rg_name     = azurerm_resource_group.rg.name
}

# Create Diagnostic Settings for AVD Host Pool
resource "azurerm_monitor_diagnostic_setting" "avd-hp1" {
  name                       = "${var.lab_name}-diags-avdhostpool"
  target_resource_id         = azurerm_virtual_desktop_host_pool.hostpool.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  depends_on = [
    azurerm_log_analytics_workspace.law,
    azurerm_virtual_desktop_host_pool.hostpool
  ]

  dynamic "enabled_log" {
    for_each = var.host_pool_log_categories
    content {
      category = enabled_log.value
    }
  }
  lifecycle {
    ignore_changes = [log]
  }
}

# Create Diagnostic Settings for AVD Workspace
resource "azurerm_monitor_diagnostic_setting" "avd-ws" {
  name                       = "${var.lab_name}-diags-avdws"
  target_resource_id         = azurerm_virtual_desktop_host_pool.hostpool.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  depends_on = [
    azurerm_log_analytics_workspace.law,
    azurerm_virtual_desktop_workspace.workspace
  ]

  dynamic "enabled_log" {
    for_each = var.ws_log_categories
    content {
      category = enabled_log.value
    }
  }
}

# Create Diagnostic Settings for AVD Desktop App Group
resource "azurerm_monitor_diagnostic_setting" "avd-dag" {
  name                       = "${var.lab_name}-diags-avddag"
  target_resource_id         = azurerm_virtual_desktop_host_pool.hostpool.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  depends_on = [
    azurerm_log_analytics_workspace.law,
    azurerm_virtual_desktop_application_group.dag
  ]

  dynamic "enabled_log" {
    for_each = var.dag_log_categories
    content {
      category = enabled_log.value
    }
  }
}

# VM
resource "azurerm_monitor_data_collection_rule" "rule1" {
  name                = "${var.lab_name}-dcr-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_virtual_machine_extension.ama]

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "log-analytics"
    }
  }

  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["log-analytics"]
  }

  data_sources {
    windows_event_log {
      streams = ["Microsoft-Event"]
      x_path_queries = ["Application!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]",
        "Security!*[System[(band(Keywords,13510798882111488))]]",
      "System!*[System[(Level=1 or Level=2 or Level=3 or Level=4 or Level=0 or Level=5)]]"]
      name = "eventLogsDataSource"
    }
  }
}

# data collection rule association

resource "azurerm_monitor_data_collection_rule_association" "dcra1" {
  count                   = var.rdsh_count
  name                    = "dcra${count.index + 1}"
  target_resource_id      = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  data_collection_rule_id = azurerm_monitor_data_collection_rule.rule1.id
}