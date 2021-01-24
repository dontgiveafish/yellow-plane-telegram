variable "teams_table_name" {
  description = "DynamoDB table to store teams members"
}

variable "teams_table_read_capacity" {
  description = "Teams members DynamoDB table read capacity"
}

variable "teams_table_write_capacity" {
  description = "Teams members DynamoDB table write capacity"
}

variable "lambda_name" {
  description = "Telegram bot lambda resource name"
}

variable "lambda_handler" {
  description = "Telegram bot lambda handler"
}

variable "lambda_timeout" {
  description = "Telegram bot lambda timeout"
}
