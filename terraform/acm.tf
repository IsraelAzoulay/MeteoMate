# I'm using using 'GoDaddy' for the DNS, thus the 'Route53' record block is not needed.
resource "aws_acm_certificate" "cert" {
  domain_name               = "meteomate.online"
  validation_method         = "DNS"
  subject_alternative_names = ["www.meteomate.online"]

  tags = {
    Name = "my-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}