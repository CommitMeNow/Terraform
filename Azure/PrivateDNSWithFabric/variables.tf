variable "location"{
    type = string
    default = "westus"
}
variable "rgName"{
    type = string
    default = "RG-PrivateNetworkingWithFabric"
}
variable "sku" {
  type        = string
  description = "F SKU"
  default     = "F2"
}

variable "admin_email" {
  type        = string
  default = "putadomainemailaddresshere"
}

variable "myF2capacityname" {
  type        = string
  default = "fabf2capacity"
}

