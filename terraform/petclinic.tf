# Terraform-managed alternative to the Jenkins-driven `helm upgrade --install`. Disabled by default
# because in this project Jenkins owns the app release lifecycle (see jenkins/Jenkinsfile); enable
# this only when demoing a pure-IaC deploy path without the CI/CD pipeline in front of it.
resource "kubernetes_namespace" "petclinic" {
  count = var.manage_petclinic_via_terraform ? 1 : 0
  metadata {
    name = "petclinic"
  }
}

resource "helm_release" "petclinic" {
  count      = var.manage_petclinic_via_terraform ? 1 : 0
  name       = "petclinic"
  chart      = "${path.module}/../helm/petclinic"
  namespace  = kubernetes_namespace.petclinic[0].metadata[0].name
  timeout    = 300

  set {
    name  = "image.tag"
    value = var.petclinic_image_tag
  }
}

variable "manage_petclinic_via_terraform" {
  description = "Deploy the petclinic Helm release via Terraform instead of Jenkins"
  type        = bool
  default     = false
}

variable "petclinic_image_tag" {
  description = "Image tag to deploy when manage_petclinic_via_terraform is true"
  type        = string
  default     = "latest"
}
