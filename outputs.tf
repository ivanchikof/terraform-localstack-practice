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