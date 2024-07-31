provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "insecure_namespace" {
  metadata {
    name = "insecure-namespace"
  }
}

resource "kubernetes_secret" "insecure_secret" {
  metadata {
    name      = "insecure-secret"
    namespace = kubernetes_namespace.insecure_namespace.metadata[0].name
  }

  data = {
    username = base64encode("admin")
    password = base64encode("password")
  }
}

resource "kubernetes_deployment" "insecure_deployment" {
  metadata {
    name      = "insecure-deployment"
    namespace = kubernetes_namespace.insecure_namespace.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "insecure-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "insecure-app"
        }
      }

      spec {
        container {
          name  = "insecure-container"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          env {
            name = "USERNAME"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.insecure_secret.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name = "PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.insecure_secret.metadata[0].name
                key  = "password"
              }
            }
          }

          security_context {
            privileged = true  # Insecure: Running with privileged access
            run_as_user = 0    # Insecure: Running as root user
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "insecure_service" {
  metadata {
    name      = "insecure-service"
    namespace = kubernetes_namespace.insecure_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "insecure-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"  # Insecure: Exposing service to the internet
  }
}
