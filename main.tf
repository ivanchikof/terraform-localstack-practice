locals {
  # Створюємо префікс, який залежить від воркспейсу
  #env_prefix = terraform.workspace
  
  # Можна навіть зробити так, щоб для default префікса не було, а для інших - був
  env_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  # Створюємо спільну мапу тегів
  common_tags = merge(var.additional_tags, {
    Environment = terraform.workspace
  })
}

#terraform {
  #backend "s3" {
    #bucket = "ivanchikof-tf-state-2026"  # Назва твого сейфа
    #key    = "dev/terraform.tfstate"     # Шлях до файлу (як папка в Google Drive)
    #region = "us-east-1"                 # Регіон (для LocalStack зазвичай цей)
    
    #dynamodb_table = "ivanchikof-tf-state-locking" # Вкажи назву, яку ти дав у коді

    # Ці 4 рядки потрібні ТІЛЬКИ для LocalStack:
   # endpoints = {
  #    s3  = "http://localhost:4566"
 #     dynamodb = "http://localhost:4566" # Додаємо точку доступу для бази даних
#}
 #   skip_requesting_account_id = true
  #  skip_credentials_validation = true
   # skip_metadata_api_check     = true
    #force_path_style            = true
  #}
#}

#Створюємо бакет вручну для tfstate
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.env_prefix}ivanchikof-tf-state-2026" 
}


#Ввімкнення "Машини часу" (Versioning) для tfstate
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_dynamodb_table" "terraform_locks"{
  #name         = "ivanchikof-tf-state-locking" # Назва таблиці
  name = "${local.env_prefix}ivanchikof-tf-state-locking"
  billing_mode = "PAY_PER_REQUEST"             # Платимо тільки коли користуємося
  hash_key     = "LockID"                      # Це обов'язкове ім'я ключа для Terraform!

  attribute {
    name = "LockID"
    type = "S"      # S означає String (Рядок)
  }
 
}


module "s3_infrastructure" {
  source      = "./modules/s3_bucket"
  #bucket_name = var.s3_bucket_name
  bucket_name = "${local.env_prefix}${var.s3_bucket_name}"
  env_tag     = "main"
}


module "app_database" {
  source = "./modules/postgres_db"
  #app_db_name = var.db_name
  # Додай префікс тут:
  app_db_name = "${local.env_prefix}${var.db_name}"

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
#bucket_name = each.value.bucket_name
# Додаємо префікс до імені кожного бакета відділу
bucket_name = "${local.env_prefix}${each.value.bucket_name}"
# Ось ми дістали "prod" або "dev" з нашої мапи!
env_tag     = each.value.env 
}

module "my_web_server" {
source = "./modules/web_server"

# Передаємо значення в змінні модуля
  project_name = local.common_tags.Project
  owner        = local.common_tags.Owner
}


resource "aws_s3_bucket" "manual_bucket" {
bucket = "${local.env_prefix}manual-created-bucket-2026"

# Замість того, щоб писати кожен тег окремо, 
  # ми можемо передати цілу мапу (map)
  #tags = var.additional_tags
  # Ми зклеюємо стандартні теги з нашим динамічним Environment
  tags = merge(var.additional_tags, {
    Environment = terraform.workspace
  })

# ДИНАМІЧНИЙ БЛОК (пишеться всередині ресурсу)
dynamic "logging"{
    # Якщо var.enable_logging = true, створиться список [1] (одна ітерація)
    # Якщо false, створиться [] (порожньо, блок не створиться)
  for_each = var.enable_logging ? [1]:[]

  content {
    target_bucket = "ivanchikof-tf-state-2026"
    target_prefix = "log/"
   }
  }
}


resource "aws_security_group" "web_sg" {
  name        = "${local.env_prefix}web-sg"
  description = "Allow HTTP inbound traffic"

  # Дозволяємо вхід (Ingress)
  ingress {
    from_port   = 80            # Порт нашого веб-сервера Nginx
    to_port     = 80
    protocol    = "tcp"         # Протокол передачі даних
    cidr_blocks = ["0.0.0.0/0"] # "Весь світ"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # В реальному житті тут має бути тільки твій IP!
  }

  # Дозволяємо вихід (Egress)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Всі протоколи
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${local.env_prefix}deployer-key"
  public_key = file("${path.module}/my-localstack-key.pub")
}

# Кажемо Terraform використати вже існуючий образ
resource "docker_image" "nginx_image" {
  name = "my-first-nginx:latest"
}

# Запускаємо контейнер на основі цього образу
resource "docker_container" "my_web_server" {
  image = docker_image.nginx_image.image_id
  name  = "terraform-managed-nginx"
  
  ports {
    internal = 80
    external = 8081 
  }

  # Оце та сама магія Volume у мові Terraform
  volumes {
    host_path      = "${abspath(path.module)}/custom_html"
    container_path = "/usr/share/nginx/html"
  }
}