resource "heroku_app" "test" {
    name = "test-${var.heroku_app_name}"
    region = "${var.heroku_region}"

    config_vars {
        AWS_SECRET_KEY = "${aws_iam_access_key.test_user.secret}"
        AWS_ACCESS_KEY = "${aws_iam_access_key.test_user.id}"
        S3_BUCKET = "${var.test_bucket_name}"
        SITE_URL = "http://test-${var.domain_url}"
        DEBUG = "True"
        ALLOWED_HOSTS = "${var.test_bucket_name}, test-${var.heroku_app_name}.herokuapp.com"
        MEDIA_URL = "https://${var.test_bucket_name}.s3.amazonaws.com/media/"
        STATIC_URL = "https://${var.test_bucket_name}.s3.amazonaws.com/static/"
    }
}

# Create a database, and configure the app to use it
resource "heroku_addon" "test-database" {
  app = "${heroku_app.test.name}"
  plan = "heroku-postgresql:hobby-dev"
}

# Add redis cache
resource "heroku_addon" "test-redis" {
  app = "${heroku_app.test.name}"
  plan = "heroku-redis:hobby-dev"
}

resource "heroku_addon" "test-logentry" {
  app = "${heroku_app.test.name}"
  plan = "logentries:le_tryit"
}

resource "heroku_addon" "test-autobus" {
  app = "${heroku_app.test.name}"
  plan = "autobus:trip"
}

resource "heroku_app" "prod" {
    name = "${var.heroku_app_name}"
    region = "${var.heroku_region}"

    config_vars {
        AWS_SECRET_KEY = "${aws_iam_access_key.prod_user.secret}"
        AWS_ACCESS_KEY = "${aws_iam_access_key.prod_user.id}"
        S3_BUCKET = "${var.prod_bucket_name}"
        SITE_URL = "http://${var.domain_url}"
        DEBUG = "False"
        ALLOWED_HOSTS = "${var.prod_bucket_name}, ${var.heroku_app_name}.herokuapp.com"
        MEDIA_URL = "https://${var.prod_bucket_name}.s3.amazonaws.com/media/"
        STATIC_URL = "https://${var.prod_bucket_name}.s3.amazonaws.com/static/"
    }
}

# Create a database, and configure the app to use it
resource "heroku_addon" "prod-database" {
  app = "${heroku_app.prod.name}"
  plan = "heroku-postgresql:hobby-dev"
}

# Add redis cache
resource "heroku_addon" "prod-redis" {
  app = "${heroku_app.prod.name}"
  plan = "heroku-redis:hobby-dev"
}

resource "heroku_addon" "prod-logentry" {
  app = "${heroku_app.prod.name}"
  plan = "logentries:le_tryit"
}

resource "heroku_addon" "prod-autobus" {
  app = "${heroku_app.prod.name}"
  plan = "autobus:trip"
}

resource "heroku_domain" "prod" {
    app = "${heroku_app.prod.name}"
    hostname = "${var.domain_url}"
}

resource "heroku_domain" "test" {
    app = "${heroku_app.test.name}"
    hostname = "${var.test_domain_url}"
}