#EKS Cluster
resource "aws_eks_cluster" "EKS_Cluster" {
  name     = "HelloWorld_API_Cluster"
  role_arn = "${aws_iam_role.EKSRole.arn}"

  vpc_config {
    subnet_ids = ["${aws_subnet.public_subnet_1.id}", "${aws_subnet.public_subnet_2.id}"]
    security_group_ids = ["${aws_security_group.eks_security_group.id}"]
    }
  
  # Ensures IAM Roles are created before EKS
  # so EKS will deploy/destroy properly
  depends_on = [
    "aws_iam_policy_attachment.EKSClusterPolicy_attach",
    "aws_iam_policy_attachment.EKSServicePolicy_attach",
  ]
}

output "endpoint" {
  value = "${aws_eks_cluster.EKS_Cluster.endpoint}"
}

output "kubeconfig-certificate-authority-data" {
  value = ["${aws_eks_cluster.EKS_Cluster.certificate_authority.0.data}"]
}

#Control plane logging group
resource "aws_cloudwatch_log_group" "hello-world-api" {
  name              = "/aws/eks/HelloWorld_API_Cluster/cluster"
  retention_in_days = 7
}

#Worker node group

resource "aws_eks_node_group" "EKS_node_group" {
  cluster_name    = "${aws_eks_cluster.EKS_Cluster.name}"
  node_group_name = "HelloWorld_Nodes"
  node_role_arn   = "${aws_iam_role.NodeGroupRole.arn}"
  subnet_ids      = ["${aws_subnet.public_subnet_1.id}",  
  "${aws_subnet.public_subnet_2.id}"],

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  # Ensures IAM Roles are created before EKS
  # so EKS will deploy/destroy properly
  depends_on = [
    "aws_iam_policy_attachment.WorkerNodePolicy_attach",
    "aws_iam_policy_attachment.CNIPolicy_attach",
    "aws_iam_policy_attachment.ContainerRegPolicy_attach",
  ]
}