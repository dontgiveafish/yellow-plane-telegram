output "telegram_webhook_url" {
  value = "${aws_api_gateway_deployment.gateway_deployment.invoke_url}/${aws_api_gateway_resource.resource_telegram_webhook.path_part}"
}

output "message_broadcast_url" {
  value = "${aws_api_gateway_deployment.gateway_deployment.invoke_url}/${aws_api_gateway_resource.resource_message_broadcast.path_part}"
}
