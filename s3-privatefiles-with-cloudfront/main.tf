provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

resource "aws_iam_user" "bucket_user" {
    name = "${var.tag}-user"
}

resource "aws_iam_user_policy" "user_policy" {
    name = "test"
    user = "${aws_iam_user.bucket_user.name}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.bucket_name}/*"
        }
   ]
}
EOF
}

resource "aws_iam_access_key" "bucket_user" {
  user = "${aws_iam_user.bucket_user.name}"
}

resource "aws_s3_bucket" "bucket" {
    bucket = "${var.bucket_name}"
    acl = "private"
}

output "secret" {
  value = "${aws_iam_access_key.bucket_user.secret}"
}

output "accesskey" {
 value = "${aws_iam_access_key.bucket_user.id}"
}