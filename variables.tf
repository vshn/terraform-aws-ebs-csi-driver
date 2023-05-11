variable "csi_namespace" {
  type    = string
  default = "kube-system"
}

variable "csi_sa_name" {
  description = "The service account name used for AWS EKS Container Storage Interface (CSI)"
  type        = string
  default     = "ebs-csi-controller-sa"
}

variable "helm_chart_version" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}
