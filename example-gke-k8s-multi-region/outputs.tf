output "cluster1-name" {
  value = var.region1_cluster_name
}

output "cluster2-name" {
  value = var.region2_cluster_name
}

output "cluster1-region" {
  value = var.region1
}

output "cluster2-region" {
  value = var.region2
}

output "endpoint" {
  value = module.cluster1.endpoint
}

#output "load-balancer-ip" {
#  value = module.glb.external_ip
#}
