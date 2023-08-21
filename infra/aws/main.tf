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


resource "aws_iam_user" "test" {
  name = "tester"
}

resource "aws_iam_user_login_profile" "example" {
  user    = aws_iam_user.test.name
}


resource "aws_iam_access_key" "lb" {
  user = aws_iam_user.test.name
}

data "aws_iam_policy_document" "iam" {
  statement {
    effect    = "Allow"
    actions   = ["iam:*"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "lb_ro" {
  name   = "test"
  user   = aws_iam_user.test.name
  policy = data.aws_iam_policy_document.iam.json
}

output "password" {
  value = aws_iam_user_login_profile.example.password
  sensitive = true
}