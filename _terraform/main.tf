terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.11"
    }
  }

  required_version = ">= 0.14.9"

  backend "s3" {
    bucket = "leslehcouk-terraform-states"
    key    = "static-test.lesleh.co.uk"
    region = "eu-west-2"
  }
}

provider "aws" {
  region  = "eu-west-2"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
}

data "aws_route53_zone" "domain_zone" {
  name = var.domain_zone
}

data "aws_acm_certificate" "static_site_certificate" {
  domain   = var.cert_domain
  statuses = ["ISSUED"]
  provider = aws.virginia
}

module "website_s3_bucket" {
  source  = "lesleh/cloudfront-ssl/s3"
  version = "0.2.0"

  bucket_name     = var.bucket_name
  domain_name     = var.domain
  certificate_arn = data.aws_acm_certificate.static_site_certificate.arn
  route53_zone_id = data.aws_route53_zone.domain_zone.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
