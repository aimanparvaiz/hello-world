module "vpc" {
  source = "git::ssh://git@github.com/aimanparvaiz/terraform-modules.git//modules/vpc"
  vpc_name = "app1-dev"
  vpc_cidr = "10.12.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.12.128.0/24", "10.12.129.0/24", "10.12.130.0/24"]
  public_subnets = ["10.12.0.0/24", "10.12.1.0/24", "10.12.2.0/24"]
  env = "dev"
}

output "private_subnets" {
  value = ["${module.vpc.private_subnets}"]
}
output "public_subnets" {
  value = ["${module.vpc.public_subnets}"]
}
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
