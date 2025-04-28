    variable "ami" {
        type = string
    }

    variable "instance_type" {
        type = string
    }

    variable "security_group_ids" {
      type = list(string)
    }

    variable "subnet_id" {
      type = string
    }
    
    variable "user_data" {
      type = string
    }

    variable "iam_instance_profile" {
      type = string
    }