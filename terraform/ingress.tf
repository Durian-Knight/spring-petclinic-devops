# On minikube, prefer `minikube addons enable ingress` (already done for this project) since it
# ships an addon-tuned ingress-nginx build. This resource is kept for parity with a cloud cluster
# that doesn't have the addon, and is a no-op if a controller with this release name already exists.
resource "helm_release" "ingress_nginx" {
  count            = var.manage_ingress_via_terraform ? 1 : 0
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.11.3"
}

variable "manage_ingress_via_terraform" {
  description = "Install ingress-nginx via Terraform instead of relying on the minikube addon"
  type        = bool
  default     = false
}
