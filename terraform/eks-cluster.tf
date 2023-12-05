module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.18.0"

  cluster_name    = "microservices-cluster"
  cluster_version = "1.28"
  subnet_ids      = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]

  vpc_id = aws_vpc.eks_vpc.id

  cluster_endpoint_public_access = true  # Enable public access to the API server
  # cluster_endpoint_public_access_cidrs = ["147.235.200.225/32"]  # Restrict public access to my current IP address
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]  # Temporarily allow all IPs

  eks_managed_node_groups = {
    eks_nodes = {
      min_size     = 1
      max_size     = 2
      desired_size = 2
      
      instance_types = ["t3.micro"]
      key_name      = var.key_name

      subnet_ids = [aws_subnet.eks_subnet_a.id, aws_subnet.eks_subnet_b.id]
    }
  }
}

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
