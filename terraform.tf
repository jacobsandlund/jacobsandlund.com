terraform {
  backend "s3" {
    bucket = "jacobsandlund-terraform-state"
    key    = "jacobsandlund.com.tfstate"
    region = "us-west-1"
  }
}

provider "aws" {
  region = "us-west-1"
}

provider "cloudflare" {
  # email pulled from $CLOUDFLARE_EMAIL
  # token pulled from $CLOUDFLARE_TOKEN
}

resource "aws_s3_bucket" "jacobsandlund_com" {
  bucket = "jacobsandlund.com"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::jacobsandlund.com/*",
            "Condition": {
                "IpAddress": {
                    "aws:SourceIp": [
                        "2400:cb00::/32",
                        "2405:8100::/32",
                        "2405:b500::/32",
                        "2606:4700::/32",
                        "2803:f800::/32",
                        "2c0f:f248::/32",
                        "2a06:98c0::/29",
                        "103.21.244.0/22",
                        "103.22.200.0/22",
                        "103.31.4.0/22",
                        "104.16.0.0/12",
                        "108.162.192.0/18",
                        "131.0.72.0/22",
                        "141.101.64.0/18",
                        "162.158.0.0/15",
                        "172.64.0.0/13",
                        "173.245.48.0/20",
                        "188.114.96.0/20",
                        "190.93.240.0/20",
                        "197.234.240.0/22",
                        "198.41.128.0/17"
                    ]
                }
            }
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "www_jacobsandlund_com" {
  bucket = "www.jacobsandlund.com"

  website {
    redirect_all_requests_to = "https://jacobsandlund.com"
  }
}


resource "cloudflare_record" "jacobsandlund_com" {
  type    = "CNAME"
  domain  = "jacobsandlund.com"
  name    = "jacobsandlund.com"
  value   = "jacobsandlund.com.s3-website-us-west-1.amazonaws.com"
}

resource "cloudflare_record" "www_jacobsandlund_com" {
  type    = "CNAME"
  domain  = "jacobsandlund.com"
  name    = "www"
  value   = "www.jacobsandlund.com.s3-website-us-west-1.amazonaws.com"
}
