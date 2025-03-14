variable "region" {
  type        = string
  description = "The AWS region where this cluster will reside."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags that are added to all resources created by this module."
}

################################################################################
# Network
################################################################################

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (VPC, Subnets, etc) must be created externally."
}

variable "vpc_cidr" {
  type        = string
  default     = ""
  description = "The CIDR of the cluster's VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three public subnets. These will contain the bastion host, NAT gateways, and internet-facing load balancer ENIs (if desired)."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three private subnets. These will contain the EKS cluster's master ENIs, worker nodes, and internal load-balancer ENIs (if desired)."
}

variable "preferred_availability_zone_ids" {
  type        = list(string)
  default     = []
  description = "The preferred availability zones to use for the created subnets, specified by ZoneId (eg. 'use1-az1') -- not ZoneName (eg. 'us-east-1a'). If no specific zones are required, leave empty."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "When 'create_network' is set to false, the VPC ID must be provided."
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
  description = "When 'create_network' is set to false, the private subnet IDs must be provided."
}

################################################################################
# Bastion
################################################################################

variable "create_bastion" {
  type        = bool
  default     = true
  description = "Whether to create a bastion host. If Kubernetes API is private-only then a way to access it must be configured separately."
}

variable "bastion_subnet_id" {
  type        = string
  default     = null
  description = "When 'create_network' is set to false but a bastion is desired, the bastion's subnet ID must be provided."
}

variable "bastion_public_access" {
  type        = bool
  default     = true
  description = "When set to true the bastion host is assigned a public IP and can be access from any of the networks provided in the 'bastion_ssh_authorized_networks' parameter."
}

variable "bastion_ssh_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the SSH port (22) on the bastion host."
}

variable "bastion_ssh_public_key" {
  type        = string
  default     = ""
  description = "The public key that will be added to the authorized keys file on the bastion host for SSH access."
}

################################################################################
# Cluster
################################################################################

variable "kubernetes_version" {
  type        = string
  description = "The kubernetes version to use. Only used a creation time, ignored once the cluster exists."
}

variable "kubernetes_service_cidr" {
  type        = string
  default     = "10.100.0.0/16"
  description = "The CIDR used to assign IPs to kubernetes services, internal to the cluster."
}

variable "node_group_max_size" {
  type        = number
  default     = 10
  description = "The maximum size for the broker node groups in the cluster."
}

variable "kubernetes_api_public_access" {
  type        = bool
  default     = false
  description = "When set to true, the Kubernetes API is accessible publicly from the provided authorized networks."
}

variable "kubernetes_api_authorized_networks" {
  type        = list(string)
  default     = []
  description = "The list of CIDRs that can access the Kubernetes API, in addition to the bastion host and worker nodes (which are added by default)."
}

variable "kubernetes_cluster_admin_arns" {
  type        = list(string)
  default     = []
  description = "User or role ARNs can be provided that will be given assigned AmazonEKSClusterAdminPolicy for this cluster."
}