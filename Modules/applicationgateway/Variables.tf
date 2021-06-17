variable "appgwname" {
    type = string
    description = "applicationgatewayname"
}

variable "rgname" {
    type = string
    description = "resource group name"
}

variable "location" {
    type = string
    description = "location for resource group"
}

variable "zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = null
}

variable "gateway_ip_config" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
}

variable "publicipname" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
}

variable "privateaddress" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
}

variable "backpoolname" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
}
variable "backendhttpname" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
}
variable "backendhttplistnername" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
}

variable "requestroutingname" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
  }

variable "privateipsubnet1" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = string
  default     = null
  
}

                                        


