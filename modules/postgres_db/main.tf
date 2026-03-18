resource "postgresql_database" "this" {
  name = var.app_db_name
}
