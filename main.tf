/**
 * ## Usage
 *
 * Creates a AWS Directory Service directory with logging to an encrypted log group in CloudWatch.
 * The directory resource is configured to ignore changes to the password value.
 *
 * ```hcl
 * data "aws_ssm_parameter" "directory_password" {
 *   name = format("/app-%s-%s/directory-password", var.application, var.environment)
 * }
 *
 * module "cloudwatch_kms_key" {
 *   source = "dod-iac/cloudwatch-kms-key/aws"
 *
 *   name = format("alias/app-%s-cloudwatch-logs-%s", var.application, var.environment)
 *
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 *
 * module "directory" {
 *   source = "dod-iac/ds-directory/aws"
 *
 *   cloudwatch_kms_key_arn = module.cloudwatch_kms_key.aws_kms_key_arn
 *   description    = format("A MicrosoftAD Directory for use with %s application in the %s environment", var.application, var.environment)
 *   edition        = "Standard"
 *   name           = format("%s.%s", var.environment, var.application)
 *   password       = data.aws_ssm_parameter.directory_password.value
 *   short_name     = title(var.application)
 *   type           = "MicrosoftAD"
 *   vpc_id         = var.vpc_id
 *   vpc_subnet_ids = var.vpc_subnet_ids
 *
 *   tags  = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to master branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

#
# Directory Service
#

resource "aws_directory_service_directory" "main" {
  edition     = var.edition
  description = length(var.description) > 0 ? var.description : format("%s (%s)", var.short_name, var.name)
  name        = var.name
  password    = var.password
  short_name  = var.short_name
  tags        = var.tags
  type        = var.type

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = var.vpc_subnet_ids
  }

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

#
# CloudWatch
#

resource "aws_cloudwatch_log_group" "main" {
  name       = format("/aws/directoryservice/%s", var.name)
  kms_key_id = var.cloudwatch_kms_key_arn
  tags       = var.tags
}

data "aws_iam_policy_document" "directory_service_cloudwatch_policy" {
  statement {
    sid = "CreateCloudWatchLogStreamsAndPutLogEvents"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    principals {
      identifiers = ["ds.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
    resources = [
      format(
        "arn:%s:logs:%s:%s:log-group:%s:log-stream:*",
        data.aws_partition.current.partition,
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
        aws_cloudwatch_log_group.main.name,
      )
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "directory_service" {
  policy_document = data.aws_iam_policy_document.directory_service_cloudwatch_policy.json
  policy_name     = aws_cloudwatch_log_group.main.name
}

resource "aws_directory_service_log_subscription" "main" {
  directory_id   = aws_directory_service_directory.main.id
  log_group_name = aws_cloudwatch_log_group.main.name
}
