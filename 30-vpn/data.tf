# Variable: put the Marketplace product code for BYOL here
# Tip: after subscribing, you can see the product code in the EC2 console AMI details
# or via `aws ec2 describe-images` for your region.
variable "openvpn_byol_product_code" {
  type        = string
  description = "AWS Marketplace product code for OpenVPN Access Server BYOL"
}

data "aws_ami" "openvpn" {
  owners      = ["aws-marketplace"] # a.k.a. 679593333241
  most_recent = true

  filter {
    name   = "product-code"
    values = [var.openvpn_byol_product_code]
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

output "openvpn_byol_ami_id" {
  value = data.aws_ami.openvpn.id
}

data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/${var.project}/${var.environment}/vpn_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project}/${var.environment}/public_subnet_ids"
}