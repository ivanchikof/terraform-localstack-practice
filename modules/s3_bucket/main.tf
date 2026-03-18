resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
tags = {
  Environment = var.env_tag
  ManagedBy   = "Terrafrom"
 }
}

