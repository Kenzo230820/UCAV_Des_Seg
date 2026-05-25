# Tutorial Avanzado de DevSecOps — Terraform con misconfigurations intencionales
# Estos recursos tienen 5 problemas que deberás corregir en el Paso 6.

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ❌ PROBLEMA 1: Bucket S3 con acceso público de lectura
# Checkov: CKV_AWS_20 — S3 Bucket has an ACL defined which allows public READ access
resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-data-${var.environment}"
  tags   = var.common_tags
}

resource "aws_s3_bucket_acl" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  acl    = "public-read"
}

# ❌ PROBLEMA 2: Sin versioning en el bucket
# Checkov: CKV_AWS_21 — Ensure all data stored in the S3 bucket have versioning enabled

# ❌ PROBLEMA 3: Base de datos accesible desde internet
# Checkov: CKV_AWS_17 — Ensure all data stored in the RDS instance is not publicly accessible
resource "aws_db_instance" "app_db" {
  identifier          = "${var.project_name}-db-${var.environment}"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "appdb"
  username            = "admin"
  password            = var.db_password
  skip_final_snapshot = true

  # ❌ PROBLEMA 3: Base de datos accesible públicamente desde internet
  publicly_accessible = true

  # ❌ PROBLEMA 4: Almacenamiento sin cifrar
  # Checkov: CKV_AWS_16 — Ensure all data stored in the RDS instance is securely encrypted
  storage_encrypted = false

  tags = var.common_tags
}

# ❌ PROBLEMA 5: Security group que permite todo el tráfico entrante
# Checkov: CKV_AWS_25 — Ensure no security groups allow ingress from 0.0.0.0:0 to port 22
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web application servers"

  ingress {
    description = "Allow all inbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
