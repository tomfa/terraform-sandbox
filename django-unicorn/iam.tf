resource "aws_iam_user" "test_user" {
    name = "${var.test_bucket_name}-user"
    path = "/system/"
}

resource "aws_iam_access_key" "test_user" {
    user = "${aws_iam_user.test_user.name}"
}

resource "aws_iam_user_policy" "test_user_ro" {
    name = "test"
    user = "${aws_iam_user.test_user.name}"
    policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.test_bucket_name}",
                "arn:aws:s3:::${var.test_bucket_name}/*"
            ]
        }
   ]
}
EOF
}

resource "aws_iam_user" "prod_user" {
    name = "${var.prod_bucket_name}-user"
    path = "/system/"
}

resource "aws_iam_access_key" "prod_user" {
    user = "${aws_iam_user.prod_user.name}"
}

resource "aws_iam_user_policy" "prod_user_ro" {
    name = "prod"
    user = "${aws_iam_user.prod_user.name}"
   policy= <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${var.prod_bucket_name}",
                "arn:aws:s3:::${var.prod_bucket_name}/*"
            ]
        }
   ]
}
EOF
}