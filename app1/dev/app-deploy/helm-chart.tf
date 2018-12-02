provider "helm" {
  debug = true
  kubernetes {
    config_path = "../eks/kubeconfig_app1-dev-eks"
  }
}
resource "helm_release" "metrics-server" {
  name      = "metrics-server"
  chart     = "stable/metrics-server"
  version   = "2.0.2"
  namespace = "metrics"
}

provider "kubernetes" {
  config_path = "../eks/kubeconfig_app1-dev-eks"
}
resource "kubernetes_deployment" "helloworld" {
  metadata {
    name = "helloworld"
    labels {
      app = "helloworldApp"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels {
        app = "helloworldApp"
      }
    }

    template {
      metadata {
        labels {
          app = "helloworldApp"
        }
      }

      spec {
        container {
          image = "nginx:1.7.8"
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
}

resource "kubernetes_service" "helloworld" {
  metadata {
    name = "helloworld"
  }
  spec {
    selector {
      app = "${kubernetes_deployment.helloworld.metadata.0.labels.app}"
    }
    port {
      port = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
