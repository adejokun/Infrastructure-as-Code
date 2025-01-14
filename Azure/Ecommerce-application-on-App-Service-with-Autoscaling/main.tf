
#############################################################################
# RESOURCES
#############################################################################

resource "azurerm_resource_group" "webapp" {
  name     = "rg-webapp-test"
  location = "West Europe"
}

resource "azurerm_service_plan" "webapp" {
  name                = "App-plan-webapp"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_resource_group.webapp.location
  sku_name            = "B1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "webapp" {
  name                = "web-app-test-molo-03"
  resource_group_name = azurerm_resource_group.webapp.name
  location            = azurerm_service_plan.webapp.location
  service_plan_id     = azurerm_service_plan.webapp.id

  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    minimum_tls_version = "1.2"
    always_on = false
    ftps_state = "FtpsOnly"
  }
}

resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_windows_web_app.webapp.id
  repo_url           = "https://github.com/SoniaConti/ContosoFinance-Demo-Web.git"
  branch             = "master"
  use_manual_integration = true
  use_mercurial      = false
}