output "network_id" {
  value = yandex_vpc_network.diplom.id
}

output "subnet_a_id" {
  value = yandex_vpc_subnet.public_a.id
}

output "subnet_b_id" {
  value = yandex_vpc_subnet.public_b.id
}

output "subnet_d_id" {
  value = yandex_vpc_subnet.public_d.id
}

output "subnets" {
  value = {
    ru-central1-a = yandex_vpc_subnet.public_a.id
    ru-central1-b = yandex_vpc_subnet.public_b.id
    ru-central1-d = yandex_vpc_subnet.public_d.id
  }
}