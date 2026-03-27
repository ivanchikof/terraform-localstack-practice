variable "app_db_name" {
  description = "Назва бази даних"
  type        = string
}

variable "db_pass"{

  description = "Пароль до бази даних, який приходить з головного модуля"
  type        = string
  sensitive   = true # ОБОВ'ЯЗКОВО вказуємо і тут, щоб Terraform не "вибовкав" секрет
}

variable "network_name" {
  description = "Назва Docker мережі для підключення бази"
  type        = string
}