variable "namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  # Latest stable at time of writing (safe)
  default     = "7.7.14"
}

variable "values" {
  description = "Custom Helm values for Argo CD"
  type        = any
  default     = {}
}

variable "create_namespace" {
  description = "Create namespace if not exists"
  type        = bool
  default     = true
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "argocd"
}
