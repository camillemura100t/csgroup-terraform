provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "/home/stagiaire/.terraform/aws-credentials"
  profile                 = "chris"
}

# Remote State
terraform {
  backend "s3" {
      bucket    = "terraform-remote-state-demo-chris"
      key       = "formation/terraform.tfstate"
      region    = "eu-central-1"
      shared_credentials_file = "/home/stagiaire/.terraform/aws-credentials"
      profile                 = "chris"
  }
}

resource "aws_security_group" "sg" {
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}