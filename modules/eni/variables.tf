variable "public_subnet_id" {
  type = string
}

variable "public_security_groups" {
  type = list(string)
}

variable "public_device_index" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "private_security_groups" {
  type = list(string)
}

variable "private_device_index" {
  type = string
}

variable "private_ips" {
  type = list(string)
}

variable "source_dest_check" {
  type = bool
}

variable "instance_id" {
  type = string
}

variable "domain" {
  type = string
}
