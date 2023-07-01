variable "location"{
    type = string
    default = "eastus"
}
variable "rgName"{
    type = string
    default = "RG-PrivateNetworking"
}
variable "windowsUserName" {
  type = string
  default = "adminuser"  #Only for test. Move to Keyvalt for security
}
variable "windowsPwd" {
    type = string
    default = "p@ssw0rd!123" #Only for test. Move to Keyvalt for security
}