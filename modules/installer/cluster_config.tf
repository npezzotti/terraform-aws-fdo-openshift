
resource "local_file" "private_key" {
  content         = tls_private_key.installer.private_key_pem
  filename        = "${path.module}/ssh_key"
  file_permission = "0600"
}

data "external" "cluster_outputs" {
  program = [
    "ssh",
    "-i",
    local_file.private_key.filename,
    "-o",
    "StrictHostKeyChecking=no",
    "ec2-user@${aws_instance.installer.public_ip}", <<BASH
    cat /opt/openshift-installer/cluster_outputs
  BASH
  ]

  depends_on = [aws_instance.installer]
}

resource "null_resource" "install_monitor" {
    connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.installer.public_ip
    private_key = tls_private_key.installer.private_key_pem
  }

  provisioner "file" {
    content     = file("${path.module}/scripts/cluster-ready.sh")
    destination = "/tmp/cluster-ready.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/cluster-ready.sh",
      "sudo /tmp/cluster-ready.sh",
    ]
  }

  depends_on = [ aws_iam_instance_profile.installer ]
}
