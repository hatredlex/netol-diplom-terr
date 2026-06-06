## Stage 2 Kuber Cluster

resource "yandex_kubernetes_cluster" "diplom" {
  name        = var.k8s_cluster_name
  description = "Diploma Managed Kubernetes cluster"

  network_id = yandex_vpc_network.diplom.id

  cluster_ipv4_range = var.cluster_ipv4_range
  service_ipv4_range = var.service_ipv4_range

  service_account_id      = var.k8s_cluster_service_account_id
  node_service_account_id = var.k8s_nodes_service_account_id

  release_channel         = "STABLE"
  network_policy_provider = "CALICO"

  master {
    version   = var.k8s_cluster_version
    public_ip = true

    regional {
      region = "ru-central1"

      location {
        zone      = yandex_vpc_subnet.public_a.zone
        subnet_id = yandex_vpc_subnet.public_a.id
      }

      location {
        zone      = yandex_vpc_subnet.public_b.zone
        subnet_id = yandex_vpc_subnet.public_b.id
      }

      location {
        zone      = yandex_vpc_subnet.public_d.zone
        subnet_id = yandex_vpc_subnet.public_d.id
      }
    }

    security_group_ids = [
      yandex_vpc_security_group.k8s_cluster_nodegroup_traffic.id,
      yandex_vpc_security_group.k8s_cluster_traffic.id
    ]

    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        day        = "sunday"
        start_time = "03:00"
        duration   = "3h"
      }
    }
  }

  labels = {
    project = "netology-diplom"
  }

  depends_on = [
    yandex_vpc_subnet.public_a,
    yandex_vpc_subnet.public_b,
    yandex_vpc_subnet.public_d,
    yandex_vpc_security_group.k8s_cluster_nodegroup_traffic,
    yandex_vpc_security_group.k8s_cluster_traffic
  ]

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}