resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  # Спрощуємо теги для модуля, щоб він не шукав locals
  tags = {
    Name    = "web-server"
    Project = var.project_name
    Owner   = var.owner
  }

  user_data = <<-EOF
#!/bin/bash
export PROJECT_NAME="${var.project_name}"
export USER_OWNER="${var.owner}"

${file("${path.module}/install_nginx.sh")}
EOF

  user_data_replace_on_change = true

  # Ми поки ЗАКОМЕНТУЄМО ці рядки, щоб Terraform не сварився. 
  # Ми повернемо їх, коли навчимо модуль приймати ID безпеки та ключі.
  # vpc_security_group_ids = [aws_security_group.web_sg.id]
  # key_name = aws_key_pair.deployer.key_name
}