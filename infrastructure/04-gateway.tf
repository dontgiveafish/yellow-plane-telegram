# define gateway

resource "aws_api_gateway_rest_api" "gateway" {
  name        = "${var.lambda_name}-api-gateway"
  description = "Gateway for yellow plane telegram bot"
}

# telegram webhook resource

resource "aws_api_gateway_resource" "resource_telegram_webhook" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "telegram_webhook"
}

resource "aws_api_gateway_method" "method_telegram_webhook" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.resource_telegram_webhook.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gateway_integration_telegram_webhook" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.method_telegram_webhook.resource_id}"
  http_method = "${aws_api_gateway_method.method_telegram_webhook.http_method}"

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"
}

# message broadcast resource

resource "aws_api_gateway_resource" "resource_message_broadcast" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.gateway.root_resource_id}"
  path_part   = "message_broadcast"
}

resource "aws_api_gateway_method" "method_message_broadcast" {
  rest_api_id   = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id   = "${aws_api_gateway_resource.resource_message_broadcast.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gateway_integration_message_broadcast" {
  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  resource_id = "${aws_api_gateway_method.method_message_broadcast.resource_id}"
  http_method = "${aws_api_gateway_method.method_message_broadcast.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.lambda.invoke_arn}"
}

# deployment

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    "aws_api_gateway_integration.gateway_integration_telegram_webhook",
    "aws_api_gateway_integration.gateway_integration_message_broadcast",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.gateway.id}"
  stage_name  = "v1"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.gateway_deployment.execution_arn}/*/*"
}
