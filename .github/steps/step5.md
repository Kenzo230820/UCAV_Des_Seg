## Paso 5 de 10 — Escaneo de Infraestructura como Código (IaC)

### ¿Por qué importa esto?

Los errores de configuración en Terraform, CloudFormation o Kubernetes YAML son la causa del 80% de los incidentes de seguridad en cloud (Gartner). A diferencia del código de aplicación, una misconfiguration en IaC puede exponer datos de todos los usuarios con un solo `terraform apply`.

**Ejemplos reales**: Capital One (2019, S3 mal configurado), Twitch (2021, bucket público).

### Situación actual

`infra/main.tf` tiene **5 misconfigurations** que Checkov detectará:

| Recurso | Problema | Checkov ID |
|---|---|---|
| `aws_s3_bucket_acl` | ACL `public-read` | CKV_AWS_20 |
| `aws_s3_bucket` | Sin versioning | CKV_AWS_21 |
| `aws_db_instance` | `publicly_accessible = true` | CKV_AWS_17 |
| `aws_db_instance` | `storage_encrypted = false` | CKV_AWS_16 |
| `aws_security_group` | Ingress 0.0.0.0/0 en todos los puertos | CKV_AWS_25 |

### Tu tarea

Crea `.github/workflows/iac-scan.yml`:

```yaml
name: IaC Security Scan

on:
  push:
    branches: [main]
    paths:
      - 'infra/**'
      - '**.tf'
      - '**.tfvars'
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  checkov:
    name: Checkov IaC scan
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Checkov — escanear Terraform
        uses: bridgecrewio/checkov-action@v12
        with:
          directory: infra/
          framework: terraform
          output_format: sarif
          output_file_path: checkov-results.sarif
          soft_fail: false

      - name: Subir resultados a Code Scanning
        if: always()
        uses: github/codeql-action/upload-sarif@45775bd8235c68ba998cffa5171334d58593da1a  # v3.28.0
        with:
          sarif_file: checkov-results.sarif
```

### ¿Qué verificará el bot?

- ✅ Que existe `.github/workflows/iac-scan.yml`
- ✅ Que el fichero contiene `checkov`, `tfsec` o `kics`

### ¿Qué pasará después?

Checkov detectará las 5 misconfigurations — el workflow fallará (❌). En el **Paso 6** corregirás los 3 problemas más críticos del fichero Terraform.

---
*Paso 5 de 10 · Tutorial Avanzado de DevSecOps*
