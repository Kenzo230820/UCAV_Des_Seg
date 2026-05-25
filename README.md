# 🔐 Tutorial Avanzado de DevSecOps

Bienvenido al tutorial interactivo de seguridad avanzada en pipelines. Este repositorio te guía paso a paso a través de las situaciones reales del día a día de un equipo DevSecOps.

## ¿Qué aprenderás?

| Paso | Tema | Herramienta | Nivel |
|------|------|-------------|-------|
| 1 | Análisis estático de código (SAST) | Semgrep | 🟢 Base |
| 2 | Hardening del pipeline CI/CD | GitHub Actions | 🟡 Medio |
| 3 | Escaneo de contenedores | Trivy | 🟡 Medio |
| 4 | Corrección de Dockerfile | Docker best practices | 🟡 Medio |
| 5 | Escaneo de Infraestructura como Código | Checkov | 🟡 Medio |
| 6 | Corrección de misconfigurations en Terraform | Terraform | 🟡 Medio |
| 7 | Detección de secretos en código | gitleaks | 🟠 Avanzado |
| 8 | Gestión de falsos positivos | Semgrep suppressions | 🟠 Avanzado |
| 9 | Política de excepciones con gobernanza | YAML governance | 🔴 Experto |
| 10 | SBOM y seguridad de cadena de suministro | Syft + SHA pinning | 🔴 Experto |

## ¿Cómo funciona?

```
Tú completas una tarea → GitHub Actions lo valida → README se actualiza → siguiente paso
```

Cada paso tiene validaciones automáticas. El bot verifica exactamente lo que se indica — no más, no menos.

## Empezar

1. Haz click en **"Use this template"** → **"Create a new repository"**
2. En tu nuevo repositorio, ve a la pestaña **Actions**
3. Si ves el aviso *"Workflows aren't being run"*, haz click en **"I understand my workflows, enable them"**
4. En el panel izquierdo haz click en **"Step 0: Empezar tutorial"**
5. Haz click en **"Run workflow"** → **"Run workflow"**

El README se actualizará con el Paso 1 en unos segundos.

---

> **Requisitos**: Repositorio propio (no fork directo). Usa **"Use this template"**.
