module "vpc" {
  source           = "../../modules/vpc-dynamic"
  vpc_cidr         = "10.0.0.0/16"
  region           = "us-east-1"
  name             = "demo"
  subnets_per_az   = 2
}