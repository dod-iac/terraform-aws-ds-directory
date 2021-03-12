<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates a AWS Directory Service directory with logging to an encrypted log group in CloudWatch.  
The directory resource is configured to ignore changes to the password value.

```hcl
data "aws_ssm_parameter" "directory_password" {
  name = format("/app-%s-%s/directory-password", var.application, var.environment)
}

module "cloudwatch_kms_key" {
  source = "dod-iac/cloudwatch-kms-key/aws"

  name = format("alias/app-%s-cloudwatch-logs-%s", var.application, var.environment)

  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}

module "directory" {
  source = "dod-iac/ds-directory/aws"

  cloudwatch_kms_key_arn = module.cloudwatch_kms_key.aws_kms_key_arn
  description    = format("A MicrosoftAD Directory for use with %s application in the %s environment", var.application, var.environment)
  edition        = "Standard"
  name           = format("%s.%s", var.environment, var.application)
  password       = data.aws_ssm_parameter.directory_password.value
  short_name     = title(var.application)
  type           = "MicrosoftAD"
  vpc_id         = var.vpc_id
  vpc_subnet_ids = var.vpc_subnet_ids

  tags  = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_caller_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) |
| [aws_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) |
| [aws_cloudwatch_log_resource_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) |
| [aws_directory_service_directory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_directory) |
| [aws_directory_service_log_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/directory_service_log_subscription) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_partition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) |
| [aws_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloudwatch\_kms\_key\_arn | A KMS key used to encrypt Domain Controller security logs stored in CloudWatch Logs. | `string` | n/a | yes |
| description | A textual description for the directory.  Defaults to "short\_name (name)". | `string` | `""` | no |
| edition | If type is Microsoft AD, the edition, either Standard or Enterprise. | `string` | `"Standard"` | no |
| name | The fully qualified name for the directory, e.g., corp.example.com | `string` | n/a | yes |
| password | The password for the directory administrator or connector user. | `string` | n/a | yes |
| short\_name | The short name of the directory, e.g, CORP. | `string` | n/a | yes |
| tags | Tags applied to the directory and CloudWatch log group. | `map(string)` | `{}` | no |
| type | The directory type, either SimpleAD, ADConnector, or MicrosoftAD. | `string` | n/a | yes |
| vpc\_id | The identifier of the VPC that the directory is in. | `string` | n/a | yes |
| vpc\_subnet\_ids | The identifiers of the subnets for the directory servers (2 subnets in 2 different AZs). | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| directory\_id | The directory identifier. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
