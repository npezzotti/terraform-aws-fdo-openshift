resource "aws_instance" "control_plane" {
  count = 3

  ami                    = data.aws_ami.rhcos.id
  instance_type          = "m5a.xlarge"
  iam_instance_profile   = aws_iam_instance_profile.master.id
  subnet_id              = element(local.base_infra.vpc.private_subnets, count.index)
  vpc_security_group_ids = [aws_security_group.master.id]

  user_data = jsonencode({
    ignition = {
      config = {
        replace = {
          source = "s3://${module.installer.s3_bucket_name}/master.ign"
        }
      }
      version = "3.1.0"
    }
  })

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_size = 120
    volume_type = "gp2"
  }

  tags = merge(local.tags, {
    "kubernetes.io/cluster/${module.installer.infra_id}" = "shared"
  })
}

resource "aws_lb_target_group_attachment" "master_external_api" {
  count = 3

  target_group_arn = aws_lb_target_group.external_api.arn
  target_id        = aws_instance.control_plane[count.index].private_ip
}

resource "aws_lb_target_group_attachment" "master_internal_api" {
  count = 3

  target_group_arn = aws_lb_target_group.internal_api.arn
  target_id        = aws_instance.control_plane[count.index].private_ip
}

resource "aws_lb_target_group_attachment" "master_internal_service" {
  count = 3

  target_group_arn = aws_lb_target_group.internal_service.arn
  target_id        = aws_instance.control_plane[count.index].private_ip
}

resource "aws_security_group" "master" {
  name        = "${module.installer.cluster_name}-master-sg"
  description = "Allow required traffic to bootstrap node"
  vpc_id      = local.base_infra.vpc.vpc_id

  tags = {
    Name = "${module.installer.cluster_name}-master-sg"
  }
}

resource "aws_security_group_rule" "master_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id

  protocol    = "icmp"
  cidr_blocks = [local.base_infra.vpc.vpc_cidr_block]
  from_port   = 0
  to_port     = 0
}

resource "aws_security_group_rule" "master_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id

  protocol    = "tcp"
  cidr_blocks = [local.base_infra.vpc.vpc_cidr_block]
  from_port   = 22
  to_port     = 22
}

resource "aws_security_group_rule" "master_k8s_api" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id

  protocol    = "tcp"
  cidr_blocks = [local.base_infra.vpc.vpc_cidr_block]
  from_port   = 6443
  to_port     = 6443
}

resource "aws_security_group_rule" "master_services" {
  type              = "ingress"
  security_group_id = aws_security_group.master.id

  protocol    = "tcp"
  cidr_blocks = [local.base_infra.vpc.vpc_cidr_block]
  from_port   = 22623
  to_port     = 22623
}

resource "aws_security_group_rule" "master_ingress_etcd" {
  description              = "etcd"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 2379
  to_port                  = 2380
}

resource "aws_security_group_rule" "master_ingress_vxlan" {
  description              = "Vxlan packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 4789
  to_port                  = 4789
}

resource "aws_security_group_rule" "master_ingress_worker_vxlan" {
  description              = "Vxlan packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 4789
  to_port                  = 4789
}

resource "aws_security_group_rule" "master_ingress_geneve" {
  description              = "Geneve packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 6081
  to_port                  = 6081
}

resource "aws_security_group_rule" "master_ingress_worker_geneve" {
  description              = "Geneve packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 6081
  to_port                  = 6081
}

resource "aws_security_group_rule" "master_ingress_ipsec_ike" {
  description              = "IPsec IKE packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 500
  to_port                  = 500
}

resource "aws_security_group_rule" "master_ingress_ipsec_nat_t" {
  description              = "IPsec NAT-T packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.master.id
  from_port                = 4500
  to_port                  = 4500
}

resource "aws_security_group_rule" "master_ingress_ipsec_esp" {
  description              = "IPsec ESP packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "50"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_worker_ipsec_ike" {
  description              = "IPsec IKE packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 500
  to_port                  = 500
}

resource "aws_security_group_rule" "master_ingress_worker_ipsec_nat_t" {
  description              = "IPsec NAT-T packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  source_security_group_id = aws_security_group.worker.id
  from_port                = 4500
  to_port                  = 4500
}

resource "aws_security_group_rule" "master_ingress_worker_ipsec_esp" {
  description              = "IPsec ESP packets"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "50"
  from_port                = -1
  to_port                  = -1
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "master_ingress_internal" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_worker_internal" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "master_ingress_internal_udp" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_worker_internal_udp" {
  description              = "Internal cluster communication"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  from_port                = 9000
  to_port                  = 9999
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "master_ingress_kube" {
  description              = "Kubernetes kubelet, scheduler and controller manager"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10259
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_worker_kube" {
  description              = "Kubernetes kubelet, scheduler and controller manager"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  from_port                = 10250
  to_port                  = 10259
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "master_ingress_ingress_services" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_worker_ingress_services" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "tcp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "master_ingress_ingress_services_udp" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.master.id
}

resource "aws_security_group_rule" "master_ingress_worker_ingress_services_udp" {
  description              = "Kubernetes ingress services"
  type                     = "ingress"
  security_group_id        = aws_security_group.master.id
  protocol                 = "udp"
  from_port                = 30000
  to_port                  = 32767
  source_security_group_id = aws_security_group.worker.id
}

resource "aws_security_group_rule" "master_egress" {
  type              = "egress"
  security_group_id = aws_security_group.master.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_iam_instance_profile" "master" {
  name = "${module.installer.cluster_name}-master-profile"
  role = aws_iam_role.master_role.name
}

resource "aws_iam_role" "master_role" {
  name = "${module.installer.cluster_name}-master-role"
  path = "/"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = "sts:AssumeRole",
        "Principal" = {
          "Service" = "ec2.${data.aws_partition.current.dns_suffix}"
        },
        "Effect" = "Allow",
        "Sid"    = ""
      }
    ]
  })

  tags = merge({
    "Name" = "${module.installer.cluster_name}-master-role"
    }, local.tags,
  )
}

resource "aws_iam_role_policy" "master_policy" {
  name = "${module.installer.cluster_name}-master-policy"
  role = aws_iam_role.master_role.id

  policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = [
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVolume",
          "ec2:Describe*",
          "ec2:DetachVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "ec2:RevokeSecurityGroupIngress",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:AttachLoadBalancerToSubnets",
          "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancerPolicy",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancerListeners",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:DetachLoadBalancerFromSubnets",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
          "kms:DescribeKey",
          "s3:GetObject" # 
        ],
        "Resource" = "*",
        "Effect"   = "Allow"
      }
    ]
  })
}
