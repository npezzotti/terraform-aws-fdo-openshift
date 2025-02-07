resource "aws_instance" "worker_node" {
  count = 2

  ami                    = data.aws_ami.rhcos.id
  instance_type          = "m5a.large"
  iam_instance_profile   = aws_iam_instance_profile.worker.id
  vpc_security_group_ids = [aws_security_group.worker.id]
  subnet_id              = element(local.base_infra.vpc.private_subnets, count.index)

  user_data = jsonencode({
    ignition = {
      config = {
        replace = {
          source = "s3://${module.installer.s3_bucket_name}/worker.ign"
        }
      }
      version = "3.1.0"
    }
  })

  root_block_device {
    volume_size = 120
    volume_type = "gp2"
  }

  tags = merge(local.tags, {
    "kubernetes.io/cluster/${module.installer.infra_id}" = "shared"
  })
}

resource "aws_security_group" "worker" {
  name        = "${module.installer.cluster_name}-worker-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = local.base_infra.vpc.vpc_id

  tags = {
    Name = "${module.installer.cluster_name}-worker-sg"
  }
}

resource "aws_security_group_rule" "worker_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id

  protocol    = "icmp"
  cidr_blocks = [local.base_infra.vpc.vpc_cidr_block]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "worker_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.worker.id

  protocol    = "tcp"
  cidr_blocks = [local.base_infra.vpc.vpc_cidr_block]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "worker_ingress_vxlan" {
  description              = "Vxlan packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 4789
  to_port                  = 4789
}

resource "aws_security_group_rule" "worker_ingress_master_vxlan" {
  description              = "Vxlan packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 4789
  to_port                  = 4789
}

resource "aws_security_group_rule" "worker_ingress_geneve" {
  description              = "Geneve packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 6081
  to_port                  = 6081
}

resource "aws_security_group_rule" "worker_ingress_master_geneve" {
  description              = "Geneve packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 6081
  to_port                  = 6081
}

resource "aws_security_group_rule" "worker_ingress_ipsec_ike" {
  description              = "IPsec IKE packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 500
  to_port                  = 500
}

resource "aws_security_group_rule" "worker_ingress_ipsec_nat_t" {
  description              = "IPsec NAT-T packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 4500
  to_port                  = 4500
}

resource "aws_security_group_rule" "worker_ingress_ipsec_esp" {
  description              = "IPsec ESP packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "50"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_master_ipsec_ike" {
  description              = "IPsec IKE packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 500
  to_port                  = 500
}

resource "aws_security_group_rule" "worker_ingress_master_ipsec_nat_t" {
  description              = "IPsec NAT-T packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 4500
  to_port                  = 4500
}

resource "aws_security_group_rule" "worker_ingress_master_ipsec_esp" {
  description              = "IPsec ESP packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "50"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "worker_ingress_internal" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "tcp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_master_internal" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "tcp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "worker_ingress_internal_udp" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_master_internal_udp" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "worker_ingress_kube" {
  description              = "Kubernetes kubelet, scheduler and controller manager"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10259
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_worker_kube" {
  description              = "Kubernetes kubelet, scheduler and controller manager"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10259
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "worker_ingress_ingress_services" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "tcp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_master_ingress_services" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "tcp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "worker_ingress_ingress_services_udp" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "worker_ingress_master_ingress_services_udp" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.worker.id
  protocol                 = "udp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "worker_egress" {
  type              = "egress"
  security_group_id = aws_security_group.worker.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_iam_instance_profile" "worker" {
  name = "${module.installer.cluster_name}-worker-profile"
  role = aws_iam_role.worker_role.name
}

resource "aws_iam_role" "worker_role" {
  name = "${module.installer.cluster_name}-worker-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.${data.aws_partition.current.dns_suffix}"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = merge({
    "Name" = "${module.installer.cluster_name}-worker-role"
    }, local.tags,
  )
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "${module.installer.infra_id}-worker-policy"
  role = aws_iam_role.worker_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "s3:GetObject" #
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}
