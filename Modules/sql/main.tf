provider "azurerm" {
  features{}
}

resource "azurerm_sql_server" "sqlserver1" {
  name                         = var.sqlname1
  resource_group_name          = var.sqlrg1
  location                     = var.sqlloc
  version                      = "12.0"
  administrator_login          = "sqldevadmin"
  administrator_login_password = "Geeth@1681"
   }

  resource "azurerm_sql_database" "sqldb1" {
   name = var.sqldbname1
   location = var.sqlloc
   resource_group_name = azurerm_sql_server.sqlserver1.resource_group_name
   server_name = azurerm_sql_server.sqlserver1.name
     depends_on = [
     azurerm_sql_server.sqlserver1
   ]
   
 }


#=================== Private DNS and private endpoint sql===============

data "azurerm_virtual_network" "pvt-vnet" {
    resource_group_name = var.sqlvnetrg1
    name = var.sqlvnetname1
}

resource "azurerm_private_dns_zone" "dns-zone" {
  name = var.dnsname2
  resource_group_name = var.dnsrg2
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
      name = var.arecordsqlname1
      zone_name = azurerm_private_dns_zone.dns-zone.name
      resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
      records = [ var.arecordsqlip1]
      ttl = 3600    
      }

  resource "azurerm_private_dns_a_record" "host-a-record2" {
      name = var.arecordsqlname2
      zone_name  = azurerm_private_dns_zone.dns-zone.name
      resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
      records = [var.arecordsqlip2]
      ttl = 3600    
      }
        
   resource "azurerm_private_dns_zone_virtual_network_link" "pvtdnsvnetlink" {
       name = "pwrop7behzk46"
       resource_group_name = azurerm_private_dns_zone.dns-zone.resource_group_name
       private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
       virtual_network_id = data.azurerm_virtual_network.pvt-vnet.id
       
        }

 
 
resource "azurerm_private_endpoint" "pvtend" {
    name = var.prsqlendname1
    resource_group_name = var.prsqlendrg
    location = var.prsqlendloc
    subnet_id = var.prendsqlsubid

    private_service_connection {
      name = var.pvt-svcsql
      private_connection_resource_id = azurerm_sql_server.sqlserver1.id
      is_manual_connection = false
      subresource_names = ["sqlServer"]
          }

    private_dns_zone_group {
      name = var.dnsgroupsql
      private_dns_zone_ids = [azurerm_private_dns_zone.dns-zone.id]
          }
    
}
