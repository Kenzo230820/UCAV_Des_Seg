## Paso 2 de 10 — Hardening del pipeline CI/CD

### ¿Por qué importa esto?

Un pipeline de seguridad mal configurado puede ser el vector de ataque. Los workflows de GitHub Actions pueden tener **permisos excesivos**, **sin límite de tiempo** (lo que permite que un atacante mantenga un runner comprometido durante horas) o usar versiones de actions que podrían cambiar bajo tus pies.

El OWASP Top 10 CI/CD incluye como riesgo #1 los flujos con permisos excesivos.

### Situación actual

Tu `sast.yml` actual funciona, pero tiene tres problemas de hardening:

1. **Sin `permissions` explícitas** → por defecto el token tiene permisos de escritura en todo el repo
2. **Sin `timeout-minutes`** → un build colgado puede correr indefinidamente (coste y riesgo)
3. **Actions sin versión fija a SHA** → `@v4` puede cambiar en cualquier momento si el mantenedor hace push al tag

### Tu tarea

Actualiza `.github/workflows/sast.yml` con estas tres mejoras:

```yaml
name: SAST — Análisis estático

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

# ✅ MEJORA 1: Mínimo de permisos necesarios (principle of least privilege)
permissions:
  contents: read
  security-events: write   # necesario para subir resultados a Code Scanning

jobs:
  semgrep:
    name: Semgrep SAST
    runs-on: ubuntu-latest
    # ✅ MEJORA 2: Timeout explícito — mata el job si tarda más de 15 minutos
    timeout-minutes: 15
    container:
      image: semgrep/semgrep:latest
    steps:
      # ✅ MEJORA 3: Pinear action a SHA completo (inmutable, no puede cambiar)
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
      - name: Ejecutar Semgrep
        run: semgrep scan --config=auto --error src/
```

### ¿Cómo obtener el SHA de una action?

```bash
# En la página de GitHub de la action → Releases → clic en el tag → copia el SHA del commit
# O desde la terminal:
gh api repos/actions/checkout/git/refs/tags/v4 --jq '.object.sha'
```

### ¿Qué verificará el bot?

- ✅ Que `sast.yml` contiene `permissions:`
- ✅ Que `sast.yml` contiene `timeout-minutes:`

### ¿Qué pasará después?

En el **Paso 3** añadirás escaneo de seguridad al contenedor Docker de la aplicación.

---
*Paso 2 de 10 · Tutorial Avanzado de DevSecOps*
