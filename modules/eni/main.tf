resource "aws_network_interface" "public" {
  subnet_id       = var.public_subnet_id
  security_groups = var.public_security_groups
  source_dest_check = var.source_dest_check

  attachment {
    instance     = var.instance_id
    device_index = var.public_device_index
  }
}

resource "aws_eip" "eip" {
    domain = var.domain
}

resource "aws_eip_association" "eip_association" {
    instance_id = var.instance_id
    allocation_id = aws_eip.eip.id
}

resource "aws_network_interface" "private" {
  subnet_id       = var.private_subnet_id
  private_ips     = var.private_ips
  security_groups = var.private_security_groups
  source_dest_check = var.source_dest_check

  attachment {
    instance     = var.instance_id
    device_index = var.private_device_index
  }
}
