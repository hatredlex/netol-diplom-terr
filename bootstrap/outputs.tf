output "terraform_service_account_id" {
  value = yandex_iam_service_account.terraform.id
}

output "bucket_name" {
  value = yandex_storage_bucket.tf_state.bucket
}

output "storage_access_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_static_key.access_key
  sensitive = true
}

output "storage_secret_key" {
  value     = yandex_iam_service_account_static_access_key.terraform_static_key.secret_key
  sensitive = true
}

output "service_account_key_file" {
  value = local_sensitive_file.terraform_sa_key_file.filename
}

## Stage 2 Kuber Cluster

output "k8s_cluster_service_account_id" {
  value = yandex_iam_service_account.k8s_cluster.id
}

output "k8s_nodes_service_account_id" {
  value = yandex_iam_service_account.k8s_nodes.id
}