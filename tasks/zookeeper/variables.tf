# Defaults follow naming recommendations from https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging

variable "resource_group_name" {
  type = string
  default = "rg-nifi-001"
}

variable "related_packages_resource_group_name" {
  type = string
  default = ""
}

variable "vnet_name" {
  type = string
  default = "vnet-nifi-001"
}

variable "vnet_address_space" {
  type = list(string)
  default = ["10.0.0.0/20"]
}

variable "subnet_mapping" {
  type = map
  default = {
    nifi = {
      name = "snet-nifi-001-nifi"
      address_prefix = "10.0.0.0/21"
    }
    zookeeper = {
      name = "snet-nifi-001-zk"
      address_prefix = "10.0.8.0/24"
    }
    agw = {
      name = "snet-nifi-001-agw"
      address_prefix = "10.0.9.0/24"
    }
    bastion = {
      name = "AzureBastionSubnet"
      address_prefix = "10.0.10.0/24"
    }
  }
}

variable "agw_public_ip_name" {
  type = string
  default = "pip-nifi-001-agw"
}

variable "agw_name" {
  type = string
  default = "agw-nifi-001"
}

variable "bastion_public_ip_name" {
  type = string
  default = "pip-nifi-001-ab"
}

variable "bastion_name" {
  type = string
  default = "ab-nifi-001"
}

variable "bastion_ip_config_name" {
  type = string
  default = "ab-nifi-001-ipconfig"
}

variable "vmss_scale_set_name" {
  type = string
  default = "vmss-nifi-001"
}

variable "vmss_computer_name_prefix" {
  type = string
  default = ""
}

variable "vmss_network_profile_name" {
  type = string
  default = "vmss-nifi-001-network-profile"
}

variable "vmss_ip_config_name" {
  type = string
  default = "vmss-nifi-001-ipconfig"
}

variable "zookeeper_nic_name_prefix" {
  type = string
  default = "nic-nifi-001-zk"
}

variable "zookeeper_computer_name_prefix" {
  type = string
  default = "vm-nifi-001-zk"
}

variable "zookeeper_ip_config_name" {
  type = string
  default = "vm-nifi-001-zk-ipconfig"
}

variable "shared_packages_storage_account_name" {
  type = string
}

variable "shared_packages_key_vault_id" {
  type = string
}

variable "shared_packages_key_name" {
  type = string
}

variable "admin_username" {
  type = string
  default = ""
}

variable "admin_ssh_key" {
  type = string
  default = ""
}

variable "location" {
  type = string
  default = "Southeast Asia"
}
