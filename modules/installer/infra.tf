
data "aws_ami" "rhel9" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9*_HVM-*-Hourly2-GP3"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"]
}

resource "aws_instance" "installer" {
  ami                    = data.aws_ami.rhel9.id
  instance_type          = "t2.micro"
  subnet_id              = element(local.base_infra.vpc.public_subnets, 0)
  iam_instance_profile   = aws_iam_instance_profile.installer.id
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.installer.id]

  tags = {
    Name = "${random_pet.cluster_name.id}-installer"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = tls_private_key.installer.private_key_pem
  }

  provisioner "file" {
    content     = local.user_data
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/setup.sh",
      "sudo /tmp/setup.sh",
    ]
  }

  # provisioner "remote-exec" {
  #   when = destroy
  #   inline = [ "/opt/openshift-installer/openshift-install destroy cluster --dir /opt/openshift-installer/clusterconfig --log-level info" ]
  # }
}

resource "aws_security_group" "installer" {
  name        = "Installer SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = local.base_infra.vpc.vpc_id

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.installer.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.installer.id
  cidr_ipv6         = "::/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.installer.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  security_group_id = aws_security_group.installer.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "tls_private_key" "installer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "${random_pet.cluster_name.id}-installer-key-pair"
  public_key = tls_private_key.installer.public_key_openssh
}

resource "aws_iam_instance_profile" "installer" {
  name = "${random_pet.cluster_name.id}-installer-profile"
  role = aws_iam_role.installer.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "installer" {
  name               = "${random_pet.cluster_name.id}-installer-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.installer.name
  policy_arn = data.aws_iam_policy.admin.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.installer.name
  policy_arn = data.aws_iam_policy.ssm.arn
}
