output "region" {
  value = var.region
}

output "cluster_name" {
  value = var.cluster_name
}

output "bastion_public_ip" {
  value = module.bastion.bastion_public_ip
}

output "kubernetes_api_public_access" {
  value = var.kubernetes_api_public_access
}

output "cluster_autoscaler_helm_values" {
  value = module.cluster_addons.cluster_autoscaler_helm_values
}

output "load_balancer_controller_helm_values" {
  value = module.cluster_addons.load_balancer_controller_helm_values
}

output "addon_versions" {
  value = module.cluster_addons.addon_versions
}

output "worker_node_ami" {
  value = nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value)
}