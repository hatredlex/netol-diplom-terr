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