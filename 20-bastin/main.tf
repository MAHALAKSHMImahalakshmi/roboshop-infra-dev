resource "aws_instance" "bastin" {
  // in order get ami_id used datasouce 
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance refer from datasorce
  //ami = data.aws_ami.joindevops
 // in local.tf --> data.aws_ami.joindevops
  ami = local.ami_id
  
  instance_type = "t3.micro"
// create security group for instances
  vpc_security_group_ids = [local.bastin_sg_id] // in list 
  subnet_id =  local.public_subnet_id  
// what about subnet ?

 # need more space for terraform
  root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
  }
  # user_data = file("bastion.sh")
   tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-bastion"
    }
  )
}