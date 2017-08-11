variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
  default     = "TF-RG1"
}

variable "hostname" {
  description = "VM name referenced also in storage-related names."
  default     = "TF-VM"
}

variable "lb_name" {
  description = "Load Balancer name"
  default     = "TF-LB"
}

variable "vm_name" {
  description = "VM name"
  default     = "TF-VM"
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "westeurope"
}

variable "vnet_name" {
  description = "The name for the virtual network."
  default     = "TF-VNet1"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.1.0.0/24"
}

variable "storage_account_type" {
  description = "Defines the type of storage account to be created. Valid options are Standard_LRS, Standard_ZRS, Standard_GRS, Standard_RAGRS, Premium_LRS. Changing this is sometimes valid - see the Azure documentation for more information on which types of accounts can be converted into other types."
  default     = "Standard_LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_A0"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "labuser"
}

variable "admin_password" {
  description = "administrator password"
  default     = "M1crosoft123"
}

variable "script_uri" {
  description = "Script URI"
  default     = "https://raw.githubusercontent.com/araffe/vdc-networking-lab/master/DemoAppConfig.sh"
}

variable "script_command" {
  description = "Command to run"
  default     = "sh DemoAppConfig.sh"
}