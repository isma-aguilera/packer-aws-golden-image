locals {
  timestamp = formatdate("YYYYMMDD-hhmm", timestamp())

  ami_name = "${var.ami_name_prefix}-al2023-${local.timestamp}"

  common_tags = {
    Name        = local.ami_name
    OS          = "Amazon Linux 2023"
    BuildDate   = local.timestamp
    ManagedBy   = "Packer"
    Org         = var.org_name
    Environment = var.environment
    CISLevel    = "1"
    Hardened    = "true"
  }
}
