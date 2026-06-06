## Stage 3 Container Registry

resource "yandex_container_registry" "diplom" {
  name      = "diplom-registry"
  folder_id = var.folder_id

  labels = {
    project = "netology-diplom"
  }
}

resource "yandex_container_repository" "diplom_nginx" {
  name = "${yandex_container_registry.diplom.id}/diplom-nginx"
}