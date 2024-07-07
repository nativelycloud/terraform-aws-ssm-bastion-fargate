# AWS Bastion with SSM on ECS Fargate
This Terraform module deploys a bastion service on ECS Fargate for use with AWS Systems Manager Session Manager to securely port-forward into a VPC from the Internet.

Although designed for seamless use with our [terraform-aws-ssm-tunnel](https://github.com/nativelycloud/terraform-aws-ssm-tunnel) module to enable provisioning of VPC resources (RDS, ES, etc) directly from your Terraform code, it can be used standalone with the AWS CLI as well.

### Features
- Deploys an ECS Cluster, Service, and Task Definition with required least-privilege IAM permissions for the bastion to run, inside your VPC
- Creates a default security group allowing all outbound traffic (can be disabled if you want to provide your own)
- Supports all TCP port forwarding use cases through AWS SSM Session Manager
- Auto-healing if the bastion task fails or if there are underlying infrastructure issues
- Customizable CPU and memory allocation for the Fargate task
- Optionally assign a public IP to the bastion task if you don't have a NAT gateway or SSM & ECR VPC endpoints
- Optionally run multiple concurrent instances of the bastion task for high availability

### Comparisons
**SSM Session Manager advantages over traditional SSH bastions**
- **Simpler setup** — No need to manage keys and user access manually, authn is handled natively in IAM next to your existing access controls
- **Better security** — no need to open inbound ports from the Internet or whitelist IP addresses as communication is relayed through the AWS SSM service

**Advantages using SSM Session Manager on Fargate versus an EC2 instance**
- **Set it and forget it** — there are no stateful components, so no EC2 lifecycle to manage, no auto-scaling group to configure, no OS to patch, no instance to monitor, no storage to back up, etc.
- **Better security** — smaller attack surface: no SSH daemon, no OS to exploit, more layers of the stack are managed by AWS
- **Built-in High Availability** — the ECS service is self-healing as any issue will cause the taks to be redeployed and several instances can optionally across multiple Availability Zones
- **Cost-effective** — the cost is roughly the same as in EC2, with all the added benefits above.

### Costs
In the default configuration, in `eu-west-1` and as of this writing, the costs are:
| Resource | Cost | Estimated monthly cost |
| --- | --- | --- |
| Fargate Task (0.25 vCPU, 0.5 GB) | $0.009875 per hour | $7.21 |

**Estimated total**: $7.21 per month

### Upcoming features
- ARM support
- Fargate Spot support
- IPv6 support (dualstack and IPv6-only)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.task_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_iam_policy_document.task_ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Whether to assign a public IP to the bastion task. If false, you will need a NAT gateway or at least SSM & ECR VPC endpoints | `bool` | `false` | no |
| <a name="input_create_default_security_group"></a> [create\_default\_security\_group](#input\_create\_default\_security\_group) | Whether to create a default security group allowing all outbound traffic for the bastion task. If false, you will need to provide your own in `security_groups` | `bool` | `true` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the bastion task to run | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | n/a | `list(string)` | `[]` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | Number of CPU units to allocate for the bastion task | `number` | `256` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Amount of memory (in MiB) to allocate for the bastion task | `number` | `512` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_security_group_id"></a> [default\_security\_group\_id](#output\_default\_security\_group\_id) | The ID of the default security group created for the bastion task |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | The name of the ECS cluster where the bastion task is running |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | The name of the ECS service running the bastion task |
<!-- END_TF_DOCS -->