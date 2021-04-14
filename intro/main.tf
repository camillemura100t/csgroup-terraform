# HCL Hashicorp Configuration Langage

# --- PROVIDER SECTION ---
provider "aws" {
    region                  = "eu-central-1"
    shared_credentials_file = "/home/stagiaire/.aws/credentials"
    profile                 = "teacher"
}

# --- VARIABLE SECTION ---
variable "student" {
  type = string
  default = "Chris" # terraform plan -var 'student=Chris'
}

variable "students" {
  type = list(string)
  default = ["Chris", "Tophe"] # var.students[0] == Chris
}

# --- RESOURCE SECTION ---
resource "aws_s3_bucket" "intro" {
    bucket = "bucket-terraform-intro-${lower(var.student)}-${aws_instance.intro.id}"

    tags = {
      Name = var.student
      Instance_Id = aws_instance.intro.id
    }
}

# --- OUTPUT SECTION ---
# terraform output
output "instance_id" {
  value = aws_instance.intro.id
}

output "bucket_demo_arn" {
  value = aws_s3_bucket.intro.arn
}

