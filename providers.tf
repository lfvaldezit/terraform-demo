provider "aws-general" {
  region  = "us-east-1"
  profile = "iamadmin-general"
}

provider "aws-production" {
  alias  = "iamadmin-production"
  region = "us-east-1"
}