env = "prod"
project_name = "expense"
vpc_cidr = "10.255.0.0/16"
public_subnets = ["10.255.0.0/24" , "10.255.1.0/24"]
private_subnets = ["10.255.2.0/24" , "10.255.3.0/24"]
azs = ["us-east-1a" , "us-east-1b"]
account_no = "492681564023"
default_vpc_id = "vpc-0f69303a5ee298d49"
default_vpc_cidr = "172.31.0.0/16"
default_route_table_id = "rtb-0cd5d19506508373c"
workstation_node_cidr = [ "172.31.23.171/32" ]
desired_capacity = 2
max_size = 10
min_size = 2
instance_class = "db.t3.medium"
prometheus_cidr = [ "172.31.95.19/32"]
kms_key_id = "arn:aws:kms:us-east-1:492681564023:key/e0d7eb6d-885f-412f-b2b6-3352d09b052a"

##eks
node_count = 2
instance_types = ["t3.large"]