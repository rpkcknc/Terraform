provider "azurerm" {
  features{}
}

data "azurerm_log_analytics_workspace" "loganytics1" {
  name                =  var.loganlyticsname1
  resource_group_name =  var.loganlyticsrgname1
}

resource "azurerm_kubernetes_cluster" "kubernetescluster1" {

 name = var.aksctlname1
 resource_group_name = var.aksrg
 location = var.aksloc
 kubernetes_version = "1.20.5"
 dns_prefix = var.kubdnsprefix1
 addon_profile {
   azure_policy {
    enabled = true
       }
    oms_agent {
      enabled = true
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.loganytics1.id
    }
   }
  default_node_pool {
    name = var.defpoolname1
    availability_zones = [ "1" ]
    node_count = 1
    vm_size = "standard_d4s_v3"
    max_pods = 30
    vnet_subnet_id = var.aksubnetid
          }
   identity {
     type = "SystemAssigned"
   }
  role_based_access_control {
    enabled = true
  }
   
 network_profile {
   network_policy = "calico"
   network_plugin = "azure"
   service_cidr = var.servicecidr1
   dns_service_ip = var.serviceip1
   docker_bridge_cidr = var.dockbridgecidr1
    }
 
}


resource "azurerm_kubernetes_cluster_node_pool" "worknodepool1" {
  name = var.wpnpname1
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kubernetescluster1.id
  availability_zones = ["1","2","3"]
  node_count = 2
  vm_size = "standard_d4s_v3"
  os_type = "Windows"
  max_pods = 40
  vnet_subnet_id = var.aksubnetid
       }
