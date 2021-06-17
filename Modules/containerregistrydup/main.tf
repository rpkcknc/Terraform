provider "azurerm" {
  features {}
}

data "azurerm_container_registry" "container-registry1" {
name = var.contname
resource_group_name = var.contrg
  
  }


#=================== Private DNS and private endpoint acr===============

data "azurerm_virtual_network" "pvt-vnet" {
    resource_group_name = var.contvnetrg1
    name = var.contvnetname1
}

resource "azurerm_private_dns_zone" "dns-zone" {
  name = var.dnsname
  resource_group_name = var.dnsrg
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
      name = var.arecord1
      zone_name = azurerm_private_dns_zone.dns-zone.name
      resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
      records = [ var.arecordip1]
      ttl = 3600    
      }

  resource "azurerm_private_dns_a_record" "host-a-record2" {
      name = var.arecord2
      zone_name  = azurerm_private_dns_zone.dns-zone.name
      resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
      records = [var.arecordip2]
      ttl = 3600    
      }
        
   resource "azurerm_private_dns_zone_virtual_network_link" "pvtdnsvnetlink" {
       name = "pwrop7behzk46"
       resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
       private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
       virtual_network_id = data.azurerm_virtual_network.pvt-vnet.id
       
        }



resource "azurerm_private_endpoint" "pvtend" {
    name = var.prendname
    resource_group_name = var.prendrg
    location = var.prendloc
    subnet_id = var.prendsubid

    private_service_connection {
      name = var.pvt-svc
      private_connection_resource_id = data.azurerm_container_registry.container-registry1.id
      is_manual_connection = false
      subresource_names = ["registry"]
          }

    private_dns_zone_group {
      name = var.dnsgroup
      private_dns_zone_ids = [azurerm_private_dns_zone.dns-zone.id]
          }
    
}
