resource "aws_dynamodb_table" "table" {
  name           = "${var.teams_table_name}"
  read_capacity  = "${var.teams_table_read_capacity}"
  write_capacity = "${var.teams_table_write_capacity}"

  hash_key = "alias"

  attribute {
    name = "alias"
    type = "S"
  }
}
