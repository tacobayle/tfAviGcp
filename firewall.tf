resource "google_compute_firewall" "sg" {
  name = var.gcp.sgName
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = var.sgTcp
  }

  allow {
    protocol = "udp"
    ports    = var.sgUdp
  }

  source_ranges = ["0.0.0.0/0"]

}
