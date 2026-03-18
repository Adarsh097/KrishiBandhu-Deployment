output "vpc_id" {
  description = "VPC used for EKS"
  value       = data.terraform_remote_state.vpc.outputs.vpc_id
}

output "public_subnets" {
  description = "Public subnets used by EKS worker nodes"
  value       = data.terraform_remote_state.vpc.outputs.public_subnets
}

output "intra_subnets" {
  description = "Subnets used by EKS control plane"
  value       = data.terraform_remote_state.vpc.outputs.intra_subnets
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for Kubernetes API"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes Version"
  value       = module.eks.cluster_version
}

output "eks_node_ids" {
  description = "EKS worker node instance IDs"
  value       = data.aws_instances.eks_nodes.ids
}

output "eks_node_private_ips" {
  description = "Private IPs of worker nodes"
  value       = data.aws_instances.eks_nodes.private_ips
}

output "eks_node_public_ips" {
  description = "Public IPs of worker nodes"
  value       = data.aws_instances.eks_nodes.public_ips
}
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${local.region} --name ${module.eks.cluster_name}"
}
