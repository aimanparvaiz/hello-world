data "terraform_remote_state" "eks" {
  backend = "s3"
  config {
    bucket = "apz-tf-state"
    key = "dev/eks/terraform.tfstate"

    region = "us-west-2"
  }
}
provider "helm" {
  debug = true
  kubernetes {
    config_path = "../eks/kubeconfig_${data.terraform_remote_state.eks.cluster_id}"
  }
}
resource "helm_release" "metrics-server" {
  name      = "metrics-server"
  chart     = "../metrics-server"
  namespace = "metrics"
}

provider "kubernetes" {
  config_path = "../eks/kubeconfig_${data.terraform_remote_state.eks.cluster_id}"
}

resource "kubernetes_replication_controller" "helloworld" {
  metadata {
    name = "helloworld"
    labels {
      app = "helloworld"
    }
  }

  spec {
    selector {
      app = "helloworld"
    }
    replicas = 3
    template {
      container {
        image = "aimanparvaiz/helloworld:hw-v1"
        name  = "helloworld"

        resources{
          limits{
            cpu    = "0.5"
            memory = "512Mi"
          }
          requests{
            cpu    = "250m"
            memory = "50Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "helloworld" {
  metadata {
    name = "helloworld"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.helloworld.metadata.0.labels.app}"
    }
    port {
      port = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
resource "kubernetes_horizontal_pod_autoscaler" "helloworld" {
  metadata {
    name = "helloworld"
  }
  spec {
    max_replicas = 10
    min_replicas = 3
    target_cpu_utilization_percentage=10
    scale_target_ref {
      kind = "ReplicationController"
      name = "helloworld"
    }
  }
}
