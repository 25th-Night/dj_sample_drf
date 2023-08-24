terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

# Create a VPC
resource "aws_vpc" "example" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "Default VPC"
  }
}


resource "aws_iam_user" "dev" {
  for_each = toset([ "monkey", "hippo", "horse" ])
  name = each.key
  path = "/dev/"
}

# resource "aws_iam_user_login_profile" "example" {
#   user    = aws_iam_user.test.name
# }


resource "aws_iam_access_key" "dev" {
  for_each = aws_iam_user.dev
  user = each.value.name
}

output "IAM_ACCESS_KEY" {
  value = {
    for k, v in aws_iam_access_key.dev : k => v.id
  }
}

data "aws_iam_policy_document" "iam" {
  statement {
    effect    = "Allow"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}

# resource "aws_iam_user_policy" "lb_ro" {
#   name   = "test"
#   user   = aws_iam_user.test.name
#   policy = data.aws_iam_policy_document.iam.json
# }

# output "password" {
#   value = aws_iam_user_login_profile.example.password
#   sensitive = true
# }

# resource "local_file" "users" {
#   content  = "${aws_iam_user_login_profile.example.password}"
#   filename = "${path.module}/users.txt"
# }

data "aws_iam_account_alias" "current" {}

output "account_id" {
  value = data.aws_iam_account_alias.current.account_alias
}