terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.22.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = "test"
  secret_key = "test"

  # Найважливіше для LocalStack:
  endpoints {
    s3 = "http://127.0.0.1:4566"
  }

  # Ці параметри допомагають працювати з локальним емулятором без помилок:
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Блок для postgresql
provider "postgresql" {
host		="localhost"
port		=5432
database	="postgres"
username	="admin"
password	="password"
sslmode		="disable" #для локальної роботи шифрування не потрібне
}
