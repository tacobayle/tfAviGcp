resource "google_compute_network" "vpc_network" {
  name = var.gcp.vpc.name
  project = var.gcp.project.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnetwork" {
  count = length(var.subnetworkName)
  name = element(var.subnetworkName, count.index)
  ip_cidr_range = element(var.subnetworkCidr, count.index)
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router" "router" {
  name = "my-router"
  region = var.gcp.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "my-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
