terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.65.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      recover_soft_deleted_key_vaults = true
      purge_soft_delete_on_destroy    = true
    }
  }
}

locals {
  resource_prefix             = "ex2"
  resource_group_name         = "azurerm-iot-example-test2"
  resource_group_location     = "westeurope"
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.resource_group_location
}

resource "azurerm_iothub" "example" {
  name                          = "${local.resource_prefix}-iot-hub"
  resource_group_name           = local.resource_group_name
  location                      = local.resource_group_location
  public_network_access_enabled = true

  sku {
    name     = "S1"
    capacity = "1"
  }
}

# Routes IoT Hub message to blob container for storage backup.
resource "azurerm_storage_account" "example" {
  name                     = "${local.resource_prefix}logsstorage"
  resource_group_name      = local.resource_group_name
  location                 = local.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = "iot-hub-messages"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}

resource "azurerm_iothub_endpoint_storage_container" "example" {
  resource_group_name = local.resource_group_name
  iothub_name         = azurerm_iothub.example.name
  name                = "${local.resource_prefix}-logs-storage-endpoint"

  connection_string          = azurerm_storage_account.example.primary_blob_connection_string
  batch_frequency_in_seconds = 60
  max_chunk_size_in_bytes    = 10485760
  container_name             = azurerm_storage_container.example.name
  encoding                   = "JSON"
  file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
}

resource "azurerm_iothub_route" "example" {
  resource_group_name = local.resource_group_name
  iothub_name         = azurerm_iothub.example.name
  name                = "${local.resource_prefix}-logs-storage-route"
  source              = "DeviceMessages"
  condition           = "true"
  endpoint_names      = [azurerm_iothub_endpoint_storage_container.example.name]
  enabled             = true
}

resource "azurerm_iothub_route" "example1" {
  resource_group_name = local.resource_group_name
  iothub_name         = azurerm_iothub.example.name
  name           = "defaultroute"
  source         = "DeviceMessages"
  condition      = "true"
  endpoint_names = ["events"]
  enabled        = true
}