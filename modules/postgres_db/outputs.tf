output "db_id" {
    value = postgresql_database.this.id
}

output "db_status" {
  value = docker_container.db_container.healthcheck[0].test[1] # покаже команду перевірки
}

output "db_port" {
  value = docker_container.db_container.ports[0].external
}