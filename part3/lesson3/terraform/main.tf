# Define region - Hard coded to us-west-2
provider "aws" {
  region = "us-west-2"
}

# Create a Role for Redshift cluster
resource "aws_iam_role" "redshift-dw-role" {
  name = "redshift-dw-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      source = "udacity-dend"
  }
}

# Allow Redshift role to be able to read from S3
resource "aws_iam_role_policy_attachment" "redshift-read-s3" {
  role       = "${aws_iam_role.redshift-dw-role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Create Redshift Cluster
resource "aws_redshift_cluster" "cluster-1" {
  cluster_identifier = "dend-redshift-cluster"
  database_name      = "dwh"
  master_username    = ".."
  master_password    = ".."
  node_type          = "dc2.large"
  cluster_type       = "multi-node"
  number_of_nodes    = "4"
  iam_roles          = ["${aws_iam_role.redshift-dw-role.name}"]
}