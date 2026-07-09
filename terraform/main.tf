# ──────────────────────────────────────────────────────────────────────────────
# main.tf — Ressources Azure à provisionner avec Terraform
# ──────────────────────────────────────────────────────────────────────────────

# ── Tags communs à toutes les ressources ──────────────────────────────────────
locals {
  tags = merge(
    {
      managed_by  = "terraform"
      environment = "tp"
      owner       = var.owner
    },
    var.tags
  )
}

# ── Data sources ──────────────────────────────────────────────────────────────
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_service_plan" "shared" {
  name                = var.shared_plan_name
  resource_group_name = var.shared_rg_name
}

# ── Storage (Étape 2) ─────────────────────────────────────────────────────────
module "storage" {
  source = "./modules/storage"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}

# ── App Service (Étape 3) ─────────────────────────────────────────────────────
module "app_service" {
  source = "./modules/app-service"
 
  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = local.tags
  location            = data.azurerm_resource_group.rg.location
}

# ── Function App (Étape 3) ────────────────────────────────────────────────────
module "function_app" {
  source = "./modules/function-app"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  service_plan_id     = data.azurerm_service_plan.shared.id
  tags                = local.tags
}

# ── Container Instance (Étape 3) ──────────────────────────────────────────────
# CORRECTION ICI : Les ??? ont été remplacés par les bonnes variables de contexte
module "container" {
  source = "./modules/container"

  owner               = var.owner
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  tags                = local.tags
}

# ── Network (Étape 7) ─────────────────────────────────────────────────────────
# On le laisse commenté pour l'instant comme demandé
# module "network" {
#   source = "./modules/network"
#
#   owner               = ???
#   resource_group_name = ???
#   location            = ???
#   tags                = ???
# }