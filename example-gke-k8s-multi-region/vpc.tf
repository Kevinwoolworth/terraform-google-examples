resource "google_compute_network" "default" {
  project                 = local.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "region1" {
  project       = local.project_id
  name          = "${var.network_name}-subnet"
  ip_cidr_range = local.region1_cidr
  network       = google_compute_network.default.self_link
  region        = local.region1
}

resource "google_compute_subnetwork" "region2" {
  project       = local.project_id
  name          = "${var.network_name}-subnet"
  ip_cidr_range = local.region2_cidr
  network       = google_compute_network.default.self_link
  region        = local.region2
}
