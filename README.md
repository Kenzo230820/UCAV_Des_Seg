## Paso 9 de 10 — Política de excepciones con gobernanza

### ¿Por qué importa esto?

Las supresiones en el código (`# nosemgrep:`) son buenas para casos individuales, pero en un equipo de 20+ personas pueden proliferar sin control. Un fichero centralizado de excepciones (`exceptions.yml`) permite:

- **Auditoría**: saber qué está suprimido en toda la base de código
- **Caducidad**: las excepciones tienen fecha de revisión obligatoria
- **Trazabilidad**: cada excepción tiene owner y ticket de aprobación
- **Automatización**: un workflow puede alertar cuando una excepción caduca

Este fichero es lo que el equipo de seguridad revisa en cada auditoría.

### Tu tarea

Crea el fichero `exceptions.yml` en la raíz del repositorio.

Mínimo requerido para que el bot lo acepte (al menos una entrada con todos los campos):

```yaml
# exceptions.yml — Política centralizada de excepciones de seguridad
# Proceso de aprobación: abrir ticket SEC-XXX → revisión de security team → merge
# Revisión periódica: las entradas con expires pasado deben renovarse o eliminarse

exceptions:
  - rule_id: "python.lang.security.insecure-hash-algorithms"
    justification: |
      hash_password() en src/app.py usa MD5 para caché de sesiones anónimas.
      No almacena contraseñas de usuario (bcrypt en auth_service.py).
      Riesgo evaluado: BAJO. Impacto en confidencialidad: ninguno.
    owner: "security-team@empresa.com"
    ticket: "SEC-042"
    created: "2026-04-30"
    expires: "2026-10-30"
    status: "approved"
    reviewed_by: "alice@empresa.com"
    affected_files:
      - "src/app.py"

  - rule_id: "python.flask.security.audit.app-run-param-debug-enabled"
    justification: |
      El flag DEBUG=True en app.py se elimina en el Paso 2 del roadmap de
      remediación. Excepciones temporal hasta completar SEC-089.
    owner: "backend-team@empresa.com"
    ticket: "SEC-089"
    created: "2026-04-30"
    expires: "2026-06-30"
    status: "pending-fix"
    reviewed_by: "security-team@empresa.com"
    affected_files:
      - "src/app.py"
```

Puedes añadir tus propias entradas. El bot solo verifica que existan los campos requeridos.

### ¿Qué verificará el bot?

El fichero `exceptions.yml` debe contener todos estos campos:
- ✅ `rule_id:`
- ✅ `justification:`
- ✅ `owner:`
- ✅ `expires:`
- ✅ `status:`

### ¿Qué pasará después?

¡Último paso! En el **Paso 10** añadirás generación de SBOM (Software Bill of Materials) para tener visibilidad total de las dependencias de la aplicación.

---
*Paso 9 de 10 · Tutorial Avanzado de DevSecOps*
