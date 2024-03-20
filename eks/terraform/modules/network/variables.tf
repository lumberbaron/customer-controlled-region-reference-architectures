variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (VPC, Subnets, etc) must be created externally."
}

variable "vpc_cidr" {
  type        = string
  default     = null
  description = "The CIDR of the cluster's VPC."
}

variable "vpc_secondary_cidrs" {
  type        = list(string)
  default     = null
  description = "The secondary CIDRs of the cluster's VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three public subnets. These will contain the bastion host, NAT gateways, and internet-facing load balancer ENIs (if desired)."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "The CIDRs of the three private subnets. These will contain internal load-balancer ENIs (if desired). By default, these will also contain the EKS cluster's ENIs and worker nodes."
}

variable "create_cluster_subnets" {
  type        = bool
  default     = false
  description = "When set to true, a third set of subnets is created that will contain the  EKS cluster's ENIs and worker nodes."
}

variable "cluster_subnet_cidrs" {
  type        = list(string)
  default     = null
  description = "The CIDRs of the three cluster subnets, if desired. These will contain the EKS cluster's ENIs and worker nodes."
}

variable "pod_spread_policy" {
  type        = string
  default     = "full"
  description = "This controls which AZs host node groups for the primary, backup, and monitor node pools as well as which AZs will host the ENIs for the NLBs that front each event broker service. See the readme for more details."

  validation {
    condition     = var.pod_spread_policy == "full" || var.pod_spread_policy == "fixed"
    error_message = "The pod_spread_policy value must be either 'full' or 'fixed'."
  }
}