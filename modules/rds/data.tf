data "aws_ssm_parameter" "master_username" {
  name = "${var.env}.rds.master_username"
}

data "aws_ssm_parameter" "master_password" {
  name = "${var.env}.rds.master_password"
}