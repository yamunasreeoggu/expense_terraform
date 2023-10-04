module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  env = var.env
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
  account_no = var.account_no
  default_vpc_id = var.default_vpc_id
  default_vpc_cidr = var.default_vpc_cidr
  default_route_table_id = var.default_route_table_id
}

#module "public-lb" {
#  source = "./modules/alb"
#  env = var.env
#  alb_type = "public"
#  internal = false
#  vpc_id = module.vpc.vpc_id
#  alb_sg_allow_cidr = "0.0.0.0/0"
#  subnets = module.vpc.public_subnets
#}
#
#module "private-lb" {
#  source = "./modules/alb"
#  env = var.env
#  alb_type = "private"
#  internal = true
#  vpc_id = module.vpc.vpc_id
#  alb_sg_allow_cidr = var.vpc_cidr
#  subnets = module.vpc.private_subnets
#}
#
#module "frontend" {
#  source = "./modules/app"
#  app_port      = 80
#  component     = "frontend"
#  env           = var.env
#  instance_type = "t3.micro"
#  vpc_cidr      = var.vpc_cidr
#  vpc_id        = module.vpc.vpc_id
#  subnets       = module.vpc.private_subnets
#  workstation_node_cidr = var.workstation_node_cidr
#}

module "backend" {
  source = "./modules/app"
  app_port      = 8080
  component     = "backend"
  env           = var.env
  instance_type = "t3.micro"
  vpc_cidr      = var.vpc_cidr
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.private_subnets
  workstation_node_cidr = var.workstation_node_cidr
}

module "mysql" {
  source = "./modules/rds"
  component = "mysql"
  env = var.env
  subnets = module.vpc.private_subnets
  vpc_cidr = var.vpc_cidr
  vpc_id = module.vpc.vpc_id
}