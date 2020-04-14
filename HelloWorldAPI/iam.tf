resource "aws_iam_role" "EKSRole" {
  name = "EKSRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    tag-key = "EKSRole"
  }
}

resource "aws_iam_role" "NodeGroupRole" {
  name = "NodeGroupRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    tag-key = "NodeGroupRole"
  }
}

resource "aws_iam_policy_attachment" "EKSClusterPolicy_attach" {
  name       = "EKSClusterPolicy_attach"
  roles      = ["${aws_iam_role.EKSRole.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_policy_attachment" "EKSServicePolicy_attach" {
  name      = "EKSServicePolicy_attach"
  roles     = ["${aws_iam_role.EKSRole.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
resource "aws_iam_policy_attachment" "ContainerRegPolicy_attach" {
  name       = "ContainerRegPolicy_attach"
  roles      = ["${aws_iam_role.NodeGroupRole.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
resource "aws_iam_policy_attachment" "CNIPolicy_attach" {
  name       = "CNIPolicy_attach"
  roles      = ["${aws_iam_role.NodeGroupRole.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_policy_attachment" "WorkerNodePolicy_attach" {
  name       = "WorkerNodePolicy_attach"
  roles      = ["${aws_iam_role.NodeGroupRole.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
