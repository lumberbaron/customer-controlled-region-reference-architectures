<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | 3.0.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 4.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.0.2 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/kubernetes_cluster) | resource |
| [azurerm_log_analytics_workspace.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.cluster_admin](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.cluster_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.cluster](https://registry.terraform.io/providers/hashicorp/azurerm/4.11.0/docs/resources/user_assigned_identity) | resource |
| [azuread_user.cluster_admin](https://registry.terraform.io/providers/hashicorp/azuread/3.0.2/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The availability zones for the default (system) node pool. | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster and name (or name prefix) for all other infrastructure. | `string` | n/a | yes |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags that are added to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_kubernetes_api_authorized_networks"></a> [kubernetes\_api\_authorized\_networks](#input\_kubernetes\_api\_authorized\_networks) | A list of CIDRs that can access the Kubernetes API, in addition to the VPC's CIDR (which is added by default). | `list(string)` | `[]` | no |
| <a name="input_kubernetes_api_public_access"></a> [kubernetes\_api\_public\_access](#input\_kubernetes\_api\_public\_access) | When set to true, the Kubernetes API is accessible publically from the provided authorized networks. | `bool` | `false` | no |
| <a name="input_kubernetes_cluster_admin_groups"></a> [kubernetes\_cluster\_admin\_groups](#input\_kubernetes\_cluster\_admin\_groups) | A list of Azure AD group object IDs that will have the Admin Role for the cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_cluster_admin_users"></a> [kubernetes\_cluster\_admin\_users](#input\_kubernetes\_cluster\_admin\_users) | A list of Azure AD users that will be assigned the 'Azure Kubernetes Service Cluster User Role' role for this cluster. | `list(string)` | `[]` | no |
| <a name="input_kubernetes_dns_service_ip"></a> [kubernetes\_dns\_service\_ip](#input\_kubernetes\_dns\_service\_ip) | The IP address within the service CIDR that will be used for kube-dns. | `string` | `"10.100.0.10"` | no |
| <a name="input_kubernetes_pod_cidr"></a> [kubernetes\_pod\_cidr](#input\_kubernetes\_pod\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `"10.101.0.0/16"` | no |
| <a name="input_kubernetes_service_cidr"></a> [kubernetes\_service\_cidr](#input\_kubernetes\_service\_cidr) | The CIDR used to assign IPs to kubernetes services, internal to the cluster. | `string` | `"10.100.0.0/16"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The kubernetes version for the cluster. | `string` | n/a | yes |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | By default, AKS has an admin account that can be used to access the cluster with static credentials. It's better to leave this disabled and use Azure RBAC, but it can be enabled if required. | `bool` | `true` | no |
| <a name="input_max_pods_per_node"></a> [max\_pods\_per\_node](#input\_max\_pods\_per\_node) | The maximum number of pods for the worker nodes in the node pools. | `number` | `110` | no |
| <a name="input_outbound_ip_count"></a> [outbound\_ip\_count](#input\_outbound\_ip\_count) | The number of public IPs assigned to the load balancer that performs NAT for the VNET. | `number` | `2` | no |
| <a name="input_outbound_ports_allocated"></a> [outbound\_ports\_allocated](#input\_outbound\_ports\_allocated) | The number of outbound ports allocated for NAT for each VM within the VNET. | `number` | `896` | no |
| <a name="input_region"></a> [region](#input\_region) | The Azure region where this cluster will reside. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group that will contain the cluster. | `string` | n/a | yes |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | The ID of the route table of the subnet where the cluster will reside. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the cluster will reside. | `string` | n/a | yes |
| <a name="input_worker_node_os_disk_size_gb"></a> [worker\_node\_os\_disk\_size\_gb](#input\_worker\_node\_os\_disk\_size\_gb) | The size of the OS disk for the worker nodes in the default (system) node pool. | `number` | `48` | no |
| <a name="input_worker_node_os_disk_type"></a> [worker\_node\_os\_disk\_type](#input\_worker\_node\_os\_disk\_type) | The type of the OS disk for the worker nodes in the default (system) node pool. | `string` | `"Ephemeral"` | no |
| <a name="input_worker_node_ssh_public_key"></a> [worker\_node\_ssh\_public\_key](#input\_worker\_node\_ssh\_public\_key) | The public key that will be added to the authorized keys file on the worker nodes for SSH access. | `string` | n/a | yes |
| <a name="input_worker_node_vm_size"></a> [worker\_node\_vm\_size](#input\_worker\_node\_vm\_size) | The default VM size for the worker nodes in the default (system) node pool. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_current_kubernetes_version"></a> [current\_kubernetes\_version](#output\_current\_kubernetes\_version) | n/a |
<!-- END_TF_DOCS -->