variable "users" {
    default = ["Athos", "Porthos", "Aramis"]
}

variable "number_of_buckets" {
    default = 5
}

resource "aws_iam_user" "users" {
    #count = length(var.users)
    for_each = toset(var.users)
    name = each.key
}

resource "aws_s3_bucket" "s3" {
    count = var.number_of_buckets != 0 ? var.number_of_buckets : 1
    bucket = "bucket-perso-${count.index}"
}