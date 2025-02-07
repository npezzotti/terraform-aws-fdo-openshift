resource "aws_instance" "bootstrap" {
  ami                         = data.aws_ami.rhcos.id
  instance_type               = "m5a.xlarge"
  vpc_security_group_ids      = [aws_security_group.bootstrap.id, aws_security_group.master.id]
  tags                        = local.tags
  subnet_id                   = element(local.base_infra.vpc.public_subnets, 0)
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bootstrap.id


  root_block_device {
    volume_size = 100
  }

  user_data = jsonencode({
    ignition = {
      config = {
        replace = {
          source = "s3://${module.installer.s3_bucket_name}/bootstrap.ign"
        }
      }
      version = "3.1.0"
    }
  })
}

resource "aws_security_group" "bootstrap" {
  name        = "${module.installer.infra_id}-bootstrap-sg"
  description = "Allow required traffic to bootstrap node"
  vpc_id      = local.base_infra.vpc.vpc_id

  tags = {
    Name = "${module.installer.cluster_name}-bootstrap-sg"
  }
}

resource "aws_security_group_rule" "bootstrap_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.bootstrap.id
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
}

resource "aws_security_group_rule" "bootstrap_journald_gateway" {
  type              = "ingress"
  security_group_id = aws_security_group.bootstrap.id
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 19531
  to_port           = 19531
}

resource "aws_security_group_rule" "bootstrap_egress" {
  type              = "egress"
  security_group_id = aws_security_group.bootstrap.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb_target_group_attachment" "bootstrap_external_api" {
  target_group_arn = aws_lb_target_group.external_api.arn
  target_id        = aws_instance.bootstrap.private_ip
}

resource "aws_lb_target_group_attachment" "bootstrap_internal_api" {
  target_group_arn = aws_lb_target_group.internal_api.arn
  target_id        = aws_instance.bootstrap.private_ip
}

resource "aws_lb_target_group_attachment" "bootstrap_internal_service" {
  target_group_arn = aws_lb_target_group.internal_service.arn
  target_id        = aws_instance.bootstrap.private_ip
}

resource "aws_iam_instance_profile" "bootstrap" {
  name = "${module.installer.cluster_name}-bootstrap-profile"
  role = aws_iam_role.bootstrap_role.name
}

resource "aws_iam_role" "bootstrap_role" {
  name = "${module.installer.cluster_name}-bootstrap-role"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.${data.aws_partition.current.dns_suffix}"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = merge({
    "Name" = "${module.installer.cluster_name}-bootstrap-role"
    }, local.tags,
  )
}

resource "aws_iam_role_policy" "bootstrap_policy" {
  name = "${module.installer.infra_id}-bootstrap-policy"
  role = aws_iam_role.bootstrap_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      "Action" = [
        "ec2:Describe*",
        "ec2:AttachVolume",
        "ec2:DetachVolume",
        "s3:GetObject"
      ],
      Resource = "*",
      Effect   = "Allow"
      }
    ]
  })
}

data "aws_iam_policy" "bootstrap_ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "bootstrap_ssm" {
  role       = aws_iam_role.bootstrap_role.name
  policy_arn = data.aws_iam_policy.bootstrap_ssm.arn
}
