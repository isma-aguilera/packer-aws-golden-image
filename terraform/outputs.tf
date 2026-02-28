output "instance_profile_name" {
  description = "Nombre del instance profile"
  value       = aws_iam_instance_profile.packer.name
}

output "packer_build_policy_arn" {
  description = "ARN de la build policy"
  value       = aws_iam_policy.packer_build.arn
}
