terraform {
  backend "s3" {
    bucket = "ivanchikof-tf-state-2026"  # Назва твого сейфа
    key    = "dev/terraform.tfstate"     # Шлях до файлу (як папка в Google Drive)
    region = "us-east-1"                 # Регіон (для LocalStack зазвичай цей)

    # Ці 4 рядки потрібні ТІЛЬКИ для LocalStack:
    endpoints = {
      s3  = "http://localhost:4566"
}
    skip_requesting_account_id = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

#Створюємо бакет вручну для tfstate
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ivanchikof-tf-state-2026" 
}
#Ввімкнення "Машини часу" (Versioning) для tfstate
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


module "s3_infrastructure" {
  source      = "./modules/s3_bucket"
  bucket_name = var.s3_bucket_name
  env_tag     = "main"
}


module "app_database" {
  source = "./modules/postgres_db"
  app_db_name = var.db_name

  depends_on = [module.s3_infrastructure]
}

#module "department_buckets" {
#source = "./modules/s3_bucket"
# Цикл: перетворюємо список у набір (set) і проходимо по ньому
#for_each = toset(var.extra_buckets)
# each.value — це поточне ім'я зі списку (наприклад, "finance-dept")
#bucket_name = each.value
#}
#тестовий коментар

module "department_buckets" {
source = "./modules/s3_bucket"
# Тепер ітеруємося по мапі
for_each = var.dept_settings
# Беремо конкретне значення з мапи
bucket_name = each.value.bucket_name
# Ось ми дістали "prod" або "dev" з нашої мапи!
env_tag     = each.value.env 
}




