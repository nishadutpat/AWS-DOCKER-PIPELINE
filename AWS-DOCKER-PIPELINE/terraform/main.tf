provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "my-data-bucket-unique-${random_id.bucket_suffix.hex}"
}
resource "random_id" "bucket_suffix" {
  byte_length = 8
}


module "rds" {
  source           = "terraform-aws-modules/rds/aws"
  engine           = "mysql"
  username         = "admin"
  password         = "nishad"
  allocated_storage = 20
  identifier       = "my-rds-instance"
  instance_class   = "db.t3.micro"

  # Required parameters
  major_engine_version = "8.0"  # Provide the major engine version for MySQL
  family               = "mysql8.0"  # The DB engine family (for MySQL 8.0)

  
}



resource "aws_glue_catalog_database" "glue_db" {
  name = "glue_database"
}

resource "aws_ecr_repository" "repo" {
  name = "data-processing"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:*", "rds:*", "glue:*", "ecr:*", "logs:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "data_processor" {
  function_name = "data-processor"
  role           = aws_iam_role.lambda_exec_role.arn
  image_uri      = "${aws_ecr_repository.repo.repository_url}:latest"
  package_type   = "Image"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.data_bucket.bucket
      RDS_USER  = "admin"
      RDS_PASS  = "nishad"
      GLUE_DB   = aws_glue_catalog_database.glue_db.name
    }
  }
}
