# Data

data "template_file" "lambda_role_template" {
  template = "${file(format("%s/templates/lambda_role_template", path.module))}"
}

data "template_file" "lambda_policy_template" {
  template = "${file(format("%s/templates/lambda_policy_template", path.module))}"
  vars     = {
    table_arn = "${aws_dynamodb_table.table.arn}"
  }
}

data "local_file" "telegram_bot_token" {
  filename = "secrets/telegram_bot_token.txt"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../src/lambda_function.py"
  output_path = "tmp/lambda.zip"
}

# IAM

resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"
  assume_role_policy = "${data.template_file.lambda_role_template.rendered}"
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.lambda_name}-policy"
  path = "/"
  description = "${var.lambda_name} lambda policy"
  policy = "${data.template_file.lambda_policy_template.rendered}"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role = "${aws_iam_role.lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

# Lambda function

resource "aws_lambda_function" "lambda" {
  filename         = "${data.archive_file.lambda_zip.output_path}"
  function_name    = "${var.lambda_name}"
  role             = "${aws_iam_role.lambda_role.arn}"
  handler          = "${var.lambda_handler}"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}-${aws_iam_role.lambda_role.name}"

  timeout = "${var.lambda_timeout}"
  runtime = "python3.6"

  environment {
    variables = {
      TELEGRAM_BOT_TOKEN = "${chomp(data.local_file.telegram_bot_token.content)}",
      TEAMS_TABLE_NAME = "${aws_dynamodb_table.table.name}"
    }
  }
}
