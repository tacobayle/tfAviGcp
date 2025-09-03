

# Jump server creation

data "template_file" "jump" {
  template = file(var.jump.userdata)
  vars = {
    avisdkVersion = var.jump.avisdkVersion
    ansibleVersion = var.ansible.version
    ansiblePrefixGroup = var.ansible.prefixGroup
    ssh_private_key = basename(var.ssh_key.private)
    username = var.jump.username
    ansibleGcpServiceAccount = var.ansible.gcpServiceAccount
    googleProject = var.gcp.project.name
  }
}

resource "google_compute_instance" "jump" {
  name = var.jump.name
  machine_type = var.jump.type
  zone = data.google_compute_zones.available.names[0]
  boot_disk {
    initialize_params {
      image = var.jump.image
    }
  }
  metadata_startup_script =  data.template_file.jump.rendered
  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.0.id
    access_config {
    }
  }
  metadata  = {
    sshKeys = "ubuntu:${file(var.ssh_key.public)}"
  }
  labels = {
    group = "jump"
    created_by = "terraform"
  }
  service_account {
    email = var.gcp.email
    scopes = ["cloud-platform"]
  }

  connection {
    host        = self.network_interface.0.access_config.0.nat_ip
    type        = "ssh"
    agent       = false
    user        = var.jump.username
    private_key = file(var.ssh_key.private)
  }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }

  # to copy  ansible directory

  provisioner "file" {
    source      = var.ssh_key.private
    destination = "/home/${var.jump.username}/.ssh/${basename(var.ssh_key.private)}"
  }

  provisioner "file" {
    source      = var.ansible.gcpServiceAccount
    destination = "/opt/ansible/inventory/${basename(var.ansible.gcpServiceAccount)}"
  }

  provisioner "file" {
    content = data.template_file.controllerPrivateIp.rendered
    destination = "/home/${var.jump.username}/controllerPrivateIp.yml"
  }

//  provisioner "remote-exec" {
//    inline      = [
//      "chmod 600 ${var.privateKey}",
//      "cd ~/ansible ; git clone https://github.com/tacobayle/ansibleGcpStorageImage ; ansible-playbook ansibleGcpStorageImage/local.yml --extra-vars '{\"bucketAvi\": ${jsonencode(var.gcp.bucket.name)}, \"googleEmail\": ${jsonencode(var.gcp.email)}, \"googleProject\": ${jsonencode(var.gcp.project.name)}}'",
//    ]
//  }
}