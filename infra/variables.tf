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

## Stage 2 Kuber Cluster

variable "k8s_cluster_name" {
  description = "Yandex Managed Kubernetes cluster name"
  type        = string
  default     = "diplom-k8s-cluster"
}

variable "k8s_cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "k8s_cluster_service_account_id" {
  description = "Service account ID for Kubernetes cluster"
  type        = string
}

variable "k8s_nodes_service_account_id" {
  description = "Service account ID for Kubernetes nodes"
  type        = string
}

variable "allowed_k8s_api_cidrs" {
  description = "CIDR blocks allowed to connect to Kubernetes API"
  type        = list(string)
  default     = ["95.165.30.171/32"]
}

variable "cluster_ipv4_range" {
  description = "CIDR for Kubernetes pods"
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_ipv4_range" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.96.0.0/16"
}

variable "node_group_name" {
  description = "Kubernetes node group name"
  type        = string
  default     = "diplom-k8s-node-group"
}

variable "node_cores" {
  description = "CPU cores per Kubernetes node"
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "RAM per Kubernetes node in GB"
  type        = number
  default     = 2
}

variable "node_core_fraction" {
  description = "Guaranteed CPU fraction"
  type        = number
  default     = 20
}

variable "node_disk_size" {
  description = "Boot disk size for Kubernetes nodes in GB"
  type        = number
  default     = 64
}

variable "node_group_size" {
  description = "Fixed number of Kubernetes nodes"
  type        = number
  default     = 3
}