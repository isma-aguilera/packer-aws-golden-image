# Rol IAM asumido por la instancia EC2 durante el build de Packer
resource "aws_iam_role" "packer_instance" {
  name = "packer-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Política inline: acceso a SSM para conectividad sin puerto 22
resource "aws_iam_role_policy" "packer_instance" {
  name   = "packer-instance-policy"
  role   = aws_iam_role.packer_instance.id
  policy = file("${path.module}/../iam/packer-instance-profile-policy.json")
}

# Instance profile que referencia el rol — usado en sources.pkr.hcl
resource "aws_iam_instance_profile" "packer" {
  name = "packer-instance-profile"
  role = aws_iam_role.packer_instance.name
}

# Managed policy para el usuario/rol que ejecuta Packer localmente
resource "aws_iam_policy" "packer_build" {
  name   = "packer-build-policy"
  policy = file("${path.module}/../iam/packer-build-policy.json")
}
