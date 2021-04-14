provider "aws" {
  region                  = var.region
  shared_credentials_file = "/home/stagiaire/.aws/credentials"
  profile                 = "teacher"
}