output "s3_bucket_name" {
  value = aws_s3_bucket.avatars.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.sessions.name
}

output "uploaded_file_key" {
  value = aws_s3_object.first_upload.key
}

output "test_file_path" {
  value = "s3://${aws_s3_bucket.avatars.id}/${aws_s3_object.first_upload.key}"
}