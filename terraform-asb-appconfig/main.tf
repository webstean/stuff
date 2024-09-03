locals {
  instance-name = "dev"
  ## map
  service-bus-topics-group = {
  }
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Australia East"
}

resource "azurerm_servicebus_namespace" "example" {
  name                = "${instance-name}-servicebus-namespace"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
}

resource "azurerm_app_configuration" "example" {
  name                = "${local.instance-name}-appConf1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
}

data "azurerm_client_config" "current" {}
resource "azurerm_role_assignment" "appconf_dataowner" {
  scope                = azurerm_app_configuration.example.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_servicebus_topic" "example" {
  for_each = service-bus-topics-group

  name         = "${each.value.name}"
  namespace_id = azurerm_servicebus_namespace.example.id
}

resource "azurerm_role_assignment" "example1" {
  scope                = azurerm_app_configuration.example.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "example2" {
  scope                = azurerm_app_configuration.example.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_client_config.current.object_id
}


resource "azurerm_app_configuration_key" "example" {
  for_each = local.

  configuration_store_id = azurerm_app_configuration.test.id
  key                    = "${each.value.name}"
  label                  = "${each.value.name}"
  value                  =  ${each.value.value}"
}

