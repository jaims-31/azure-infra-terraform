resource "azurerm_service_plan" "local_plan_app" {
  name                = "plan-app-fbarry"
  location            = "francecentral"
  resource_group_name = "fbarryRG"
  os_type             = "Linux"
  sku_name            = "B1"
}
terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

#data "azurerm_service_plan" "shared" {
 # name                = split("/", var.service_plan_id)[8]
  #resource_group_name = split("/", var.service_plan_id)[4]
#}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.owner}-tf"
  resource_group_name = var.resource_group_name
  
  location = "francecentral"
  
  service_plan_id = azurerm_service_plan.local_plan_app.id
  https_only          = true

  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      python_version = "3.11"
    }
  }

  tags = var.tags
}