variable "cluster_name" {
  type        = string
  description = "The name of the cluster and name (or name prefix) for all other infrastructure."
}

variable "create_network" {
  type        = bool
  default     = true
  description = "When set to false, networking (network, subnetworks, etc) must be created externally."
}

variable "network_cidr_range" {
  type        = string
  default     = null
  description = "The CIDR for the cluster's network."
}

variable "secondary_cidr_range_services" {
  type        = string
  default     = null
  description = "The secondary CIDR range for the cluster's services."
}

variable "secondary_cidr_range_pods" {
  type        = string
  default     = null
  description = "The secondary CIDR range for the cluster's pods. If a separate CIDR range is provided for messaging pods, this range will be used for just the system (default) node pool."
}

variable "secondary_cidr_range_messaging_pods" {
  type        = string
  default     = null
  description = "The secondary CIDR range for the cluster's messaging node pools, if a separate range is desired."
}