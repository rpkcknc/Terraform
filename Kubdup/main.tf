terraform{
  backend "azurerm"{

  }
}

provider "azurerm" {
  features{}  
}

data "azurerm_virtual_network" "dev-vnet" {
    resource_group_name = var.rgsubnets
    name = "vnet-dc-lz-dev-useast2-001"
}

data "azurerm_subnet" "devsubnet5" {
    resource_group_name = var.rgsubnets
    virtual_network_name = data.azurerm_virtual_network.dev-vnet.name
    name = "snet-dc-lz-dev-useast2-0005"
   
}

# ============= Kubernetes Cluster ====================================


   module "aksclusters" {
  source = "../Modules/kubernetesservice"
  aksctlname1 = "aks-nami-api-dev-002"
  aksrg = "rg-dc-lz-dev-001"
  aksloc = "eastus2"
  defpoolname1 = "sysdev001"
  kubdnsprefix1 = "aks-nami-api-dev-002-dns"
  aksubnetid  = data.azurerm_subnet.devsubnet5.id
  servicecidr1 = "20.203.32.0/20"
  serviceip1  = "20.203.47.254"
  dockbridgecidr1 = "20.203.48.1/20"
  wpnpname1 = "unw003"
     
}


  






