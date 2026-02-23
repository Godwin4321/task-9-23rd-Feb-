terraform {
  backend "s3" {
    bucket         = "strapi-terraform-state-775112909184"
    key            = "ecs-strapi/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
