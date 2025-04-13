variable "lb_name" {
  type = string
}

variable "internal" {
  type = bool   
}

variable "load_balancer_type" {
  type = string
}

variable "security_groups" {
  type = set(string)
}

variable "subnets" {
  type = set(string)
}

variable "port" {
  type = string
}

variable "protocol" {
  type = string
}


variable "vpc_id" {
  type = string
}

variable "target_type" {
  type = string
}

variable "health_check_path" {
  type = string
}

variable "health_protocol" {
  type = string
}

#variable "target_id" {
#  type = string
#}