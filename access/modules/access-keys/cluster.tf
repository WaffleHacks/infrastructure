resource "aws_iam_user" "cluster" {
  name = "cluster"
  path = "/terraform/"

  tags = {
    ChildProject = "cluster"
  }
}

resource "aws_iam_access_key" "cluster" {
  user   = aws_iam_user.cluster.name
  status = "Active"
}

resource "aws_iam_user_policy_attachment" "cluster_iam_role" {
  user       = aws_iam_user.cluster.name
  policy_arn = aws_iam_policy.iam_role.arn
}

resource "aws_iam_user_policy_attachment" "cluster_s3" {
  user       = aws_iam_user.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
