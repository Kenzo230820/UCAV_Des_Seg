# Tutorial Avanzado de DevSecOps — Terraform con misconfigurations intencionales
# Estos recursos tienen 5 problemas que deberás corregir en el Paso 6.
# Tutorial Avanzado de DevSecOps — Terraform corregido

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

# -------------------------------------------------------
# KMS para cifrado de RDS
# -------------------------------------------------------

resource "aws_kms_key" "rds" {
  description         = "KMS key for RDS encryption"
  enable_key_rotation = true

  tags = var.common_tags
}

# -------------------------------------------------------
# S3 Bucket seguro
# Corrige:
# CKV_AWS_20 — Evitar acceso público de lectura
# CKV_AWS_21 — Activar versionado
# -------------------------------------------------------

resource "aws_s3_bucket" "app_data" {
  bucket = "${var.project_name}-data-${var.environment}"

  tags = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# -------------------------------------------------------
# RDS seguro
# Corrige:
# CKV_AWS_17 — No accesible públicamente
# CKV_AWS_16 — Almacenamiento cifrado
# -------------------------------------------------------

resource "aws_db_instance" "app_db" {
  identifier        = "${var.project_name}-db-${var.environment}"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20

  db_name  = "appdb"
  username = "admin"
  password = var.db_password

  publicly_accessible = false

  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  skip_final_snapshot = true

  tags = var.common_tags
}

# -------------------------------------------------------
# Security Group seguro
# Corrige:
# CKV_AWS_25 — No permitir tráfico entrante amplio desde 0.0.0.0/0
# -------------------------------------------------------

resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web application servers"

  ingress {
    description = "HTTPS desde internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permitir tráfico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
