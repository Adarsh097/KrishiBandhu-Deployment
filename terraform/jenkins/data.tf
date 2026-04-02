data "terraform_remote_state" "vpc" {

  backend = "s3"

  config = {
    bucket = "my-project-remote-terraform-state-bucket-5559-krishibandhu"
    key    = "prod-vpc/terraform.tfstate"
    region = "ap-south-1"
  }

}