# Tutorial Avanzado de DevSecOps — Dockerfile con problemas intencionales
# Este fichero tiene 4 problemas de seguridad que deberás corregir en el Paso 4.

# ❌ PROBLEMA 1: Imagen base con CVEs conocidos (EOL desde abril 2023)
FROM ubuntu:18.04

# Instalar dependencias del sistema
RUN apt-get update && \
    apt-get install -y python3 python3-pip curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ❌ PROBLEMA 2: Secretos en variables de entorno del contenedor
# Quedan grabados en el historial de layers y visibles con: docker inspect
ENV API_KEY=sk-prod-1234567890abcdef9876543210fedcba
ENV DB_PASSWORD=SuperSecretPassword123!
ENV INTERNAL_TOKEN=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

# ❌ PROBLEMA 3: Sin directiva USER — el proceso se ejecuta como root
# Si un atacante explota la app, tiene acceso root al contenedor

# ❌ PROBLEMA 4: Sin HEALTHCHECK
# Kubernetes/Docker no sabe si la app está realmente funcionando

EXPOSE 5000

CMD ["python3", "src/app.py"]
