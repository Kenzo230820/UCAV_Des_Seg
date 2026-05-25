## Paso 1 de 10 — Análisis estático de código (SAST)

¡El tutorial ha comenzado! 🎉

### ¿Por qué importa esto?

El SAST detecta vulnerabilidades en el código **antes** de que lleguen a producción. Es la herramienta con mejor ratio coste/beneficio en DevSecOps: cuesta ~0€ en GitHub y detecta problemas en cada pull request, antes de cualquier revisión manual.

### Situación actual

`src/app.py` contiene **7 vulnerabilidades reales**:

| # | Vulnerabilidad | Función | Severidad |
|---|---|---|---|
| 1 | SQL Injection | `get_user()` | 🔴 Crítica |
| 2 | Command Injection | `ping()` | 🔴 Crítica |
| 3 | Path Traversal | `read_file()` | 🟠 Alta |
| 4 | Secreto hardcodeado (`SECRET_KEY`) | línea 16 | 🟠 Alta |
| 5 | API key hardcodeada | línea 19 | 🟠 Alta |
| 6 | Hash débil (MD5) | `hash_password()` | 🟡 Media |
| 7 | Debug mode en producción | línea 14 | 🟡 Media |

Ninguna está siendo detectada todavía.

### Tu tarea

Crea el fichero `.github/workflows/sast.yml`:

```yaml
name: SAST — Análisis estático

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

jobs:
  semgrep:
    name: Semgrep SAST
    runs-on: ubuntu-latest
    container:
      image: semgrep/semgrep:latest
    steps:
      - uses: actions/checkout@v4
      - name: Ejecutar Semgrep
        run: semgrep scan --config=auto --error src/
```

### Cómo hacerlo

**Desde la web de GitHub:**
1. **Add file** → **Create new file**
2. Nombre: `.github/workflows/sast.yml`
3. Pega el contenido → **Commit changes** → **Commit directly to main**

**Desde la terminal:**
```bash
mkdir -p .github/workflows
# crea .github/workflows/sast.yml con el contenido de arriba
git add .github/workflows/sast.yml
git commit -m "ci: add Semgrep SAST workflow"
git push
```

### ¿Qué verificará el bot?

- ✅ Que existe `.github/workflows/sast.yml`
- ✅ Que el fichero contiene la cadena `semgrep`

### ¿Qué pasará después?

Semgrep encontrará las vulnerabilidades — el workflow fallará (❌). **Eso es lo esperado.** En el Paso 2 aprenderás a configurar el pipeline de forma segura antes de corregir el código.

---
*Paso 1 de 10 · Tutorial Avanzado de DevSecOps*
