variable "s3_bucket_name" {
  description = "Назва нашого S3 бакета"
  type        = string
  default     = "bucket-test-variable"
}

variable "db_name" {
description	= "Our PostgreSQL database name"
type		= string
default		= "default_db_name"
}

#variable "extra_buckets" {
#  description = "Список додаткових бакетів для відділів"
#  type        = list(string)
#  default     = ["finance-dept", "marketing-dept", "legal-dept"]
#}

variable "dept_settings"{
  description = "Налаштування для відділів: назва та рівень доступу"
  type	      = map(any)
  default     = {
    finance   = {bucket_name = "corp-finance-data", env = "prod"}
    marketing = {bucket_name = "corp-marketing-ads", env = "dev"}
    legal     = {bucket_name = "corp-leagal-docs", env = "prod"}
  }
}
