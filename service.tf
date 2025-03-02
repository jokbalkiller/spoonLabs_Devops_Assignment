resource "kubernetes_service" "springboot" {
  metadata {
    name   = "springboot"
    labels = {
      app  = "springboot"
    }
  }
  spec {
    port {
      name = "springboot"
      port        = 8080
      target_port = 8080
    }

    selector = {
      app  = "springboot"
    }
  }
}