# Tutorial Avanzado de DevSecOps — Dockerfile con problemas intencionales
# Este fichero tiene 4 problemas de seguridad que deberás corregir en el Paso 4.
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
