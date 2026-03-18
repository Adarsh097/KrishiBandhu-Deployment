terraform {
  backend "s3" {
    bucket         = "my-project-remote-terraform-state-bucket-5559-ad"
    key            = "prod-jenkins/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "my-project-state-lock-table-5559-ad"
    encrypt        = true
  }
}