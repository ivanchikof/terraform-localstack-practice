# modules/app_storage/main.tf

# 1. Сховище для аватарів користувачів
resource "aws_s3_bucket" "avatars" {
  bucket = "${var.project_name}-${var.environment}-avatars"

  tags = {
    Name        = "User Avatars"
    Environment = var.environment
  }
}

# 2. Автоматичне видалення старих файлів (через 90 днів)
resource "aws_s3_bucket_lifecycle_configuration" "avatars_lifecycle" {
  bucket = aws_s3_bucket.avatars.id

  rule {
    id     = "cleanup-old-avatars"
    status = "Enabled"

    expiration {
      days = 90
    }
  }
}

# 3. Таблиця DynamoDB для сесій (NoSQL)
resource "aws_dynamodb_table" "sessions" {
  name           = "${var.project_name}-${var.environment}-sessions"
  billing_mode   = "PAY_PER_REQUEST" # Ідеально для Localstack та стартапів
  hash_key       = "SessionId"

  attribute {
    name = "SessionId"
    type = "S" # String
  }

  tags = {
    Environment = var.environment
  }
}

# Завантажуємо файл у наш бакет
resource "aws_s3_object" "first_upload" {
  bucket = aws_s3_bucket.avatars.id # Куди кладемо (в наш бакет)
  key    = "welcome/hello.txt"     # Яку назву матиме файл у хмарі (шлях)
  source = "hello.txt"             # Де лежить файл на твоєму комп'ютері
  
  etag = filemd5("hello.txt")
  # Це допоможе браузеру зрозуміти, що це текст
  content_type = "text/plain"
}