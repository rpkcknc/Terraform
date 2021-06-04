provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "myrg" {
name = "rg1"
location = "east us"
}