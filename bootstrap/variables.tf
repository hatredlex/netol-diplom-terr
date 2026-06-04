variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Default Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "service_account_key_file" {
  type        = string
  description = "Path to service account key file"
}

variable "tf_sa_name" {
  description = "Terraform service account name"
  type        = string
  default     = "terraform-sa"
}

variable "bucket_name" {
  description = "Bucket name for Terraform state"
  type        = string
}