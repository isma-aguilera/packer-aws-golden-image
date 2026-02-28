variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where the AMI will be built and registered."
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type used during the build. t2.micro keeps costs minimal."
}

variable "ami_name_prefix" {
  type        = string
  default     = "ec2-golden-image"
  description = "Prefix for the resulting AMI name. Combined with OS and timestamp."
}

variable "org_name" {
  type        = string
  default     = "myorg"
  description = "Organization name used in tags and banners."
}

variable "environment" {
  type        = string
  default     = "base"
  description = "Target environment tag (base, staging, production)."

  validation {
    condition     = contains(["base", "staging", "production"], var.environment)
    error_message = "environment must be one of: base, staging, production."
  }
}

variable "encrypt_boot" {
  type        = bool
  default     = true
  description = "Whether to encrypt the AMI root volume. Always true in production."
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key ID for AMI encryption. Empty string uses the AWS-managed default key."
  sensitive   = true
}

variable "iam_instance_profile" {
  type        = string
  default     = "packer-instance-profile"
  description = "IAM instance profile attached to the build instance. Needs SSM permissions."
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC ID for the build instance. Empty uses the default VPC."
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Subnet ID for the build instance. Empty uses a default subnet."
}
