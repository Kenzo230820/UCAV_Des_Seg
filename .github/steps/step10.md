## Paso 10 de 10 — SBOM y seguridad de cadena de suministro

### ¿Por qué importa esto?

El ataque a SolarWinds (2020) demostró que el mayor riesgo no siempre está en tu código, sino en tus dependencias. Un **SBOM (Software Bill of Materials)** es un inventario completo de todos los componentes de tu aplicación — librerías, versiones, licencias, y sus CVEs conocidos.

Es obligatorio en contratos con el gobierno de EE.UU. desde 2021 (EO 14028) y cada vez más requerido en auditorías de enterprise.

### Tu tarea

Crea `.github/workflows/sbom.yml`:

```yaml
name: SBOM — Software Bill of Materials

on:
  push:
    branches: [main]
    paths:
      - 'requirements.txt'
      - 'Dockerfile'
      - 'src/**'
  release:
    types: [published]

permissions:
  contents: write    # para subir el SBOM como release asset
  packages: write    # para publicar en GitHub Packages

jobs:
  sbom:
    name: Generate SBOM with Syft
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      # ✅ Buena práctica: actions pineadas a SHA
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2

      - name: Instalar Syft
        uses: anchore/sbom-action/download-syft@v0.18.0

      - name: Generar SBOM del repositorio
        run: |
          syft . \
            --output cyclonedx-json=sbom-source.json \
            --output spdx-json=sbom-spdx.json \
            --output table

      - name: Subir SBOM como artefacto
        uses: actions/upload-artifact@v4
        with:
          name: sbom-${{ github.sha }}
          path: |
            sbom-source.json
            sbom-spdx.json
          retention-days: 90

      - name: Escanear SBOM con Grype (vulnerabilidades en dependencias)
        run: |
          curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
          grype sbom:sbom-source.json --fail-on high
```

### ¿Por qué pinear a SHA en lugar de a tag?

Un tag como `@v4` puede ser movido por el mantenedor (incluso por un atacante que comprometa su cuenta). Un SHA es **inmutable**: `@11bd71901bbe5b1630ceea73d27597364c9af683` siempre apunta exactamente al mismo código.

### ¿Qué verificará el bot?

- ✅ Que existe `.github/workflows/sbom.yml`
- ✅ Que el fichero contiene `syft`, `cdxgen` o `cyclonedx`

### ¿Qué pasará después?

¡Has completado el tutorial! 🎉

---
*Paso 10 de 10 · Tutorial Avanzado de DevSecOps*
