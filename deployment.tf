resource "kubernetes_deployment" "springboot" {
  metadata {
    name   = "${terraform.workspace}-springboot"
    labels = {
      app  = "springboot"
    }
  }
  spec {
    replicas = 2

    selector {
      match_labels = {
        app  = "springboot"
      }
    }

    strategy {
      rolling_update {
        max_surge       = "1"
        max_unavailable = "0"
      }
      type = "RollingUpdate"
    }

    template {
      metadata {
        labels = {
          app  = "springboot"
        }
      }

      spec {
        container {
          port {
            container_port = 8080
          }
          name  = "springboot"
          image = "${var.ecr_registry}/springboot:$IMAGE_TAG"

          resources {
            limits = {
              cpu    = "500m"
              memory = "2Gi"
            }
            requests = {
              cpu    = "1500m"
              memory = "2Gi"
            }
          }

          readiness_probe {
            http_get {
              path = "/actuator/health"
              port = "8080"
            }
            initialDelaySeconds = 10
            periodSeconds = 2
            failureThreshold = 30
          }

          liveness_probe {
            http_get {
              path = "/actuator/health"
              port = "8080"
            }
            initialDelaySeconds = 30
            periodSeconds = 10
            failureThreshold = 9
          }

          lifecycle {
            pre_stop {
              exec {
                command = ["/bin/sh", "-c", "sleep 14"]
              }
            }
          }
        }

        termination_grace_period_seconds = 60

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "app"
                  operator = "In"
                  values   = ["springboot"]
                }
                match_expressions {
                  key      = "os"
                  operator = "In"
                  values   = ["amd"]
                }
              }
            }
          }
        }
      }
    }
  }

  timeouts {
    create = "3m"
    delete = "3m"
    update = "3m"
  }
}