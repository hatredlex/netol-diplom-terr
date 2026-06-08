## Stage 2 Kuber Cluster

resource "yandex_kubernetes_node_group" "diplom" {
  cluster_id  = yandex_kubernetes_cluster.diplom.id
  name        = var.node_group_name
  description = "Diploma Kubernetes preemptible worker nodes"
  version     = var.k8s_cluster_version

  instance_template {
    platform_id = "standard-v3"

    network_interface {
      nat = true

      subnet_ids = [
        yandex_vpc_subnet.public_a.id,
        yandex_vpc_subnet.public_b.id,
        yandex_vpc_subnet.public_d.id
      ]

      security_group_ids = [
        yandex_vpc_security_group.k8s_cluster_nodegroup_traffic.id,
        yandex_vpc_security_group.k8s_nodegroup_traffic.id,
        yandex_vpc_security_group.k8s_services_access.id
      ]
    }

    resources {
      cores         = var.node_cores
      memory        = var.node_memory
      core_fraction = var.node_core_fraction
    }

    boot_disk {
      type = "network-hdd"
      size = var.node_disk_size
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_group_size
    }
  }

  allocation_policy {
    location {
      zone = yandex_vpc_subnet.public_a.zone
    }

    location {
      zone = yandex_vpc_subnet.public_b.zone
    }

    location {
      zone = yandex_vpc_subnet.public_d.zone
    }
  }

  deploy_policy {
    max_expansion   = 1
    max_unavailable = 1
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "sunday"
      start_time = "04:00"
      duration   = "3h"
    }
  }

  node_labels = {
    project = "netology-diplom"
    role    = "worker"
  }

  labels = {
    project = "netology-diplom"
    check   = "atlantis"
  }
# Atlantis test

  depends_on = [
    yandex_kubernetes_cluster.diplom,
    yandex_vpc_security_group.k8s_cluster_nodegroup_traffic,
    yandex_vpc_security_group.k8s_nodegroup_traffic,
    yandex_vpc_security_group.k8s_services_access
  ]

  timeouts {
    create = "60m"
    update = "60m"
    delete = "30m"
  }
}