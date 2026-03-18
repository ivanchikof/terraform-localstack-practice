module "s3_infrastructure" {
  source      = "./modules/s3_bucket"
  bucket_name = var.s3_bucket_name
}


module "app_database" {
  source = "./modules/postgres_db"
  app_db_name = var.db_name

  depends_on = [module.s3_infrastructure]
}

#тестовий коментар
