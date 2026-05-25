## Paso 8 de 10 — Gestión de falsos positivos con gobernanza

### ¿Por qué importa esto?

No todos los hallazgos de un escáner son vulnerabilidades reales. Suprimir un hallazgo sin justificación es un riesgo: nadie sabrá por qué se ignoró. Una supresión bien gestionada documenta:

- **Qué** se está suprimiendo (rule ID)
- **Por qué** no es un riesgo real en este contexto
- **Quién** lo aprobó (equipo de seguridad)
- **Cuándo** caduca la excepción (para revisarla)

Sin este proceso, las supresiones se acumulan sin revisión y crean deuda de seguridad invisible.

### Situación actual

Semgrep detecta `hash_password()` como uso de MD5 (algoritmo inseguro). Supongamos que, tras análisis, el equipo de seguridad determina que esta función se usa solo para caché de sesiones no-críticas, no para contraseñas de usuarios. Es un **falso positivo en contexto** que debe suprimirse con justificación.

### Tu tarea

Edita `src/app.py` y añade la supresión estructurada encima de la función `hash_password`:

```python
# ==============================================================
# SUPRESIÓN APROBADA — Equipo de Seguridad
# Ticket: SEC-042
# Tipo: Falso positivo en contexto
# Motivo: hash_password() se usa únicamente para caché de
#   sesiones anónimas, no para almacenar contraseñas de usuario.
#   El hash de contraseñas usa bcrypt en auth_service.py (línea 87).
# Aprobado por: security-team@empresa.com
# Creado: 2026-04-30 | Expira: 2026-10-30
# ==============================================================
# nosemgrep: python.lang.security.insecure-hash-algorithms  # SEC-042
def hash_password(password: str) -> str:
    return hashlib.md5(password.encode()).hexdigest()
```

El formato `# nosemgrep: <rule-id>` le dice a Semgrep que ignore esa línea.
El comentario estructurado encima provee el contexto de gobernanza.

### ¿Qué verificará el bot?

- ✅ Que `src/app.py` contiene `nosemgrep:`
- ✅ Que existe una referencia de ticket (`SEC-` seguido de dígitos) en el fichero

### ¿Qué pasará después?

En el **Paso 9** formalizarás las excepciones en un fichero de política con gobernanza centralizada.

---
*Paso 8 de 10 · Tutorial Avanzado de DevSecOps*
