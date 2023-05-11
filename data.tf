data "aws_iam_policy_document" "ebs_controller_policy_doc" {
  statement {
    actions = [
      "ec2:ModifyVolume",
      "ec2:DetachVolume",
      "ec2:DescribeVolumesModifications",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "ec2:DescribeSnapshots",
      "ec2:DescribeInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DeleteVolume",
      "ec2:DeleteTags",
      "ec2:DeleteSnapshot",
      "ec2:CreateVolume",
      "ec2:CreateTags",
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
    ]
    resources = ["*"]
  }
}
