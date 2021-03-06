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
      instance_type = "m4.large"
      asg_max = 6
      asg_desired_capacity = 3
      autoscaling_enabled = true
      subnets = "${join(",", data.terraform_remote_state.vpc.private_subnets)}"
    }
  ]
}
resource "null_resource" "kubeconfig" {

  depends_on = ["module.eks"]

  provisioner "local-exec" {
  command = "KUBECONFIG=kubeconfig_${module.eks.cluster_id} kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default"
  }
}
module "eks" {
  source = "git::ssh://git@github.com/aimanparvaiz/terraform-modules.git//modules/eks"
  cluster_name = "app1-dev-eks"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  subnets = "${concat(data.terraform_remote_state.vpc.private_subnets, data.terraform_remote_state.vpc.public_subnets)}"
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
