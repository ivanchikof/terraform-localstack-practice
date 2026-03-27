terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0" # версія, яку ми вже використовували
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
