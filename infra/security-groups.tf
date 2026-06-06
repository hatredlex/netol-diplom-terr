resource "yandex_vpc_security_group" "k8s_cluster_nodegroup_traffic" {
  name        = "k8s-cluster-nodegroup-traffic"
  description = "Service traffic for Kubernetes cluster and node groups"
  network_id  = yandex_vpc_network.diplom.id

  ingress {
    description       = "Allow load balancer health checks"
    protocol          = "TCP"
    from_port         = 0
    to_port           = 65535
    predefined_target = "loadbalancer_healthchecks"
  }

  ingress {
    description       = "Allow service traffic between master and nodes"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  ingress {
    description    = "Allow ICMP health checks from Yandex Cloud internal networks"
    protocol       = "ICMP"
    v4_cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16"
    ]
  }

  egress {
    description       = "Allow outgoing service traffic between master and nodes"
    protocol          = "ANY"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    description    = "Allow outgoing traffic to cluster and service CIDRs"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [
      var.cluster_ipv4_range,
      var.service_ipv4_range
    ]
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_cluster_traffic" {
  name        = "k8s-cluster-traffic"
  description = "Kubernetes API access and master outgoing traffic"
  network_id  = yandex_vpc_network.diplom.id

  ingress {
    description    = "Allow Kubernetes API 443"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = var.allowed_k8s_api_cidrs
  }

  ingress {
    description    = "Allow Kubernetes API 6443"
    protocol       = "TCP"
    port           = 6443
    v4_cidr_blocks = var.allowed_k8s_api_cidrs
  }

  egress {
    description    = "Allow master to metric-server pods"
    protocol       = "TCP"
    port           = 4443
    v4_cidr_blocks = [var.cluster_ipv4_range]
  }

  egress {
    description    = "Allow NTP"
    protocol       = "UDP"
    port           = 123
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description    = "Allow all outgoing traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_nodegroup_traffic" {
  name        = "k8s-nodegroup-traffic"
  description = "Kubernetes node group traffic"
  network_id  = yandex_vpc_network.diplom.id

  ingress {
    description    = "Allow pods and services traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = [
      var.cluster_ipv4_range,
      var.service_ipv4_range
    ]
  }

  ingress {
    description    = "Allow internal VPC traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    description    = "Allow nodes to external resources"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "k8s_services_access" {
  name        = "k8s-services-access"
  description = "Allow access to NodePort services from internet"
  network_id  = yandex_vpc_network.diplom.id

  ingress {
    description    = "Allow NodePort services"
    protocol       = "TCP"
    from_port      = 30000
    to_port        = 32767
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}