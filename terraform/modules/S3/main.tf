resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname # Change this to a unique name for your bucket
}

resource "aws_s3_bucket_public_access_block" "public_access_blockl" {
  bucket = aws_s3_bucket.my_bucket.bucket

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.my_bucket.bucket
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  bucket = aws_s3_bucket.my_bucket.bucket
  depends_on = [
    aws_s3_bucket_public_access_block.public_access_blockl,
    aws_s3_bucket_ownership_controls.ownership_controls,
  ]

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.public_access_blockl]
  bucket     = aws_s3_bucket.my_bucket.bucket

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.my_bucket.arn}/*"
    }
  ]
}
EOF
}



