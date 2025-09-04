data "aws_ami" "joindevops" {
  owners           = ["973714476881"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "ami_id" {
  value       = data.aws_ami.joindevops.id
}

data "aws_ssm_parameter" "bastin_sg_id" {
  name  = "/${var.project}/${var.environment}/bastin_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project}/${var.environment}/public_subnet_ids"
}
// chttps://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance refer from datasorce
// to get ami_i for aws instances