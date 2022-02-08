data "template_file" "backend" {
  template = file(var.backend.userdata)
  vars = {
    url_demovip_server = var.backend.url_demovip_server
    username = var.backend.username
  }
}

resource "google_compute_instance" "backend" {
  count = var.backend.count
  name = "backend-${count.index + 1 }"
  machine_type = var.backend.type
  zone = element(data.google_compute_zones.available.names, count.index)
  boot_disk {
    initialize_params {
      image = var.backend.image
    }
  }
  metadata_startup_script =  data.template_file.backend.rendered
  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.1.id
    #access_config {
    #}
  }
  metadata  = {
    sshKeys = "ubuntu:${file(var.ssh_key.public)}"
  }
  labels = {
    group = "backend"
    created_by = "terraform"
  }
}