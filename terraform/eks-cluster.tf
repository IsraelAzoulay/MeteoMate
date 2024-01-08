# eks-cluster.tf
# This Terraform configuration file is used to set up the AWS EKS cluster.
# It defines the EKS cluster, managed node groups, and associated settings.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.18.0"

  # Basic configuration for the EKS cluster
  cluster_name    = "microservices-cluster"
  cluster_version = "1.28"
  subnet_ids      = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]

  vpc_id = aws_vpc.eks_vpc.id

  # Enabling public access to the EKS control plane
  cluster_endpoint_public_access = true  # Enable public access to the API server
  # cluster_endpoint_public_access_cidrs = ["147.235.200.225/32"]  # Restrict public access to my current IP address
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Temporarily allow all IPs

  # Configuration for the EKS managed node groups
  eks_managed_node_groups = {
    eks_nodes = {
      # Minimum, maximum, and desired number of worker nodes
      min_size     = 2
      max_size     = 3
      desired_size = 3
      
      # Instance types for the worker nodes
      instance_types = ["t2.micro"]
      # SSH key name for accessing worker nodes
      key_name      = var.key_name

      # Subnets for the worker nodes
      subnet_ids = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]
    }
  }
}

# Output variables providing information about the created EKS cluster
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group id attached to the EKS cluster."
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name attached to EKS cluster."
  value       = module.eks.cluster_iam_role_name
}
