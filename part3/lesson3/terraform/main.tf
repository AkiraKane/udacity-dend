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