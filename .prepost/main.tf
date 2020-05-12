variable "flavor_name" {}

variable "key_pair_name" {}

variable "network_name" {}

variable "private_key_path" {
  default = "~/.ssh/id_rsa"
}

resource "openstack_compute_instance_v2" "gem5-sandbox" {
  name            = "gem5-sandbox"
  image_name      = "Ubuntu18.04_LTS"
  flavor_name     = var.flavor_name
  key_pair        = var.key_pair_name
  security_groups = ["default", "default_ext"]

  network {
    name = var.network_name
  }
}

resource "openstack_networking_floatingip_v2" "gem5-sandbox" {
  pool = "external"
}

resource "openstack_compute_floatingip_associate_v2" "gem5-sandbox" {
  floating_ip = openstack_networking_floatingip_v2.gem5-sandbox.address
  instance_id = openstack_compute_instance_v2.gem5-sandbox.id
}

resource "null_resource" "gem5-sandbox" {
  triggers = {
    trigger = openstack_compute_floatingip_associate_v2.gem5-sandbox.id
  }

  provisioner "remote-exec" {
    connection {
      host        = openstack_networking_floatingip_v2.gem5-sandbox.address
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }

    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "curl releases.rancher.com/install-docker/19.03.sh | bash",
      "sudo usermod -a -G docker ubuntu",
      "sudo docker pull mcapuccini/gem5-sandbox"
    ]

  }
  
}

output "floating_ip" {
  value = openstack_networking_floatingip_v2.gem5-sandbox.address
}