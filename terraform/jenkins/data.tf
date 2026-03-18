data "terraform_remote_state" "vpc" {

  backend = "s3"

  config = {
    bucket = "my-project-remote-terraform-state-bucket-5559-ad"
    key    = "prod-vpc/terraform.tfstate"
    region = "ap-south-1"
  }

}