provider "azurerm" {
features {}
  }

  data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvaults" {
  name = var.kvaultname
  location = var.kvaultloc
  resource_group_name = var.kvaultrg
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  network_acls {
    bypass = "AzureServices"
    default_action = "Deny"
      }
  enabled_for_deployment = true
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
  soft_delete_retention_days = 90
  soft_delete_enabled = true
  enable_rbac_authorization = true
  purge_protection_enabled = true
  
}

#============================ Private Endpoint and private dns for keyvault ===============


data "azurerm_virtual_network" "pvt-vnet" {
    resource_group_name = var.keyvaultvnetrg1
    name = var.keyvaultvnetname1
}

resource "azurerm_private_dns_zone" "dns-zone" {
  name = var.dnsname1
  resource_group_name = var.dnsrg1
   soa_record {
   email = "azureprivatedns-host.microsoft.com"
   expire_time = 2419200
   refresh_time = 3600
   retry_time =  300
   minimum_ttl = 10
   ttl = 3600
      }
    
  }

  resource "azurerm_private_dns_a_record" "host-a-record1" {
      name = var.arecordkvname1
      zone_name = azurerm_private_dns_zone.dns-zone.name
      resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
      records = [ var.arecordkvip1]
      ttl = 3600    
      }

        
   resource "azurerm_private_dns_zone_virtual_network_link" "pvtdnsvnetlink" {
       name = "pwrop7behzk46"
       resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
       private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
       virtual_network_id = data.azurerm_virtual_network.pvt-vnet.id
       
        }



resource "azurerm_private_endpoint" "pvtend" {
    name = var.prkvendname1
    resource_group_name = var.prkvendrg
    location = var.prkvendloc
    subnet_id = var.prendkvsubid

    private_service_connection {
      name = var.pvt-svckv
      private_connection_resource_id = azurerm_key_vault.keyvaults.id
      is_manual_connection = false
      subresource_names = ["vault"]
          }

    private_dns_zone_group {
      name = var.dnsgroupkv
      private_dns_zone_ids = [azurerm_private_dns_zone.dns-zone.id]
          }
    
}
