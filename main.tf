module "s3_infrastructure" {
  source      = "./modules/s3_bucket"
  bucket_name = var.s3_bucket_name
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
}
