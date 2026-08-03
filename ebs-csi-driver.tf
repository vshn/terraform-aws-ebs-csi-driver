resource "aws_iam_policy" "ebs_controller_policy" {
  name_prefix = "ebs-csi-driver-policy"
  policy      = data.aws_iam_policy_document.ebs_controller_policy_doc.json
}

module "ebs_controller_role" {
  source          = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version         = "6.8.0"
  description     = "EBS CSI Driver Role"
  name            = "ebs-csi-driver-policy"
  use_name_prefix = true
  oidc_providers = {
    provider = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.csi_namespace}:${var.csi_sa_name}"]
    }
  }
  policies = {
    efs_csi_policy = aws_iam_policy.ebs_controller_policy.arn
  }
}

resource "helm_release" "csi" {
  atomic          = true
  chart           = "aws-ebs-csi-driver"
  cleanup_on_fail = true
  name            = "aws-ebs-csi-driver"
  namespace       = var.csi_namespace
  repository      = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver/"
  timeout         = 300
  version         = var.helm_chart_version

  set = [
    {
      name  = "controller.serviceAccount.create"
      value = "true"
      type  = "auto"
    },
    {
      name  = "controller.serviceAccount.name"
      value = var.csi_sa_name
      type  = "string"
    },
    {
      name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com\\/role\\-arn"
      value = module.ebs_controller_role.arn
      type  = "string"
    }
  ]
}
