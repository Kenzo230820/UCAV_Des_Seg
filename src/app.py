"""
API Flask de demostración — contiene vulnerabilidades intencionales para el tutorial.
NO usar en producción. Cada problema está marcado para que Semgrep lo detecte.
"""
from flask import Flask, request, jsonify
import sqlite3
import subprocess
import hashlib
import os
import logging

app = Flask(__name__)

# ❌ PROBLEMA 1: Modo debug habilitado — expone stack traces al cliente
app.config['DEBUG'] = True

# ❌ PROBLEMA 2: Clave secreta hardcodeada en código fuente
app.config['SECRET_KEY'] = 'mi-clave-super-secreta-hardcodeada-123'

# ❌ PROBLEMA 3: API key de servicio externo en el código
EXTERNAL_API_KEY = 'sk-prod-1234567890abcdef9876543210fedcba'

logger = logging.getLogger(__name__)
DB_PATH = os.getenv('DB_PATH', 'database.db')


def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            email TEXT
        )
    ''')
    conn.commit()
    conn.close()


# ❌ PROBLEMA 4: Inyección SQL — f-string con entrada de usuario directamente en la query
@app.route('/user')
def get_user():
    user_id = request.args.get('id', '')
    conn = sqlite3.connect(DB_PATH)
    # Un atacante puede pasar: ?id=1 OR 1=1 -- para extraer todos los usuarios
    query = f"SELECT username, email FROM users WHERE id = {user_id}"
    cursor = conn.execute(query)
    rows = cursor.fetchall()
    conn.close()
    return jsonify(rows)


# ❌ PROBLEMA 5: Inyección de comandos — shell=True con entrada no validada
@app.route('/tools/ping')
def ping():
    host = request.args.get('host', 'localhost')
    # Un atacante puede ejecutar: ?host=localhost; cat /etc/passwd
    result = subprocess.run(
        f'ping -c 1 {host}',
        shell=True,
        capture_output=True,
        text=True
    )
    return jsonify({'output': result.stdout, 'error': result.stderr})


# ❌ PROBLEMA 6: Algoritmo hash débil (MD5) — no apto para contraseñas
def hash_password(password: str) -> str:
    # MD5 es reversible con tablas rainbow. Usar bcrypt o argon2.
    return hashlib.md5(password.encode()).hexdigest()


# ❌ PROBLEMA 7: Path traversal — ruta de fichero controlada por el usuario
@app.route('/files/read')
def read_file():
    filename = request.args.get('name', '')
    # Un atacante puede leer: ?name=../../etc/passwd
    filepath = os.path.join('/var/app/data', filename)
    try:
        with open(filepath) as f:
            return f.read()
    except FileNotFoundError:
        return jsonify({'error': 'File not found'}), 404


@app.route('/health')
def health():
    return jsonify({'status': 'ok', 'version': '1.0.0'})


if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000)
