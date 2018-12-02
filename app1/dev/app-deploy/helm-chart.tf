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
    name = "terraform-example"
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
