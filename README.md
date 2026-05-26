## Paso 4 de 10 — Corrección del Dockerfile

### ¿Por qué importa esto?

Un contenedor mal configurado amplifica cualquier vulnerabilidad de la aplicación. Si la app tiene un bug de ejecución remota de código y el proceso corre como root, el atacante tiene control total del host. Los 4 problemas de este Dockerfile son los más comunes en producción.

### Situación actual

`Dockerfile` tiene estos 4 problemas:

| # | Problema | Riesgo |
|---|---|---|
| 1 | `FROM ubuntu:18.04` — EOL desde 2023 | CVEs sin parchear |
| 2 | `ENV API_KEY=sk-prod-...` — secretos en layers | Visibles con `docker inspect` |
| 3 | Sin `USER` — corre como root | Escalada de privilegios trivial |
| 4 | Sin `HEALTHCHECK` | Kubernetes no detecta fallos de la app |

### Tu tarea

Reemplaza el contenido de `Dockerfile` con esta versión corregida:

```dockerfile
# ✅ CORRECCIÓN 1: Imagen base con soporte activo
FROM python:3.12-slim

# Instalar solo lo necesario, sin caché
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# ✅ CORRECCIÓN 2: Crear usuario sin privilegios
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app

# ✅ CORRECCIÓN 3: Ejecutar como usuario sin privilegios (no root)
USER appuser

# ✅ CORRECCIÓN 4: Healthcheck para que Kubernetes sepa el estado real
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/health || exit 1

EXPOSE 5000

CMD ["python", "src/app.py"]

# NOTA: Las variables de entorno (API_KEY, DB_PASSWORD) se pasan en runtime:
#   docker run -e API_KEY=... -e DB_PASSWORD=... tutorial-app
#   O desde un orquestador (Kubernetes Secret, Azure Key Vault CSI driver)
```

### ¿Qué verificará el bot?

- ✅ Que `Dockerfile` contiene `USER` (directiva de usuario no-root)
- ✅ Que `Dockerfile` **no** contiene `ENV API_KEY=` ni `ENV DB_PASSWORD=` ni `ENV INTERNAL_TOKEN=`
- ✅ Que `Dockerfile` contiene `HEALTHCHECK`

### ¿Qué pasará después?

En el **Paso 5** añadirás escaneo de seguridad a la infraestructura Terraform.

---
*Paso 4 de 10 · Tutorial Avanzado de DevSecOps*
