### VPC ###
resource "aws_vpc" "tf_test" {
  cidr_block = "172.31.0.0/16"
  
  lifecycle {
    ignore_changes = [ tags_all, tags]
  }
}

resource "aws_customer_gateway" "default" {
  bgp_asn    = 65000
  ip_address = "172.0.0.1"
  type       = "ipsec.1"

#  provisioner "local-exec" {
#     command = "c2-ec2 CreateVpnConnection CustomerGatewayId ${aws_customer_gateway.default.id} Type ${aws_customer_gateway.default.type} VpnGatewayId ${resource.aws_vpc.tf_test.id} Options.TunnelOptions.0.TunnelInsideCidr '169.254.252.0/30'"
#     when = create
#  }
#
#  provisioner "local-exec" {
#      command = "c2-ec2 DescribeVpnConnections Filter.1.Name customer-gateway-id Filter.1.Value.1 ${self.id} | grep vpnConnectionId | egrep -o 'vpn-[A-Z0-9]+' | while read line; do c2-ec2 DeleteVpnConnection VpnConnectionId $line; done"
#      when = destroy
#  }
}

resource "aws_ec2_tag" "tf_test_vpc" {
  resource_id = resource.aws_vpc.tf_test.id
  key         = "Name"
  value       = "tf_test"
}


### Subnets ###
resource "aws_subnet" "subnet1" {
  vpc_id            = resource.aws_vpc.tf_test.id
  cidr_block        = "172.31.16.0/20"
  availability_zone = "ru-msk-comp1p"
  lifecycle {
    ignore_changes = [ tags_all, tags]
  }
}

### SG ###
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound connections"
  vpc_id      = resource.aws_vpc.tf_test.id

  ingress {
    description = "SSH inbound"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_ssh"
  }
  lifecycle {
    ignore_changes = [ tags_all, tags]
  }
}

### EC2 Instances ###
resource "aws_instance" "test_1" {
  tags = {
    Name = "test_1"
  }
  ami                         = "cmi-0E29FB61"                  # AlmaLinux 8.5 [Cloud Image]
  instance_type               = "c5.large"
  subnet_id                   = resource.aws_subnet.subnet1.id
  monitoring                  = true
  source_dest_check           = true
  key_name                    = "gmelnikov"
  private_ip                  = "172.31.16.122"
  associate_public_ip_address = false
  root_block_device {
    volume_size = 32
    volume_type = "gp2"
    tags = {
        Name = "pepka test"
    }
  }

  security_groups = [
    aws_security_group.allow_ssh.id
  ]

  lifecycle {
    ignore_changes = [
      security_groups,
      associate_public_ip_address,
      tags_all,
      tags
    ]
  }
}
