output "ecr_repository_url" {
  value = aws_ecr_repository.lambda.repository_url
}

output "function_name" {
  value = var.create_lambda ? aws_lambda_function.php-example[0].function_name : null
}