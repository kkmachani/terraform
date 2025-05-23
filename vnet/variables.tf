variable "resource_group" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "vnet_tag" {
  type = string
}

# Dev Subnet
variable "subnet_names" {
    type = list(string)
}

variable "address_prefixes" {
    type = list(string)
}



