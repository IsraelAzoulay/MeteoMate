# AWS ACM Certificate Configuration for the EKS Cluster - it's used for securing communication to the EKS cluster,
# especially when exposed via the Load Balancer.
# Note: I'm using using 'GoDaddy' for the DNS, thus the 'Route53' record block is not needed.

resource "aws_acm_certificate" "cert" {
  domain_name               = "meteomate.online" # Primary domain for the certificate
  validation_method         = "DNS" # Method used for the certificate validation
  subject_alternative_names = ["www.meteomate.online"] # Additional domain names covered by the certificate

  tags = {
    Name = "my-cert" # Tag the certificate for identification
  }

  lifecycle {
    create_before_destroy = true # Ensures certificate is created before it's destroyed (useful during updates)
  }
}