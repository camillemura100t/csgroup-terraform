resource "aws_instance" "intro" {
  ami           = "ami-0db9040eb3ab74509"
  instance_type = "t2.micro"

  tags = {
    Name = var.students[0]
  }
}