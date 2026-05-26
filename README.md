## Paso 3 de 10 — Escaneo de contenedores

### ¿Por qué importa esto?

Las imágenes Docker acumulan CVEs con el tiempo. Una imagen base de hace 2 años puede tener cientos de vulnerabilidades conocidas. Sin un escáner automatizado, puedes estar desplegando vulnerabilidades críticas sin saberlo.

**Dato real**: el 58% de las imágenes en Docker Hub públicas tienen al menos una vulnerabilidad crítica (Sysdig 2024).

### Situación actual

El `Dockerfile` de este proyecto usa `ubuntu:18.04` — una imagen con **soporte terminado en abril 2023** que acumula CVEs sin parchear. Además tiene secretos en variables de entorno y se ejecuta como root. Pero primero hay que **verlo** antes de corregirlo.

### Tu tarea

Crea `.github/workflows/container-scan.yml` para que Trivy escanee la imagen en cada push:

```yaml
name: Container Security Scan

on:
  push:
    branches: [main]
    paths:
      - 'Dockerfile'
      - 'src/**'
      - 'requirements.txt'
  pull_request:
    branches: [main]

permissions:
  contents: read
  security-events: write

jobs:
  trivy:
    name: Trivy container scan
    runs-on: ubuntu-latest
    timeout-minutes: 20
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Build image
        run: docker build -t tutorial-app:${{ github.sha }} .

      - name: Trivy — escanear imagen
        uses: aquasecurity/trivy-action@6c175e9c4083a92bbca2f9724c8a5e33bc2d97a8  # 0.28.0
        with:
          image-ref: tutorial-app:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: '1'

      - name: Subir resultados a Code Scanning
        if: always()
        uses: github/codeql-action/upload-sarif@45775bd8235c68ba998cffa5171334d58593da1a  # v3.28.0
        with:
          sarif_file: trivy-results.sarif
```

### ¿Qué verificará el bot?

- ✅ Que existe `.github/workflows/container-scan.yml`
- ✅ Que el fichero contiene `trivy`, `grype` o `snyk`

### ¿Qué pasará después?

Trivy encontrará CVEs críticos — el workflow fallará (❌). En el **Paso 4** corregirás los 4 problemas del Dockerfile.

---
*Paso 3 de 10 · Tutorial Avanzado de DevSecOps*
