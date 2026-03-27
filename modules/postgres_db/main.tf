
# 1. Створюємо образ (Data Source ми розберемо пізніше, поки беремо базовий)
resource "docker_image" "postgres_image" {
  name = "postgres:15-alpine"
}

# 2. Замість хмарної RDS створюємо локальний контейнер
resource "docker_container" "db_container" {
  name  = var.app_db_name # Використовуємо ту саму назву, що й для RDS
  image = docker_image.postgres_image.image_id

  # Налаштування паролів через змінні, які приходять з main.tf
  env = [
    "POSTGRES_PASSWORD=${var.db_pass}", 
    "POSTGRES_DB=${var.app_db_name}",
    "POSTGRES_USER=postgres"
  ]

  # Важливо для Networking:
  ports {
    internal = 5432
    external = 5433
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U postgres"]
    interval = "5s"
    retries  = 5
  }
  networks_advanced {
    name = var.network_name
  }
}


# ПАУЗА (Time Sleep) - це наш "запобіжник"
# Він змусить Terraform почекати, поки Postgres реально розчепиться
resource "time_sleep" "wait_30_seconds" {
  depends_on = [docker_container.db_container] # Чекаємо, поки Docker запустить контейнер
  create_duration = "30s"                      # Даємо 30 секунд на ініціалізацію бази
}

# Створення бази всередині (Database)
resource "postgresql_database" "this" {
  name       = var.app_db_name
  # ВАЖЛИВО: Кажемо базі чекати не на контейнер, а на ЗАВЕРШЕННЯ ПАУЗИ
  depends_on = [time_sleep.wait_30_seconds] 
}