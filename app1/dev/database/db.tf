data "terraform_remote_state" "eks" {
  backend = "s3"
  config {
    bucket = "apz-tf-state"
    key = "dev/eks/terraform.tfstate"

    region = "us-west-2"
  }
}
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "apz-tf-state"
    key = "dev/vpc/terraform.tfstate"

    region = "us-west-2"
  }
}
module "db" {
  source = "git::ssh://git@github.com/aimanparvaiz/terraform-modules.git//modules/db"
  identifier = "app1-dev-db"
  name     = "demodb"
  vpc_sg_id = ["${data.terraform_remote_state.eks.worker_security_group_id}"]
  env       = "dev"
  vpc_subnets = "${data.terraform_remote_state.vpc.private_subnets}"

}
