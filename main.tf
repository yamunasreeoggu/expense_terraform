module "vpc" {
  source                 = "./modules/vpc"
  vpc_cidr               = var.vpc_cidr
  env                    = var.env
  public_subnets         = var.public_subnets
  private_subnets        = var.private_subnets
  azs                    = var.azs
  account_no             = var.account_no
  default_vpc_id         = var.default_vpc_id
  default_vpc_cidr       = var.default_vpc_cidr
  default_route_table_id = var.default_route_table_id
}

module "public-lb" {
  source            = "./modules/alb"
  env               = var.env
  alb_type          = "public"
  internal          = false
  vpc_id            = module.vpc.vpc_id
  alb_sg_allow_cidr = "0.0.0.0/0"
  subnets           = module.vpc.public_subnets
  dns_name          = "${var.env}.yamunadevops.online"
  zone_id           = "Z10281701O26X6KFZM8G8"
  tg_arn            = module.frontend.tg_arn
}

module "private-lb" {
  source            = "./modules/alb"
  env               = var.env
  alb_type          = "private"
  internal          = true
  vpc_id            = module.vpc.vpc_id
  alb_sg_allow_cidr = var.vpc_cidr
  subnets           = module.vpc.private_subnets
  dns_name          = "backend-${var.env}.yamunadevops.online"
  zone_id           = "Z10281701O26X6KFZM8G8"
  tg_arn            = module.backend.tg_arn
}

module "frontend" {
  source                = "./modules/app"
  app_port              = 80
  component             = "frontend"
  env                   = var.env
  instance_type         = "t3.micro"
  vpc_cidr              = var.vpc_cidr
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.private_subnets
  workstation_node_cidr = var.workstation_node_cidr
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  prometheus_cidr       = var.prometheus_cidr
  kms_key_id            = var.kms_key_id
}

module "backend" {
  depends_on            = [module.mysql]
  source                = "./modules/app"
  app_port              = 8080
  component             = "backend"
  env                   = var.env
  instance_type         = "t3.micro"
  vpc_cidr              = var.vpc_cidr
  vpc_id                = module.vpc.vpc_id
  subnets               = module.vpc.private_subnets
  workstation_node_cidr = var.workstation_node_cidr
  desired_capacity      = var.desired_capacity
  max_size              = var.max_size
  min_size              = var.min_size
  prometheus_cidr       = var.prometheus_cidr
  kms_key_id            = var.kms_key_id
}

module "mysql" {
  source    = "./modules/rds"
  component = "mysql"
  env       = var.env
  subnets   = module.vpc.private_subnets
  vpc_cidr  = var.vpc_cidr
  vpc_id    = module.vpc.vpc_id
  instance_class = var.instance_class
  kms_key_id = var.kms_key_id
}