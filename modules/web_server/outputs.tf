output "web_server_id" {
  description = "server's id"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "server`s public ip"
  value       = aws_instance.web_server.public_ip

}