source "amazon-ebs" "al2023" {
  region        = var.aws_region
  instance_type = var.instance_type


  source_ami_filter {
    filters = {
      name                = "al2023-ami-2023.*-x86_64"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  # SSH communicator — connects as ec2-user with a temporary key pair.
  # Packer creates and destroys the key pair automatically.
  communicator = "ssh"
  ssh_username = "ec2-user"

  # Attach the instance profile so SSM Agent can connect (and for CW agent later)
  iam_instance_profile = var.iam_instance_profile

  # IMDSv2 only — prevents SSRF attacks from reaching the metadata service
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Encrypt the resulting AMI root volume
  encrypt_boot = var.encrypt_boot
  kms_key_id   = var.kms_key_id != "" ? var.kms_key_id : null

  # Root volume: 20 GiB gp3, encrypted, deleted when the build instance terminates
  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = 20
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # Optional: place the build instance in a specific VPC/subnet
  vpc_id    = var.vpc_id != "" ? var.vpc_id : null
  subnet_id = var.subnet_id != "" ? var.subnet_id : null

  ami_name        = local.ami_name
  ami_description = "Golden Image — Amazon Linux 2023 — CIS Level 1 Hardened — ${local.timestamp}"

  tags     = local.common_tags
  run_tags = local.common_tags
}
