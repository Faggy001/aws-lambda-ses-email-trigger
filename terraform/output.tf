output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.send_email.function_name
}

output "ses_verified_sender" {
  description = "The verified sender email address"
  value       = aws_ses_email_identity.verified_sender.email
}


output "api_gateway_endpoint" {
  value = "https://${aws_api_gateway_rest_api.email_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.stage.stage_name}/send"
}
