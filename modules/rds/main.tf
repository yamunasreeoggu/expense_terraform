 resource "aws_security_group" "security_group" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "RDS"
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.component}-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-${var.component}"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-${var.component}"
  }
}

resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier      = "${var.env}-${var.component}"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.11.3"
  db_subnet_group_name = aws_db_subnet_group.main.name
  database_name           = "dummy"
  master_username         = data.aws_ssm_parameter.master_username.value
  master_password         = data.aws_ssm_parameter.master_password.value
  vpc_security_group_ids  = [aws_security_group.security_group.id]
  skip_final_snapshot     = true
  kms_key_id              = var.kms_key_id
  storage_encrypted       = true
}

resource "aws_rds_cluster_instance" "cluster_instance" {
  count              = 1
  identifier         = "${var.env}-${var.component}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version
}