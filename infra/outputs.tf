output "network_id" {
  value = yandex_vpc_network.diplom.id
}

output "subnet_a_id" {
  value = yandex_vpc_subnet.public_a.id
}

output "subnet_b_id" {
  value = yandex_vpc_subnet.public_b.id
}

output "subnet_d_id" {
  value = yandex_vpc_subnet.public_d.id
}

output "subnets" {
  value = {
    ru-central1-a = yandex_vpc_subnet.public_a.id
    ru-central1-b = yandex_vpc_subnet.public_b.id
    ru-central1-d = yandex_vpc_subnet.public_d.id
  }
}

## Stage 2 Kuber Cluster

output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.diplom.id
}

output "k8s_cluster_name" {
  value = yandex_kubernetes_cluster.diplom.name
}

output "k8s_external_endpoint" {
  value = yandex_kubernetes_cluster.diplom.master[0].external_v4_endpoint
}

output "k8s_node_group_id" {
  value = yandex_kubernetes_node_group.diplom.id
}