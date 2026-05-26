## Paso 7 de 10 — Detección de secretos en código

### ¿Por qué importa esto?

Los secretos en código son la causa #1 de brechas de seguridad en la nube. Una API key subida a GitHub puede ser detectada por bots en menos de 1 minuto. Los robots de AWS buscan activamente credenciales en GitHub y crean instancias EC2 para minería de criptomonedas.

**Problema adicional**: aunque borres el secreto en el siguiente commit, **sigue visible en el historial de Git**. Hay que revocar la credencial siempre.

### Situación actual

`src/app.py` todavía contiene credenciales hardcodeadas que acabas de dejar en el historial de Git:
- `EXTERNAL_API_KEY = 'sk-prod-1234567890abcdef...'`
- `app.config['SECRET_KEY'] = 'mi-clave-super-secreta...'`

gitleaks las detectará al escanear el historial completo del repositorio.

### Tu tarea

Crea `.github/workflows/secrets-scan.yml`:

```yaml
name: Secrets Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  gitleaks:
    name: gitleaks secret scan
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
        with:
          fetch-depth: 0   # escanear todo el historial, no solo el último commit

      - name: gitleaks — escanear historial completo
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          config-path: .gitleaks.toml
```

> ⚠️ gitleaks **fallará** porque el historial de este repositorio tiene secretos. Eso es esperado — en el siguiente paso aprenderás a gestionarlos correctamente.

### ¿Qué verificará el bot?

- ✅ Que existe `.github/workflows/secrets-scan.yml`
- ✅ Que el fichero contiene `gitleaks`, `trufflehog` o `detect-secrets`

### ¿Qué pasará después?

En el **Paso 8** aprenderás a gestionar los falsos positivos y a suprimir hallazgos con gobernanza correcta.

---
*Paso 7 de 10 · Tutorial Avanzado de DevSecOps*
