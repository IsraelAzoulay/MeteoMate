# Terraform Variables for the EKS Cluster Configuration

# Key name for the EC2 instances in the EKS cluster
variable "key_name" {
  description = "The key name to use for the instance"
  default     = "eks-worker-nodes-keypair"
}

# AWS region where the resources will be deployed
variable "region" {
  description = "The AWS region to deploy resources into"
  default     = "us-east-1"
}
