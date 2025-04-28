############### VPC ###############

module "vpc" {
  source                   = "../../modules/_vpc"
  vpc_name                 = var.vpc_name
  vpc_cidr_block           = var.vpc_cidr_block
  instance_tenancy         = var.instance_tenancy
  availability_zones       = var.availability_zones
  enable_dns_hostnames     = var.enable_dns_hostnames
  enable_dns_support       = var.enable_dns_support
  letter_azs               = var.letter_azs
  main_cidr_block          = var.public_cidr_block
  main_route_table_id      = aws_route_table.rt_public.id
  tag_main_subnet          = var.sn_tag_public
  secondary_cidr_block     = var.private_cidr_block
  secondary_route_table_id = aws_route_table.rt_private.id
  tag_secondary_subnet     = var.sn_tag_private
}

############### ROUTE TABLES ###############

resource "aws_route_table" "rt_public" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = var.default_route
    gateway_id = module.igw.igw_id
  }

  tags = {
    Name = var.rt_public_name
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = module.vpc.vpc_id
  route  = []

  tags = {
    Name = var.rt_private_name
  }
}

############### IGW ###############

module "igw" {
  source   = "../../modules/igw"
  igw_name = var.igw_name
  vpc      = module.vpc.vpc_id
}

############### ENI ###############

### Routers Strongwan   

#module "eni_router_1" {
#  source = "../../modules/eni"
#  public_subnet_id = module.vpc.main_subnet_id[0]
#  public_security_groups = module.router_security_group.security_group_ids
#  public_device_index = var.public_device_index
#  private_subnet_id = module.vpc.secondary_subnet_id[2]
#  private_ips = var.privates_ips[0]
#  private_security_groups = module.router_security_group.security_group_ids
#  private_device_index = var.private_device_index
#  instance_id = 
#  source_dest_check = var.source_dest_check
#  domain = var.domain
#}
#
#module "eni_router_2" {
#  source = "../../modules/eni"
#  public_subnet_id = module.vpc.main_subnet_id[1]
#  public_security_groups = module.router_security_group.security_group_ids
#  public_device_index = var.public_device_index
#  private_subnet_id = module.vpc.secondary_subnet_id[3]
#  private_ips = var.privates_ips[1]
#  private_security_groups = module.router_security_group.security_group_ids
#  private_device_index = var.private_device_index
#  instance_id = 
#  source_dest_check = var.source_dest_check
#  domain = var.domain
#}

############### SECURITY GROUPS ###############

module "router_security_group" {
  source = "../../modules/security-group"
  name   = var.router_sg_name
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = "true"
  ingress_cidr_from_port = [0]
  ingress_cidr_to_port   = [0]
  ingress_cidr_block     = [var.aws_prefix]
  ingress_cidr_protocol  = ["-1"]

  create_ingress_sg          = "false"
  ingress_sg_from_port       = [0]
  ingress_sg_to_port         = [0]
  ingress_sg_protocol        = [-1]
  ingress_security_group_ids = []

  create_egress_cidr    = "false"
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
  egress_cidr_block     = []

  create_egress_sg          = "false"
  egress_sg_from_port       = [0]
  egress_sg_to_port         = [0]
  egress_sg_protocol        = [-1]
  egress_security_group_ids = []
}

module "dns_security_group" {
  source = "../../modules/security-group"
  name   = var.dns_sg_name
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = "true"
  ingress_cidr_from_port = ["22", "80", "53", "53"]
  ingress_cidr_to_port   = ["22", "80", "53", "53"]
  ingress_cidr_block     = [var.aws_prefix]
  ingress_cidr_protocol  = ["tcp", "tcp", "tcp", "tcp"]

  create_ingress_sg          = "false"
  ingress_sg_from_port       = [0]
  ingress_sg_to_port         = [0]
  ingress_sg_protocol        = [-1]
  ingress_security_group_ids = []

  create_egress_cidr    = "false"
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
  egress_cidr_block     = []

  create_egress_sg          = "false"
  egress_sg_from_port       = [0]
  egress_sg_to_port         = [0]
  egress_sg_protocol        = [-1]
  egress_security_group_ids = []
}

############### SECURITY GROUPS ###############

### Routers Strongwan  

module "EC2_DNS_1" {
  source                      = "../../modules/ec2"
  ami                         = var.dns_ami
  instance_type               = var.dns_instance_type
  security_group_ids          = [module.router_security_group.security_group_ids]
  subnet_id                   = module.vpc.main_subnet_id[0]
  iam_instance_profile        = "null"
  user_data                   = <<-EOF
                                #!/bin/bash -xe
                                  dnf install bind bind-utils -y
                                  cat <<EON > /etc/named.conf
                                  options {
                                    directory	"/var/named";
                                    dump-file	"/var/named/data/cache_dump.db";
                                    statistics-file "/var/named/data/named_stats.txt";
                                    memstatistics-file "/var/named/data/named_mem_stats.txt";
                                    allow-query { any; };
                                    recursion yes;
                                    forward first;
                                    forwarders {
                                      192.168.10.2;
                                    };
                                    dnssec-enable yes;
                                    dnssec-validation yes;
                                    dnssec-lookaside auto;
                                    /* Path to ISC DLV key */
                                    bindkeys-file "/etc/named.iscdlv.key";
                                    managed-keys-directory "/var/named/dynamic";
                                  };
                                  zone "corp.lfvaldezit.click" IN {
                                      type master;
                                      file "corp.animals4life.org.zone";
                                      allow-update { none; };
                                  };
		                              zone "aws.lfvaldezit.click" IN {
                                      type forward;
                                      forward only;
                                      forwarders {192.168.0.; 192.168.1.0};
                                  };
                                  EON
                                  cat <<EON > /var/named/corp.lfvaldezit.click.zone
                                  \$TTL 86400
                                  @   IN  SOA     ns1.mydomain.com. root.mydomain.com. (
                                          2013042201  ;Serial
                                          3600        ;Refresh
                                          1800        ;Retry
                                          604800      ;Expire
                                          86400       ;Minimum TTL
                                  )
                                  ; Specify our two nameservers
                                      IN	NS		dnsA.corp.lfvaldezit.click.
                                      IN	NS		dnsB.corp.lfvaldezit.click.
                                  ; Resolve nameserver hostnames to IP, replace with your two droplet IP addresses.
                                  dnsA		IN	A		1.1.1.1
                                  dnsB	  IN	A		8.8.8.8

                                  ; Define hostname -> IP pairs which you wish to resolve
                                  @		  IN	A		172.17.2.252
                                  app		IN	A	  172.17.2.252
                                  EON
                                  service named restart
                                  chkconfig named on
                              EOF
}