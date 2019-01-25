terraform {
  required_version = ">= 0.11.10"
}

provider "aws" {
  region = "us-west-2"
}

/*------------------------------------------------------------------------------
Build Vault cluster in AWS according to reference architecture using 
https://github.com/iainthegray/terraform-aws-vault. Use data resources to
pull default VPC, subnet, etc.
------------------------------------------------------------------------------*/
resource "random_id" "project_name" {
  byte_length = 3
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = "${data.aws_vpc.default_vpc.id}"
}

data "aws_subnet" "subnet" {
  count = "${length(data.aws_subnet_ids.subnets.ids)}"
  id    = "${data.aws_subnet_ids.subnets.ids[count.index]}"
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "aws_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "aws_ssh_key" {
  key_name   = "${random_id.project_name.hex}-ssh-key"
  public_key = "${tls_private_key.aws_ssh_key.public_key_openssh}"
}

resource "local_file" "private_key" {
    content     = "${tls_private_key.aws_ssh_key.private_key_pem}"
    filename = "${path.module}/private.pem"
}

module "terraform-aws-vault" {
  source              = "github.com/iainthegray/terraform-aws-vault"
  vpc_id              = "${data.aws_vpc.default_vpc.id}"
  availability_zones  = ["${data.aws_availability_zones.available.names.0}","${data.aws_availability_zones.available.names.1}","${data.aws_availability_zones.available.names.2}"]
  private_subnets     = ["${data.aws_subnet.subnet.0.id}","${data.aws_subnet.subnet.1.id}","${data.aws_subnet.subnet.2.id}"]
  cluster_name        = "${random_id.project_name.hex}"
  vault_ami_id        = "${data.aws_ami.ubuntu.id}"  
  consul_ami_id       = "${data.aws_ami.ubuntu.id}"  
  instance_type       = "m5.large"
  ssh_key_name        = "${aws_key_pair.aws_ssh_key.key_name}"
  consul_cluster_size = 5
#  use_userdata        = true
}
