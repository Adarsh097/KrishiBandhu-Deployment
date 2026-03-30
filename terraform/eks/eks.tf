module "eks" {

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }

  # Access VPC from remote state
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnets

  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.intra_subnets

  eks_managed_node_group_defaults = {
    instance_types                        = ["c7i-flex.large"]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {

    krishi-ng = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types = ["c7i-flex.large"]
      capacity_type  = "SPOT"

      disk_size = 35

      tags = {
        Name        = "krishi-node-group"
        Environment = "dev"
      }
    }
  }

  node_security_group_additional_rules = {

    nodeport_ingress = {
      description = "Allow NodePort services"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  tags = local.tags
}


data "aws_instances" "eks_nodes" {

  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]

}
