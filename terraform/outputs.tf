output "instance_public_ip" {
  description = "Public IP of the Directus server"
  value       = aws_instance.directus_server.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.directus_server.id
}

output "directus_url" {
  description = "Directus URL"
  value       = "http://${aws_instance.directus_server.public_ip}:8055"
}

output "private_key" {
  description = "Private key for SSH access"
  value       = tls_private_key.directus_key.private_key_pem
  sensitive   = true
}