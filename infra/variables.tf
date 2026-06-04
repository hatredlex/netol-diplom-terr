variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "zone" {
  description = "Default zone"
  type        = string
  default     = "ru-central1-a"
}

variable "service_account_key_file" {
  description = "Path to authorized key JSON for Terraform service account"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "diplom-vpc"
}