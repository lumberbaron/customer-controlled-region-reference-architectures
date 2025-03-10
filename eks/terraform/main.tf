################################################################################
# Network
################################################################################

module "network" {
  source = "./modules/network"

  cluster_name   = var.cluster_name
  create_network = var.create_network

  vpc_cidr                        = var.vpc_cidr
  public_subnet_cidrs             = var.public_subnet_cidrs
  private_subnet_cidrs            = var.private_subnet_cidrs
  preferred_availability_zone_ids = var.preferred_availability_zone_ids
}

################################################################################
# Bastion
################################################################################

module "bastion" {
  source = "./modules/bastion"

  cluster_name   = var.cluster_name
  create_bastion = var.create_bastion

  vpc_id    = var.create_network ? module.network.vpc_id : var.vpc_id
  subnet_id = var.create_network ? module.network.public_subnets[2] : var.bastion_subnet_id

  bastion_public_access           = var.bastion_public_access
  bastion_ssh_authorized_networks = var.bastion_ssh_authorized_networks
  bastion_ssh_public_key          = var.bastion_ssh_public_key
  cluster_security_group_id       = module.cluster.cluster_security_group_id
}

################################################################################
# Cluster
################################################################################

module "cluster" {
  source = "./modules/cluster"

  region       = var.region
  cluster_name = var.cluster_name

  vpc_id             = var.create_network ? module.network.vpc_id : var.vpc_id
  private_subnet_ids = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  kubernetes_version                 = var.kubernetes_version
  kubernetes_service_cidr            = var.kubernetes_service_cidr
  kubernetes_api_public_access       = var.kubernetes_api_public_access
  kubernetes_api_authorized_networks = var.kubernetes_api_authorized_networks
  kubernetes_cluster_admin_arns      = var.kubernetes_cluster_admin_arns
}

module "cluster_addons" {
  source = "./modules/cluster-addons"

  region       = var.region
  cluster_name = module.cluster.cluster_name
  cluster_id   = module.cluster.cluster_id

  default_node_group_arn = module.node_group_default.node_group_arn

  common_tags = var.common_tags
}

################################################################################
# Node Groups
################################################################################

locals {
  default_instance_type = "m5.large"

  prod1k_instance_type     = "r5.large"
  prod5k_instance_type     = "r5.xlarge"
  prod10k_instance_type    = "r6in.xlarge"
  prod50k_instance_type    = "r6in.2xlarge"
  prod100k_instance_type   = "r6in.4xlarge"
  monitoring_instance_type = "t3.medium"

  worker_node_volume_size = 20
  worker_node_volume_type = "gp2"

  resources_tags = [
    {
      key   = "k8s.io/cluster-autoscaler/node-template/resources/ephemeral-storage"
      value = "${local.worker_node_volume_size}G"
    }
  ]
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}

module "node_group_default" {
  source = "./modules/default-node-group"

  cluster_name       = module.cluster.cluster_name
  node_group_name    = "default"
  security_group_ids = [module.cluster.worker_node_security_group_id]
  subnet_ids         = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.default_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_desired_size = 2
}

module "node_group_prod1k" {
  source = "./modules/broker-node-group"

  cluster_name           = module.cluster.cluster_name
  node_group_name_prefix = "prod1k"
  security_group_ids     = [module.cluster.worker_node_security_group_id]
  subnet_ids             = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.prod1k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod1k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod1k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_prod5k" {
  source = "./modules/broker-node-group"

  cluster_name           = module.cluster.cluster_name
  node_group_name_prefix = "prod5k"
  security_group_ids     = [module.cluster.worker_node_security_group_id]
  subnet_ids             = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.prod5k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod5k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod5k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_prod10k" {
  source = "./modules/broker-node-group"

  cluster_name           = module.cluster.cluster_name
  node_group_name_prefix = "prod10k"
  security_group_ids     = [module.cluster.worker_node_security_group_id]
  subnet_ids             = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.prod10k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod10k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod10k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_prod50k" {
  source = "./modules/broker-node-group"

  cluster_name           = module.cluster.cluster_name
  node_group_name_prefix = "prod50k"
  security_group_ids     = [module.cluster.worker_node_security_group_id]
  subnet_ids             = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.prod50k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod50k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod50k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_prod100k" {
  source = "./modules/broker-node-group"

  cluster_name           = module.cluster.cluster_name
  node_group_name_prefix = "prod100k"
  security_group_ids     = [module.cluster.worker_node_security_group_id]
  subnet_ids             = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.prod100k_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_labels = {
    nodeType     = "messaging"
    serviceClass = "prod100k"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "messaging"
      effect = "NO_EXECUTE"
    },
    {
      key    = "serviceClass"
      value  = "prod100k"
      effect = "NO_EXECUTE"
    }
  ]
}

module "node_group_monitoring" {
  source = "./modules/broker-node-group"

  cluster_name           = module.cluster.cluster_name
  node_group_name_prefix = "monitoring"
  security_group_ids     = [module.cluster.worker_node_security_group_id]
  subnet_ids             = var.create_network ? module.network.private_subnets : var.private_subnet_ids

  worker_node_role_arn      = module.cluster.worker_node_role_arn
  worker_node_instance_type = local.monitoring_instance_type
  worker_node_volume_size   = local.worker_node_volume_size
  worker_node_volume_type   = local.worker_node_volume_type
  worker_node_tags          = var.common_tags

  node_group_max_size       = var.node_group_max_size
  node_group_resources_tags = local.resources_tags

  kubernetes_version      = var.kubernetes_version
  worker_node_ami_version = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)

  node_group_labels = {
    nodeType = "monitoring"
  }

  node_group_taints = [
    {
      key    = "nodeType"
      value  = "monitoring"
      effect = "NO_EXECUTE"
    }
  ]
}