resource "aws_iam_policy" "ebs_controller_policy" {
  name_prefix = "ebs-csi-driver-policy"
  policy      = data.aws_iam_policy_document.ebs_controller_policy_doc.json
}

module "ebs_controller_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.47.1"
  create_role                   = true
  role_description              = "EBS CSI Driver Role"
  role_name_prefix              = "ebs-csi-driver-policy"
  provider_url                  = var.oidc_provider_url
  role_policy_arns              = [aws_iam_policy.ebs_controller_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.csi_namespace}:${var.csi_sa_name}"]
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

  set {
    name  = "controller.serviceAccount.create"
    value = "true"
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = var.csi_sa_name
    type  = "string"
  }

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com\\/role\\-arn"
    value = module.ebs_controller_role.iam_role_arn
    type  = "string"
  }
}
