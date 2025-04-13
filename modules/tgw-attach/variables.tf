variable "vpc" {
  type = string
}

variable "tgw_id" {
  type = string
}

variable "subnet_id" {
    type = set(string)
}

variable "tgw_attach_name" {
  type = string
}