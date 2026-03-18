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
