variable "key_name" {
  description = "The key name to use for the instance"
  default     = "eks-worker-nodes-keypair"
}

variable "region" {
  description = "The AWS region to deploy resources into"
  default     = "us-east-1"
}
