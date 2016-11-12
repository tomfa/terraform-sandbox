provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

module "testbucket" {
    source  = "github.com/tomfa/terraform-sandbox/s3-webfiles-with-cloudfront"
    aws_region = "${var.aws_region}"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    bucket_name = "${var.bucket_name}-test"
}

module "prodbucket" {
    source  = "github.com/tomfa/terraform-sandbox/s3-webfiles-with-cloudfront"
    aws_region = "${var.aws_region}"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    bucket_name = "${var.bucket_name}"
}