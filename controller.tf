# avi controller creation

resource "google_compute_instance" "aviController" {
  name = var.controller.name
  machine_type = var.controller.type
  zone = data.google_compute_zones.available.names[0]
  boot_disk {
    device_name = var.controller.diskName
    initialize_params {
    image = "projects/${var.gcp.project.name}/global/images/${var.controller.image_name}"
    type = var.controller.diskType
    size = var.controller.diskSize
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork.0.id
    access_config {
    }
  }
  metadata  = {
    sshKeys = "ubuntu:${file(var.ssh_key.public)}"
  }
  labels = {
    group = "controller"
    created_by = "terraform"
  }
  service_account {
  email = var.gcp.email
  scopes = ["cloud-platform"]
  }
}
