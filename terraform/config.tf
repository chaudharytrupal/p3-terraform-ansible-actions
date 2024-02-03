terraform {
  backend "s3" {
    bucket = "prod-acs730-assignment1-trupal" // Bucket where to SAVE Terraform State
    key    = "stag-network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"
    # encrypt        = true
    # dynamodb_table = "project-acs730-groupdev" //Dynamo DB table
  }
  required_version = ">= 1.0"
}
