resource "aws_instance" "ec2" {
    ami = var.ami
    instance_type = var.instance_type
    vpc_security_group_ids = var.security_group_ids
    user_data = var.user_data
    subnet_id = var.subnet_id
    iam_instance_profile = var.iam_instance_profile
    associate_public_ip_address = var.associate_public_ip_address
}