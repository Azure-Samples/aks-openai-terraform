variable "resource_group_name" {
  description = "(Required) Specifies the resource group name"
  type = string
}

variable "location" {
  description = "(Required) Specifies the location of the Azure OpenAI Service"
  type = string
}

variable "name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the Azure OpenAI Service"
  type        = map(any)
  default     = {}
}

variable "sku_name" {
  description = "(Optional) The SKU which should be used. At this time the only supported value is Standard. Defaults to Standard"
  type = string
  default = "Standard"
}

variable "idle_timeout_in_minutes" {
  description = "(Optional) The idle timeout which should be used in minutes. Defaults to 4."
  type = number
  default = 4
}

variable "zones" {
  description = " (Optional) A list of Availability Zones in which this NAT Gateway should be located. Changing this forces a new NAT Gateway to be created."
  type = list(string)
  default = []
}

variable "subnet_ids" {
  description = "(Required) A map of subnet ids to associate with the NAT Gateway"
  type = map(string)
}