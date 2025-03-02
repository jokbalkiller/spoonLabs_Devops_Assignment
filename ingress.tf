resource "kubernetes_ingress_v1" "springboot" {
  metadata {
    name = "${terraform.workspace}-springboot"
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" : "${terraform.workspace}-springboot"
      "alb.ingress.kubernetes.io/scheme" : "internet-facing"
      "alb.ingress.kubernetes.io/target-type" : "ip"
      "alb.ingress.kubernetes.io/certificate-arn" : ""
      "alb.ingress.kubernetes.io/listen-ports"                = "[{\"HTTP\": 80},{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect" : "443"
      "alb.ingress.kubernetes.io/healthcheck-path" : "/actuator/health"
      "alb.ingress.kubernetes.io/healthcheck-interval-seconds" : "5"
      "alb.ingress.kubernetes.io/healthcheck-timeout-seconds" : "2"
      "alb.ingress.kubernetes.io/success-codes": "200"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/*"
          backend {
            service {
              name = "springboot"
              port {
                name = "sprintboot"
              }
            }
          }
        }
      }
    }
  }
}