## Paso 6 de 10 — Corrección de misconfigurations en Terraform

### ¿Por qué importa esto?

Corregir los problemas en Terraform **antes** de aplicar los cambios es el propósito del IaC scanning. En este paso simulas el flujo real: el escáner encontró problemas → los corriges en código → el escáner vuelve a pasar → `terraform apply`.

### Tu tarea

Edita `infra/main.tf` aplicando estos 3 cambios:

**Cambio 1 — Eliminar ACL pública del bucket S3:**
```hcl
# ELIMINAR este bloque completo:
resource "aws_s3_bucket_acl" "app_data" {
  bucket = aws_s3_bucket.app_data.id
  acl    = "public-read"
}

# AÑADIR en su lugar — bucket privado con versioning y cifrado:
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
```

**Cambio 2 — Base de datos privada y cifrada:**
```hcl
resource "aws_db_instance" "app_db" {
  # ... resto de configuración sin cambios ...

  # ✅ Corregido: no accesible desde internet
  publicly_accessible = false

  # ✅ Corregido: almacenamiento cifrado
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn
}
```

**Cambio 3 — Security group con reglas específicas:**
```hcl
resource "aws_security_group" "web_sg" {
  # ... nombre y descripción sin cambios ...

  # ✅ Corregido: solo HTTPS desde internet
  ingress {
    description = "HTTPS desde internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Sin regla de ingress para el puerto 0-65535
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### ¿Qué verificará el bot?

- ✅ Que `infra/main.tf` **no** contiene `publicly_accessible = true`
- ✅ Que `infra/main.tf` **no** contiene `storage_encrypted = false`
- ✅ Que `infra/main.tf` **no** contiene `acl    = "public-read"`

### ¿Qué pasará después?

En el **Paso 7** añadirás detección de secretos para proteger el historial de Git.

---
*Paso 6 de 10 · Tutorial Avanzado de DevSecOps*
