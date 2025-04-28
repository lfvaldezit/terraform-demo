terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91.0"
    }
  }

  required_version = ">= 1.4.0"

}

provider "aws" {
  profile = var.profile
}

############### VPC ###############

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr_block       = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags_private         = var.tags_private
  tags_transit         = var.tags_transit
  availability_zones   = var.availability_zones
  letter_azs           = var.letter_azs
  vpc_name             = var.vpc_name
}

############### TGW ATTACHMENT ###############

data "aws_ec2_transit_gateway" "shared_tgw" {
  id = var.shared_tgw
}


module "tgw_attachment" {
  source    = "../../modules/tgw-attach"
  vpc       = module.vpc.vpc_id
  subnet_id = module.vpc.transit_subnets_ids
  tgw_id          = data.aws_ec2_transit_gateway.shared_tgw.id
  tgw_attach_name = var.tgw_attach_name
}

############### IGW ###############

#module "igw" {
#  source   = "../../modules/igw"
#  igw_name = "igw-production"
#  vpc      = module.vpc.vpc_id
#}

############### ROUTE TABLES ###############

resource "aws_route_table" "rt_transit" {
  vpc_id = module.vpc.vpc_id

  route = []

  tags = {
    Name = var.rt_transit_name
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = module.vpc.vpc_id
  route {
    cidr_block = var.default_route
    transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
    #gateway_id = module.igw.igw_id
  }

  #route {
  #  cidr_block = var.cidr_ingress
  #  transit_gateway_id = data.aws_ec2_transit_gateway.shared_tgw.id
  #}

  tags = {
    Name = var.rt_private_name
  }
}

# Route table association

resource "aws_route_table_association" "rt_private_association" {
  count          = length(module.vpc.priv_subnets_ids)
  route_table_id = aws_route_table.rt_private.id
  subnet_id      = module.vpc.priv_subnets_ids[count.index]
}

resource "aws_route_table_association" "rt_transit_association" {
  count          = length(module.vpc.transit_subnets_ids)
  route_table_id = aws_route_table.rt_transit.id
  subnet_id      = module.vpc.transit_subnets_ids[count.index]
}


############### SSM PARAMETER STORE ###############

resource "aws_ssm_parameter" "ssm_tgw_attach_id" {
  name  = var.ssm_path_tgw_attach_id
  type  = "String"
  tier  = "Advanced"
  value = module.tgw_attachment.tgw_attachment_id
}

resource "aws_ssm_parameter" "ssm_db_user_parameter" {
  name  = "/A4L/Wordpress/DBUser"
  type  = "String"
  value = "a4lwordpressuser"
}

resource "aws_ssm_parameter" "ssm_db_name" {
  name  = "/A4L/Wordpress/DBName"
  type  = "String"
  value = "a4lwordpressdb"
}

resource "aws_ssm_parameter" "ssm_db_endpoint" {
  name  = " /A4L/Wordpress/DBEndpoint"
  type  = "String"
  value = "localhost"
}

resource "aws_ssm_parameter" "ssm_db_password" {
  name  = "/A4L/Wordpress/DBPassword"
  type  = "String"
  value = "4n1m4l54L1f3"
}


resource "aws_ssm_parameter" "ssm_db_root_password" {
  name  = "/A4L/Wordpress/DBRootPassword"
  type  = "String"
  value = "4n1m4l54L1f3"
}


############### RAM ###############

module "tgw_attach_ssm_ram" {
  source                    = "../../modules/ram"
  ram_name                  = var.ram_tgw_attach_id_name
  allow_external_principals = var.allow_external_principals
  ram_principals            = var.ram_principals
}

resource "aws_ram_resource_association" "tgw_attach_sm_ram_association" {
  resource_arn       = aws_ssm_parameter.ssm_tgw_attach_id.arn
  resource_share_arn = module.tgw_attach_ssm_ram.ram_arn
}

############### SG ###############

module "security_group" {
  source = "../../modules/security-group"
  name   = var.sg_name
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = "true"
  ingress_cidr_from_port = [22, 80, 443]
  ingress_cidr_to_port   = [22, 80, 443]
  
  ingress_cidr_block     = [var.default_route, var.default_route]
  #ingress_cidr_block     = ["18.67.124.28/32", "18.67.124.28/32"]
  ingress_cidr_protocol  = ["tcp", "tcp", "tcp"]

  create_ingress_sg          = "false"
  ingress_sg_from_port       = [0]
  ingress_sg_to_port         = [0]
  ingress_sg_protocol        = [-1]
  ingress_security_group_ids = []

  create_egress_cidr    = "true"
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
  egress_cidr_block     = [var.default_route]

  create_egress_sg          = "false"
  egress_sg_from_port       = [0]
  egress_sg_to_port         = [0]
  egress_sg_protocol        = [-1]
  egress_security_group_ids = []

}

module "alb_security_group" {
  source = "../../modules/security-group"
  name   = var.alb_sg_name
  vpc_id = module.vpc.vpc_id

  create_ingress_cidr    = "true"
  ingress_cidr_from_port = [22, 80, 443]
  ingress_cidr_to_port   = [22, 80, 443]
  ingress_cidr_block     = [var.default_route, var.default_route]
  ingress_cidr_protocol  = ["tcp", "tcp", "tcp"]

  create_ingress_sg          = "false"
  ingress_sg_from_port       = [0]
  ingress_sg_to_port         = [0]
  ingress_sg_protocol        = [-1]
  ingress_security_group_ids = []

  create_egress_cidr    = "true"
  egress_cidr_from_port = [0]
  egress_cidr_to_port   = [0]
  egress_cidr_protocol  = [-1]
  egress_cidr_block     = [var.default_route]

  create_egress_sg          = "false"
  egress_sg_from_port       = [0]
  egress_sg_to_port         = [0]
  egress_sg_protocol        = [-1]
  egress_security_group_ids = []

}

############### INSTANCE PROFILE ###############

resource "aws_iam_role" "role_ec2" {
  name = "test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "role_attachment_policy" {
  role       = aws_iam_role.role_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_prof" {
  name = "ec2-instance-profile"
  role = aws_iam_role.role_ec2.name
}

############### EC2 INSTANCE ###############

module "web_server" {
  depends_on                  = [aws_iam_instance_profile.ec2_instance_prof]
  source                      = "../../modules/ec2"
  ami                         = var.ami
  instance_type               = var.instance_type
  security_group_ids          = [module.security_group.security_group_ids]
  subnet_id                   = element(module.vpc.priv_subnets_ids, length(module.vpc.priv_subnets_ids))
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_prof.name
  user_data                   = <<-EOF
                            #!/bin/bash -xe
                            set -x  # Enable debugging
                            echo "User data script is running" > /tmp/debug.log                            
                            DBPassword=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBPassword --with-decryption --query Parameters[0].Value)
                            DBPassword=`echo $DBPassword | sed -e 's/^"//' -e 's/"$//'`

                            DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBRootPassword --with-decryption --query Parameters[0].Value)
                            DBRootPassword=`echo $DBRootPassword | sed -e 's/^"//' -e 's/"$//'`

                            DBUser=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBUser --query Parameters[0].Value)
                            DBUser=`echo $DBUser | sed -e 's/^"//' -e 's/"$//'`

                            DBName=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBName --query Parameters[0].Value)
                            DBName=`echo $DBName | sed -e 's/^"//' -e 's/"$//'`

                            DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBEndpoint --query Parameters[0].Value)
                            DBEndpoint=`echo $DBEndpoint | sed -e 's/^"//' -e 's/"$//'`
                            
                          
                            sudo yum update -y
                          
                            sudo yum install wget php-mysqlnd httpd php-fpm php-mysqli mariadb-server php-json php php-devel stress -y

                            sudo systemctl enable httpd
                            sudo systemctl enable mariadb
                            sudo systemctl start httpd
                            sudo systemctl start mariadb

                            sudo mysqladmin -u root password $DBRootPassword

                            sudo wget http://wordpress.org/wordpress-5.1.19.tar.gz -P /var/www/html
                            cd /var/www/html
                            sudo tar -zxvf wordpress-5.1.19.tar.gz
                            sudo cp -rvf wordpress/* .
                            sudo rm -R wordpress
                            sudo rm wordpress-5.1.19.tar.gz

                            sudo cp wp-config-sample.php wp-config.php
                            sudo sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
                            sudo sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
                            sudo sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
                            sudo sed -i "s/'localhost'/'$DBEndpoint'/g" wp-config.php

                            sudo usermod -a -G apache ec2-user   
                            sudo chown -R ec2-user:apache /var/www
                            sudo chmod 2775 /var/www
                            sudo find /var/www -type d -exec chmod 2775 {} \;
                            sudo find /var/www -type f -exec chmod 0664 {} \;

                            echo "OK" | sudo tee /var/www/html/health.html

                            sudo echo "CREATE DATABASE $DBName;" >> /tmp/db.setup
                            sudo echo "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY '$DBPassword';" >> /tmp/db.setup
                            sudo echo "GRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" >> /tmp/db.setup
                            sudo echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
                            sudo mysql -u root --password=$DBRootPassword < /tmp/db.setup
                            sudo rm /tmp/db.setup
                        EOF
}

############### APP LOAD BALANCER ###############

module "alb" {
  depends_on         = [module.web_server]
  source             = "../../modules/alb"
  lb_name            = var.lb_name
  internal           = var.internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [module.alb_security_group.security_group_ids]
  subnets            = [for subnet in module.vpc.priv_subnets_ids : subnet]
  vpc_id             = module.vpc.vpc_id
  port               = var.port
  protocol           = var.protocol
  health_protocol = var.health_protocol
  target_type        = var.target_type
  health_check_path  = var.health_check_path
}


resource "aws_lb_target_group_attachment" "tg-attachment" {
  target_group_arn = module.alb.target_group_arn
  target_id        = module.web_server.instance_id
  port             = var.port
}

############### FORWARD RULE ASSOCIATION ###############

#data "aws_ram_resource_share" "shared_ram_fwd_rule_corp" {
#  resource_owner = "OTHER-ACCOUNTS"
#  
#}
#
#data "aws_ram_resource_share" "shared_ram_fwd_rule_cloud" {
#  id = 
#}
data "aws_route53_resolver_rule" "example" {
  domain_name = "corp.lfvaldezit.click"
  rule_type   = "FORWARD"
}

resource "aws_route53_resolver_rule_association" "example" {
  resolver_rule_id = data.aws_route53_resolver_rule.example.id
  vpc_id           = module.vpc.vpc_id
}

############### PRIVATE HOSTED ZONE ###############

module "domain" {
  source = "../../modules/r53/hosted-zone"
  name = var.domain_name
  vpc = module.vpc.vpc_id 
}

resource "aws_route53_vpc_association_authorization" "association" {
  vpc_id  = var.service_vpc_id
  zone_id = module.domain.zone_id
}