variable "region" {
  default = "australia-southeast1"
}

variable "cluster_name" {
  default = "tf-regional"
}

variable "master_version" {
  default = ""
}

variable "node_count" {
  default = 1
}

variable "tags" {
#  type    = "list"
  default = ["testing cluster", "poc"]
}

variable "network" {
  default = "default"
}

variable "subnetwork" {
  default = "default"
}

variable "project" {
#  default = "wx-poc-devops-chapter-dev"
  default = ""
}

#data "google_compute_zones" "available" {
#  region = var.region
#}
#
#data "google_container_engine_versions" "default" {
##  zone = element(data.google_compute_zones.available.names, 0)
##  provider       =
#  location        = "australia-southeast1"
##  version_prefix = "1.12."
#}

#data "google_container_engine_versions" "gke_versions" {}

resource "google_container_cluster" "default" {
  project            = var.project
  name               = var.cluster_name
  location           = var.region
  initial_node_count = var.node_count
  min_master_version = "1.23.12" #var.master_version != "" ? var.master_version : data.google_container_engine_versions.default.latest_master_version
  network            = var.network
  subnetwork         = var.subnetwork

  // Use legacy ABAC until these issues are resolved: 
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true

  node_config {
#    tags = [var.tags]
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloudkms",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.project}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  // Wait for the GCE LB controller to cleanup the resources.
#  provisioner "local-exec" {
#    when    = "destroy"
#    command = "sleep 90"
#  }
}

#output "instance_groups" {
#  value = google_container_cluster.default.instance_group_urls
#}

output "endpoint" {
  value = google_container_cluster.default.endpoint
}

output "client_certificate" {
  value = google_container_cluster.default.master_auth[0].client_certificate
}

output "client_key" {
  value = google_container_cluster.default.master_auth[0].client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.default.master_auth[0].cluster_ca_certificate
}
