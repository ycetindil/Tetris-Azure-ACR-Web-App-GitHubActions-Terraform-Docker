terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.20.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "ycetindil"
    storage_account_name = "ycetindil"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "github" {}

######################
### RESOURCE GROUP ###
######################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

###########
### ACR ###
###########
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

########################
### APP SERVICE PLAN ###
########################
resource "azurerm_service_plan" "asp" {
  name                = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

###############
### WEB APP ###
###############
resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {}
}

########################
### GITHUB VARIABLES ###
########################
resource "github_actions_secret" "acr_password" {
  repository       = var.github_repo_name
  secret_name      = "ACR_PASSWORD"
  plaintext_value  = azurerm_container_registry.acr.admin_password
}

resource "github_actions_variable" "acr_name" {
  repository       = var.github_repo_name
  variable_name    = "ACR_NAME"
  value            = var.acr_name
}

resource "github_actions_variable" "rg_name" {
  repository       = var.github_repo_name
  variable_name    = "RG_NAME"
  value            = azurerm_resource_group.rg.name
}

resource "github_actions_variable" "web_app_name" {
  repository       = var.github_repo_name
  variable_name    = "WEB_APP_NAME"
  value            = azurerm_linux_web_app.app.name
}