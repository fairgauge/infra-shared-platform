# KMS key for DynamoDB encryption (if enabled)
resource "aws_kms_key" "dynamodb" {
  count = var.enable_kms_encryption ? 1 : 0
  
  description             = "KMS key for ${var.project_name} DynamoDB tables"
  deletion_window_in_days = var.kms_deletion_window
  
  tags = var.tags
}

resource "aws_kms_alias" "dynamodb" {
  count = var.enable_kms_encryption ? 1 : 0
  
  name          = "alias/${var.project_name}-dynamodb"
  target_key_id = aws_kms_key.dynamodb[0].key_id
}

# Terraform state lock table (additional one for apps, not the bootstrap one)
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${var.project_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_kms_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = aws_kms_key.dynamodb[0].arn
    }
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = var.tags
}

# Application state table (optional)
resource "aws_dynamodb_table" "app_state" {
  count = var.create_app_state_table ? 1 : 0
  
  name         = "${var.project_name}-app-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  dynamic "server_side_encryption" {
    for_each = var.enable_kms_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = aws_kms_key.dynamodb[0].arn
    }
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  tags = var.tags
}