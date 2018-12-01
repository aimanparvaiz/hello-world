terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket         = "apz-tf-state"
      key            = "${path_relative_to_include()}/terraform.tfstate"
      region         = "us-west-2"
      encrypt        = true
      dynamodb_table = "apz-terraform-lock"
      
      s3_bucket_tags {
        owner = "terragrunt"
        name  = "Terraform state storage"
      }

      dynamodb_table_tags {
        owner = "terragrunt"
        name  = "Terraform lock table"
      }
    }
  }
}