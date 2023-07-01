variable "resourceGroupName" {
    description = "Resource group name for the project"
    type = string
    default = "RG-BasicHubAndSpoke"  
}
variable "deploymentLocation" {
    description = "Deployment location for the project"
    type = string
    default = "eastus"

}
#Only hard coded here for TEST. Move to keyvault or runtime variable
variable "windowsUsername"{
    type = string
    default = "adminuser"
}
#Only hard coded here for TEST. Move to keyvault or runtime variable

variable "userPWD"{
    type = string
    default = "P@$$w0rd1234!" #TEST ONLY:  ideally ask at runtime or pull from keyvault
}

