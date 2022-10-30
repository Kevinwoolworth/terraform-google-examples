variable "region1_cluster_name" {
  default = "tf-region1"
}

variable "region2_cluster_name" {
  default = "tf-region2"
}

variable "region1" {
  default = "australia-southeast1" # Sydney
}

variable "region2" {
  default = "australia-southeast2" # Melbourne
}

variable "network_name" {
  default = "tf-gke-multi-region"
}

provider "google" {
  region = var.region1
}

locals {
  project_id = "gcp-wow-rwds-admin-01-dev" #"wx-poc-devops-chapter-dev"
  region2 = "australia-southeast2" # Melbourne
  region1 = "australia-southeast1" # Sydney
  region1_cidr = "10.126.0.0/20"
  region2_cidr = "10.127.0.0/20"
}

data "google_client_config" "current" {}

module "cluster1" {
  source       = "./gke-regional"
  project      = local.project_id
  region       = local.region1 # "australia-southeast1"
  cluster_name = var.region1_cluster_name
  tags         = ["tf-gke-region1", "poc"]
  network      = google_compute_subnetwork.region1.network
  subnetwork   = google_compute_subnetwork.region1.name
}

module "cluster2" {
  source       = "./gke-regional"
  project      = local.project_id
  region       = local.region2 # "australia-southeast2" #var.region2
  cluster_name = var.region2_cluster_name
  tags         = ["tf-gke-region2", "poc"]
  network      = google_compute_subnetwork.region2.network
  subnetwork   = google_compute_subnetwork.region2.name
}

provider "kubernetes" {
  alias                  = "cluster1"
  host                   = module.cluster1.endpoint
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(module.cluster1.client_certificate)
  client_key             = base64decode(module.cluster1.client_key)
  cluster_ca_certificate = base64decode(module.cluster1.cluster_ca_certificate)
}

provider "kubernetes" {
  alias                  = "cluster2"
  host                   = module.cluster2.endpoint
  token                  = data.google_client_config.current.access_token
  client_certificate     = base64decode(module.cluster2.client_certificate)
  client_key             = base64decode(module.cluster2.client_key)
  cluster_ca_certificate = base64decode(module.cluster2.cluster_ca_certificate)
}

#module "cluster1_app" {
#  source      = "./k8s-app"
#  external_ip = module.glb.external_ip
#  node_port   = 30000
#
#  providers = {
#    kubernetes = "kubernetes.cluster1"
#  }
#}

#module "cluster2_app" {
#  source      = "./k8s-app"
#  external_ip = module.glb.external_ip
#  node_port   = 30000
#
#  providers = {
#    kubernetes = "kubernetes.cluster2"
#  }
#}

#module "glb" {
#  source            = "GoogleCloudPlatform/lb-http/google"
#  version           = "1.0.10"
#  name              = "gke-multi-regional"
#  target_tags       = ["tf-gke-region1", "tf-gke-region2"]
#  firewall_networks = [google_compute_network.default.name]
#
#  backends = {
#    "0" = [
#      {
#        group = element(module.cluster1.instance_groups, 0)
#      },
#      {
#        group = element(module.cluster1.instance_groups, 1)
#      },
#      {
#        group = element(module.cluster1.instance_groups, 2)
#      },
#      {
#        group = element(module.cluster2.instance_groups, 0)
#      },
#      {
#        group = element(module.cluster2.instance_groups, 1)
#      },
#      {
#        group = element(module.cluster2.instance_groups, 2)
#      },
#    ]
#  }
#
#  backend_params = [
#    // health check path, port name, port number, timeout seconds.
#    "/,http,30000,10",
#  ]
#}

#module "cluster1_named_port_1" {
#  source         = "github.com/danisla/terraform-google-named-ports"
#  instance_group = element(module.cluster1.instance_groups, 0)
#  name           = "http"
#  port           = "30000"
#}

#module "cluster1_named_port_2" {
#  source         = "github.com/danisla/terraform-google-named-ports"
#  instance_group = element(module.cluster1.instance_groups, 1)
#  name           = "http"
#  port           = "30000"
#}

#module "cluster1_named_port_3" {
#  source         = "github.com/danisla/terraform-google-named-ports"
#  instance_group = element(module.cluster1.instance_groups, 2)
#  name           = "http"
#  port           = "30000"
#}

#module "cluster2_named_port_1" {
#  source         = "github.com/danisla/terraform-google-named-ports"
#  instance_group = element(module.cluster2.instance_groups, 0)
#  name           = "http"
#  port           = "30000"
#}

#module "cluster2_named_port_2" {
#  source         = "github.com/danisla/terraform-google-named-ports"
#  instance_group = element(module.cluster2.instance_groups, 1)
#  name           = "http"
#  port           = "30000"
#}

#module "cluster2_named_port_3" {
#  source         = "github.com/danisla/terraform-google-named-ports"
#  instance_group = element(module.cluster2.instance_groups, 2)
#  name           = "http"
#  port           = "30000"
#}

