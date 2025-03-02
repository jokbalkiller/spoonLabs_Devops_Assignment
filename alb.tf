resource "kubernetes_service_account" "alb" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"       = "aws-load-balancer-controller"
      "app.kubernetes.io/component"  = "controller"
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.load_balancer_irsa_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
      "meta.helm.sh/release-name"                = "aws-load-balancer-controller"
      "meta.helm.sh/release-namespace"           = "kube-system"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  values = [
    <<-EOT
    clusterName: ${module.eks.cluster_name}
    serviceAccount:
      create: false
      name: aws-load-balancer-controller
    EOT
  ]
}
