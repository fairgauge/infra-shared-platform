terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "state_management" {
  source = "../modules/bootstrap/state-management"

  project_name = "fairgauge"  
  environment = "shared"
  
  tags = {
    Environment = "shared"
    Purpose     = "terraform-state"
  }
}

output "s3_bucket_name" {
  value = module.state_management.s3_bucket_name
}

output "dynamodb_table_name" {
  value = module.state_management.dynamodb_table_name
}