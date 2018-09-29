
data "aws_iam_policy_document" "worker_role_doc" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "worker_role" {
  name               = "${var.name}-worker-instance-role"
  assume_role_policy = "${data.aws_iam_policy_document.worker_role_doc.json}"
}

# Permission borrowed from https://github.com/kubernetes/kops/issues/1873
data "aws_iam_policy_document" "worker_policy_doc" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:DeleteTags",
      "ec2:DeleteVolume",
      "ec2:DescribeTags",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumesModifications",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeVolumes",
    ]
    resources = [ "*" ]
  }
  statement {
    actions = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "worker_policy" {
  name        = "${var.name}-worker-instance-role-policy"
  # path        = "/"
  role = "${aws_iam_role.worker_role.id}"
  policy = "${data.aws_iam_policy_document.worker_policy_doc.json}"
}

resource "aws_iam_instance_profile" "worker_profile" {
  name  = "${var.name}-worker-instance-role"
  role = "${aws_iam_role.worker_role.name}"
}

