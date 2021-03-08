variable "cloudwatch_kms_key_arn" {
  type        = string
  description = "A KMS key used to encrypt Domain Controller security logs stored in CloudWatch Logs."
}

variable "description" {
  type        = string
  description = "A textual description for the directory.  Defaults to \"short_name (name)\"."
  default     = ""
}

variable "edition" {
  type        = string
  description = "If type is Microsoft AD, the edition, either Standard or Enterprise."
  default     = "Standard"
}

variable "name" {
  type        = string
  description = "The fully qualified name for the directory, e.g., corp.example.com"
}

variable "password" {
  type        = string
  description = "The password for the directory administrator or connector user."
}

variable "short_name" {
  type        = string
  description = "The short name of the directory, e.g, CORP."
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the directory and CloudWatch log group."
  default     = {}
}

variable "type" {
  type        = string
  description = "The directory type, either SimpleAD, ADConnector, or MicrosoftAD."
}

variable "vpc_id" {
  type        = string
  description = "The identifier of the VPC that the directory is in."
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "The identifiers of the subnets for the directory servers (2 subnets in 2 different AZs)."
}
