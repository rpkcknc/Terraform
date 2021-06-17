terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.40.0"
    }
  }
}

provider "azurerm" {
  features{}
  
}


# ============= Subnets =====================
data "azurerm_virtual_network" "preprod-vnet" {
    resource_group_name = var.rgsubnets
    name = "vnet-dc-lz-medium-useast2-001"
}

data "azurerm_subnet" "preprod-subnet1" {
    resource_group_name = var.rgsubnets
    virtual_network_name = data.azurerm_virtual_network.preprod-vnet.name
    name = "snet-dc-lz-medium-useast2-001"
    
  
}

data "azurerm_route_table" "preprod-routetable" {
  resource_group_name = var.rgsubnets
  name = "route-dc-lz-medium-001"
    }


data "azurerm_subnet" "preprodsubnet2" {
  name = var.subnet2name  
  resource_group_name = var.rgsubnets
  virtual_network_name = data.azurerm_virtual_network.preprod-vnet.id
  }

data "azurerm_subnet" "preprodsubnet3" {
  name = var.subnet3name  
  resource_group_name = var.rgsubnets
  virtual_network_name = data.azurerm_virtual_network.preprod-vnet.id
}

data "azurerm_subnet" "preprodsubnet4" {
  name = var.subnet4name  
  resource_group_name = var.rgsubnets
  virtual_network_name = data.azurerm_virtual_network.preprod-vnet.id
}

data "azurerm_subnet" "preprodsubnet5" {
  name = var.subnet5name  
  resource_group_name = var.rgsubnets
  virtual_network_name = data.azurerm_virtual_network.preprod-vnet.id
}

data "azurerm_subnet" "preprodsubnet6" {
  name = var.subnet6name  
  resource_group_name = var.rgsubnets
  virtual_network_name = data.azurerm_virtual_network.preprod-vnet.id
}

data "azurerm_subnet" "preprodsubnet7" {
  name = var.subnet7name  
  resource_group_name = var.rgsubnets
  virtual_network_name = data.azurerm_virtual_network.preprod-vnet.id
    }

# ============= Application Gateway =============

module "bmic-preprod-agw" {
    source = "../Modules/applicationgateway"
    appgwname = "agw-nami-api-medium-001"
    rgname    = "rg-agw-medium-001"
    location  =  "eastus2"
    zones     = ["1","2","3"]
    gateway_ip_config = data.azurerm_subnet.preprod-subnet1.id
    publicipname = "pip-agw-nami-api-medium-001"
    privateaddress= "10.203.0.4"
    backendhttplistnername = "http-lis-pub-agw-nami-api-preprod-001"
    backpoolname = "bp-agw-nami-api-preprod-001"
    backendhttpname = "http-bes-agw-nami-api-preprod-001"   
    requestroutingname = "http-rule-agw-nami-api-preprod-001"
          
   }
   
   

   # ============= Container registry and PrivateEndpoint for ACR =================

   module "bmic-preprod-cont" {
    source   = "../Modules/containerregistry"
    contname = "acrnamiapimedium001"
    contrg   = "rg-shd-medium-001"
    contloc  = "eastus2"
    dnsname  = "privatelink.azurecr.io"
    dnsrg    =    "rg-dc-lz-medium-001"
    arecord1 = "acrnamiapimedium001"
    arecord2 = "acrnamiapimedium001.eastus2.data"
    arecordip1 = "10.203.0.37"
    arecordip2 = "10.203.0.36"
    prendname = "pe-acr-nami-api-medium-001"
    prendrg = "rg-shd-medium-001"
    prendloc = "eastus2"
    prendsubid = azurerm_subnet.preprodsubnet2.id
    pvt-svc = "acrconnection"
    dnsgroup ="acrdnsgroup"

     }


   # ============= Key Vault =================

   module "bmic-preprod-kv" {
     source = "../Modules/keyvault"
     kvaultname = "akv-nami-api-medium-001"
     kvaultloc  = "eastus2"
     kvaultrg   = azurerm_resource_group.bmic-preprod-shrg.name
    dnsname1  = "privatelink.vaultcore.azure.net"
    dnsrg1    =    "rg-dc-lz-medium-001"
    arecordkvname1 = "akv-nami-api-medium-001"
    arecordkvip1= "10.203.0.38"
    prkvendname1 = "pe-akv-nami-api-medium-001"
    prkvendrg = "rg-shd-medium-001"
    prkvendloc = "eastus2"
    prendkvsubid = azurerm_subnet.preprodsubnet2.id
    pvt-svckv = "keyconnection"
    dnsgroupkv ="keydnsgroup"

     
   }

   # ============= SQL server, SQL DB and PrivateEndpoint for SQL =================

   module "bmic-preprod-sql" {
    source   = "../Modules/sql"
    sqlname1 = "sqldb-nami-api-preprod-001"
    sqlrg1   = "rg-aks-preprod-001"
    sqlloc  = "eastus2"
    dnsname2 = "privatelink.database.windows.net"
    dnsrg2 =    "rg-dc-lz-medium-001"
    arecordsqlname1 = "akv-nami-api-medium-001"
    arecordsqlname2 = "sql-nami-api-qa-001.privatelink.database.windows.net"
    arecordsqlip1= "10.203.0.132"
    arecordsqlip2 = "10.203.128.4"
    prsqlendname1 = "pe-sqldb-nami-api-preprod-001"
    prsqlendrg = "rg-aks-preprod-001"
    prsqlendloc = "eastus2"
    prendsqlsubid = azurerm_subnet.preprodsubnet4.id
    pvt-svcsql = "sqlconnection"
    dnsgroupsql ="sqldnsgroup"

         }

# ============= Kubernetes Cluster ====================================

module "aksclusters" {
  source = "../Modules/kubernetesservice"
  aksctlname1 = "aks-nami-api-preprod-001"
  aksrg = azurerm_resource_group.bmic-preprod-aksrg.name
  aksloc = "eastus2"
  defpoolname1 = "syspreprod001"
  aksubnetid  = azurerm_subnet.preprodsubnet5.id
  servicecidr1 = "10.203.32.0/20"
  serviceip1  = "10.203.47.254"
  dockbridgecidr1 = "10.203.48.1/20"
  wpnpname1  = "unw001"
   
}
   


  






