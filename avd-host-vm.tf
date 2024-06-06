# VM
resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "vm-nic-${var.lab_name}-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}-config"
    subnet_id                     = azurerm_subnet.subnet00.id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count
  name                  = "vm-${var.lab_name}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  license_type          = "Windows_Client"
  vtpm_enabled          = true
  secure_boot_enabled   = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  os_disk {
    name                 = "vm-${lower(var.lab_name)}-vm-${count.index + 1}-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "office-365"
    sku       = "win10-22h2-avd-m365-g2"
    version   = "latest"
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_network_interface.avd_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "azureadjoin" {
  count                      = var.rdsh_count
  name                       = "${var.lab_name}-${count.index + 1}-avd_domjoin"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
}

resource "azurerm_virtual_machine_extension" "guestattestation" {
  count                      = var.rdsh_count
  name                       = "${var.lab_name}-${count.index + 1}-guest_attest"
  publisher                  = "Microsoft.Azure.Security.WindowsAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = false
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]

  depends_on = [
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_virtual_machine_extension.azureadjoin
  ]
}


resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.lab_name}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02698.323.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}",
        "aadJoin": true
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token}"
    }
  }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

  depends_on = [
    azurerm_virtual_desktop_host_pool.hostpool,
    azurerm_virtual_machine_extension.azureadjoin,
    azurerm_virtual_machine_extension.guestattestation
  ]
}

resource "azurerm_virtual_machine_extension" "ama" {
  count                      = var.rdsh_count
  name                       = "${var.lab_name}${count.index + 1}-avd_azuremonitor"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = "true"

  depends_on = [
    azurerm_virtual_machine_extension.azureadjoin,
    azurerm_virtual_machine_extension.vmext_dsc,
    azurerm_log_analytics_workspace.law
  ]
}
