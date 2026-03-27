terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  # Найважливіше для LocalStack:
  endpoints {
    s3       = "http://127.0.0.1:4566"
    dynamodb = "http://127.0.0.1:4566" # Додай цей рядок!
    sts      = "http://127.0.0.1:4566" # І цей (для авторизації)
    iam      = "http://127.0.0.1:4566" # (Identity and Access Management)
    ec2      = "http://127.0.0.1:4566"
    rds      = "http://localhost:4566"
  }

  # Ці параметри допомагають працювати з локальним емулятором без помилок:
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Блок для postgresql
provider "postgresql" {
  host		="127.0.0.1"
  port		=5433
  database	="postgres"
  username	="postgres"
  password	= var.db_password
  sslmode		="disable" #для локальної роботи шифрування не потрібне

  connect_timeout = 15
}
