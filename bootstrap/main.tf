terraform {
  required_version = ">= 1.6.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.136.0"
    }
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_iam_service_account" "terraform" {
  name        = var.tf_sa_name
  description = "Service account for Terraform diploma project"
  folder_id   = var.folder_id
}

# Роль для управления основной инфраструктурой.
resource "yandex_resourcemanager_folder_iam_member" "terraform_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

# Для управления S3 бакетом.
resource "yandex_resourcemanager_folder_iam_member" "terraform_storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.terraform.id}"
}

# Статический ключ для S3.
resource "yandex_iam_service_account_static_access_key" "terraform_static_key" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Static access key for Terraform state bucket"
}

# Ключ для yandex provider.
resource "yandex_iam_service_account_key" "terraform_key" {
  service_account_id = yandex_iam_service_account.terraform.id
  description        = "Authorized key for Terraform provider"
  key_algorithm      = "RSA_2048"
}

resource "local_sensitive_file" "terraform_sa_key_file" {
  filename        = "${path.module}/terraform-sa-key.json"
  file_permission = "0600"

  content = jsonencode({
    id                 = yandex_iam_service_account_key.terraform_key.id
    service_account_id = yandex_iam_service_account.terraform.id
    created_at         = yandex_iam_service_account_key.terraform_key.created_at
    key_algorithm      = yandex_iam_service_account_key.terraform_key.key_algorithm
    public_key         = yandex_iam_service_account_key.terraform_key.public_key
    private_key        = yandex_iam_service_account_key.terraform_key.private_key
  })
}

resource "yandex_storage_bucket" "tf_state" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.terraform_static_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_static_key.secret_key

  versioning {
    enabled = true
  }

  force_destroy = true
}

resource "yandex_storage_bucket_grant" "tf_state_private" {
  bucket = yandex_storage_bucket.tf_state.bucket

  access_key = yandex_iam_service_account_static_access_key.terraform_static_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_static_key.secret_key

  grant {
    id          = yandex_iam_service_account.terraform.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }
}

## Stage 2 Kuber Cluster

# Service account для Managed Kubernetes cluster.
resource "yandex_iam_service_account" "k8s_cluster" {
  name        = "k8s-cluster-sa"
  description = "Service account for Yandex Managed Kubernetes cluster"
  folder_id   = var.folder_id
}

# Service account для worker nodes.
resource "yandex_iam_service_account" "k8s_nodes" {
  name        = "k8s-nodes-sa"
  description = "Service account for Yandex Managed Kubernetes nodes"
  folder_id   = var.folder_id
}

# Роль для управления ресурсами Managed Kubernetes cluster.
resource "yandex_resourcemanager_folder_iam_member" "k8s_clusters_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s_tunnel_clusters_agent" {
  folder_id = var.folder_id
  role      = "k8s.tunnelClusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

# Роль для создания публичных сетевых ресурсов.
resource "yandex_resourcemanager_folder_iam_member" "k8s_vpc_public_admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

# Роль для создания Network Load Balancer из Kubernetes Service.
resource "yandex_resourcemanager_folder_iam_member" "k8s_load_balancer_admin" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_cluster.id}"
}

# Роль для скачивания образов из Yandex Container Registry.
resource "yandex_resourcemanager_folder_iam_member" "k8s_nodes_images_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.k8s_nodes.id}"
}

## Stage 3 Container Registry

# SA для сборки и публикации Docker image в Container Registry.
resource "yandex_iam_service_account" "app_pusher" {
  name        = "app-pusher-sa"
  description = "Service account for pushing Docker images to Yandex Container Registry"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "app_pusher_images_pusher" {
  folder_id = var.folder_id
  role      = "container-registry.images.pusher"
  member    = "serviceAccount:${yandex_iam_service_account.app_pusher.id}"
}

resource "yandex_iam_service_account_key" "app_pusher_key" {
  service_account_id = yandex_iam_service_account.app_pusher.id
  description        = "Authorized key for Docker image push"
  key_algorithm      = "RSA_2048"
}

resource "local_sensitive_file" "app_pusher_key_file" {
  filename        = "${path.module}/app-pusher-key.json"
  file_permission = "0600"

  content = jsonencode({
    id                 = yandex_iam_service_account_key.app_pusher_key.id
    service_account_id = yandex_iam_service_account.app_pusher.id
    created_at         = yandex_iam_service_account_key.app_pusher_key.created_at
    key_algorithm      = yandex_iam_service_account_key.app_pusher_key.key_algorithm
    public_key         = yandex_iam_service_account_key.app_pusher_key.public_key
    private_key        = yandex_iam_service_account_key.app_pusher_key.private_key
  })
}