data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "apz-tf-state"
    key = "dev/vpc/terraform.tfstate"

    region = "us-west-2"
  }
}
locals {
  worker_groups = [
    {
      instance_type = "t2.small"
      asg_max = 4
      autoscaling_enabled = true
    }
  ]
}

module "eks" {
  source = "git::ssh://git@github.com/aimanparvaiz/terraform-modules.git//modules/eks"
  cluster_name = "app1-dev-eks"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  private_subnets = ["${data.terraform_remote_state.vpc.private_subnets}"]
  worker_group_count = 1
  worker_groups = "${local.worker_groups}"
  tags = {
    Terraform = "true"
    Environment = "dev"
  }

}

output "cluster_certificate_authority_data" {
  value = "${module.eks.cluster_certificate_authority_data}"
}
output "cluster_endpoint" {
  value = "${module.eks.cluster_endpoint}"
}
output "cluster_id" {
  value = "${module.eks.cluster_id}"
}
output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
}
output "worker_security_group_id" {
  value = "${module.eks.worker_security_group_id}"
}
