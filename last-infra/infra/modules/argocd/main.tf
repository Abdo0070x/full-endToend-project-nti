resource "kubernetes_namespace_v1" "argocd" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}


resource "helm_release" "argocd" {
  name       = var.release_name
  namespace  = var.namespace

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  create_namespace = false

  values = [
    yamlencode(var.values)
  ]

  depends_on = [
    kubernetes_namespace_v1.argocd
  ]

  timeout = 600
  atomic  = true
  cleanup_on_fail = true
}
