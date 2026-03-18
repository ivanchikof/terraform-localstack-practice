output "final_s3_bucket_name" {
  description = "Це ім'я бакета, яке ми отримали на виході"
  value       = module.s3_infrastructure.bucket_id
}

output "bucket_arn" {
  description = "Повна ARN адреса бакета"
  value       = module.s3_infrastructure.bucket_arn
}


output "db_internal_id" {
  description = "Внутрішній ID створеної бази в системі"
  value       = module.app_database.db_id  
}

output "all_department_bucket_arns" {
  description = "Список ARN усіх бакетів department"
  value = {
    for k, v in module.department_buckets : k => v.bucket_arn
  }
}

output "all_department_bucket_id" {
  description = "Список назв усіх бакетів department"
  value = {
    for k, v in module.department_buckets : k => v.bucket_id
  }
}