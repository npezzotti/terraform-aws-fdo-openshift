# tfe-fdo-kubernetes

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.tfe](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.tfe](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.docker_registry](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_hostname"></a> [db\_hostname](#input\_db\_hostname) | n/a | `string` | n/a | yes |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | n/a | `string` | n/a | yes |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | n/a | `string` | n/a | yes |
| <a name="input_db_user"></a> [db\_user](#input\_db\_user) | n/a | `string` | n/a | yes |
| <a name="input_docker_registry"></a> [docker\_registry](#input\_docker\_registry) | n/a | `string` | n/a | yes |
| <a name="input_docker_registry_username"></a> [docker\_registry\_username](#input\_docker\_registry\_username) | n/a | `string` | n/a | yes |
| <a name="input_encryption_password"></a> [encryption\_password](#input\_encryption\_password) | n/a | `string` | `"SUPERSECRET"` | no |
| <a name="input_helm_chart_version"></a> [helm\_chart\_version](#input\_helm\_chart\_version) | n/a | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | n/a | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The ID of the KMS key to use for TFE Object Storage | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | n/a | `string` | `"terraform-enterprise"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | n/a | `number` | n/a | yes |
| <a name="input_redis_host"></a> [redis\_host](#input\_redis\_host) | n/a | `string` | n/a | yes |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | n/a | `string` | n/a | yes |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | n/a | `string` | n/a | yes |
| <a name="input_redis_use_auth"></a> [redis\_use\_auth](#input\_redis\_use\_auth) | n/a | `bool` | `true` | no |
| <a name="input_redis_use_tls"></a> [redis\_use\_tls](#input\_redis\_use\_tls) | n/a | `bool` | `true` | no |
| <a name="input_redis_user"></a> [redis\_user](#input\_redis\_user) | n/a | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-1"` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | n/a | `string` | n/a | yes |
| <a name="input_service_annotations"></a> [service\_annotations](#input\_service\_annotations) | n/a | `map(string)` | `{}` | no |
| <a name="input_tag"></a> [tag](#input\_tag) | n/a | `string` | n/a | yes |
| <a name="input_tfe_hostname"></a> [tfe\_hostname](#input\_tfe\_hostname) | n/a | `string` | n/a | yes |
| <a name="input_tfe_iact_subnets"></a> [tfe\_iact\_subnets](#input\_tfe\_iact\_subnets) | n/a | `string` | `""` | no |
| <a name="input_tfe_license"></a> [tfe\_license](#input\_tfe\_license) | n/a | `string` | n/a | yes |
| <a name="input_tls_ca_cert"></a> [tls\_ca\_cert](#input\_tls\_ca\_cert) | n/a | `string` | n/a | yes |
| <a name="input_tls_cert"></a> [tls\_cert](#input\_tls\_cert) | n/a | `string` | n/a | yes |
| <a name="input_tls_cert_key"></a> [tls\_cert\_key](#input\_tls\_cert\_key) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tfe_namespace_id"></a> [tfe\_namespace\_id](#output\_tfe\_namespace\_id) | The ID of the Terraform Enterprise namespace |
<!-- END_TF_DOCS -->