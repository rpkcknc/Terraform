provider "azurerm" {
    features {
        }
  }

resource "azurerm_public_ip" "pubip" {
  name                = var.publicipname
  resource_group_name = var.rgname
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
  
}

resource "azurerm_application_gateway" "apgw" {
  name                = var.appgwname
  resource_group_name = var.rgname
  location            = var.location
  zones               = ["1","2","3"] 
  enable_http2 = false
    autoscale_configuration { 
    min_capacity     =  0
    max_capacity =  5
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
      }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = var.gateway_ip_config
  }

  frontend_port {
    name = "port_80"
    port = 80
  }

  frontend_ip_configuration {
    name  = "appGwPublicFrontendIp"
    public_ip_address_id = azurerm_public_ip.pubip.id
  }

  frontend_ip_configuration {
    name  = "appGwPrivateFrontendIp"
    private_ip_address = var.privateaddress
    private_ip_address_allocation = "Static"   
    subnet_id = var.privateipsubnet1 
  }

  backend_address_pool {
    name = var.backpoolname
  }

  backend_http_settings {
    name                  = var.backendhttpname
    cookie_based_affinity = "Enabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
    affinity_cookie_name = "ApplicationGatewayAffinity"
    pick_host_name_from_backend_address = false
  }

  http_listener {
    name                           = var.backendhttplistnername
    frontend_ip_configuration_name = "appGwPublicFrontendIp"
    frontend_port_name             = "port_80"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.requestroutingname
    rule_type                  = "Basic"
    http_listener_name         = var.backendhttplistnername
    backend_address_pool_name  = var.backpoolname
    backend_http_settings_name = var.backendhttpname
  }

   waf_configuration {
  enabled = true
  firewall_mode = "Detection"
  rule_set_type = "OWASP"
  rule_set_version = "3.0"
  request_body_check = true
  max_request_body_size_kb = 128
  file_upload_limit_mb = 100
}

}