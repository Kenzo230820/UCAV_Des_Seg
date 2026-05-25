# TUTORIAL -- Como construir un repositorio template con sistema de pasos progresivos

Guia tecnica agnostica para replicar esta arquitectura en cualquier dominio:
tutorial de seguridad, onboarding tecnico, certificacion interna, curso de buenas
practicas, o cualquier proceso que se quiera guiar paso a paso con validacion automatica.

---

## Arquitectura general

El sistema usa dos repositorios:

**`security-tutorial-base`** — contiene la logica compartida: los workflows reutilizables
que todos los tutoriales invocan. Ninguna logica se duplica en los repos individuales.

**`template-NOMBRE-del-tutorial`** — el repo del tutorial. Es un thin caller: solo
declara su nombre, el numero de pasos, y delega todo al base.

Estructura del repo de tutorial:

```
template-NOMBRE-del-tutorial/
    .github/workflows/
        start.yml
        completion.yml
        validate.yml
        reset-tutorial.yml
        update-from-template.yml
        test-tutorial.yml
        functional-tests.yml
        validate-step-01.yml        <-- un workflow por paso
        validate-step-02.yml
        validate-step-NN.yml
    .tutorial/
        config.yml
        steps/
            00-introduccion.md
            01-nombre-del-paso.md
            NN-nombre-del-paso.md
    scripts/
        validate-step-01.py         <-- un validador por paso
        validate-step-02.py
        validate-step-NN.py
        tutorial_engine.py
        test_tutorial_functional.py
    README.md
```

---

## Parte 1 -- El repositorio base (security-tutorial-base)

Contiene seis workflows reutilizables. Todos usan `on: workflow_call`.

| Workflow | Que hace |
|---|---|
| `reusable-start.yml` | Inicializa el estado del tutorial en el fork del estudiante |
| `reusable-completion.yml` | Genera la evidencia de finalizacion cuando todos los pasos estan completos |
| `reusable-validate.yml` | Permite al estudiante lanzar manualmente una validacion de su progreso |
| `reusable-reset.yml` | Reinicia el estado del tutorial al paso 0 |
| `reusable-update-from-template.yml` | Sincroniza el fork del estudiante con cambios del template original |
| `reusable-tutorial-tests.yml` | Valida la estructura e integridad del tutorial (CI del repo template) |

### Que comprueba reusable-tutorial-tests.yml

Este es el workflow mas critico para el autor del tutorial. Verifica antes de publicar:

- Que existen todos los workflows requeridos en `.github/workflows/`
- Que existe `.tutorial/config.yml`
- Que existe exactamente un fichero `00-*.md` en `.tutorial/steps/`
- Que existen los ficheros de paso del `01` al `N` (segun `total-steps`)
- Que cada fichero de paso empieza con `# Paso N.` y contiene las 8 secciones obligatorias
- Que `README.md` contiene los tres enlaces obligatorios

---

## Parte 2 -- Los workflows del repo de tutorial

### Workflows thin caller (5)

`start.yml`, `completion.yml`, `validate.yml`, `reset-tutorial.yml` y
`update-from-template.yml` siguen el mismo patron: `on: workflow_dispatch`, un
solo job que llama al reusable correspondiente en `security-tutorial-base` pasando
`tutorial-name` y el token.

El unico campo que cambia entre repos es `tutorial-name`. El valor debe coincidir
exactamente con el campo `name` en `.tutorial/config.yml`.

### test-tutorial.yml

Llama a `reusable-tutorial-tests` en el base. Se dispara en `push`, `pull_request`
y `workflow_dispatch`. Pasa tambien `total-steps`, que debe coincidir con
`total_steps` en `.tutorial/config.yml`.

### functional-tests.yml

No llama al base. Corre `scripts/test_tutorial_functional.py` directamente en el
runner. Se dispara en `push`, `pull_request` y `workflow_dispatch`. Requiere
instalar `pyyaml` como dependencia antes de ejecutar el script.

### Un workflow por paso: validate-step-NN.yml

Cada paso tiene su propio workflow. `validate-step-01.yml` corre solo
`scripts/validate-step-01.py`. `validate-step-02.yml` corre solo
`scripts/validate-step-02.py`. Y asi sucesivamente.

Ventajas frente a un workflow unico que itera todos los validadores:
- El estudiante ve exactamente que paso fallo en el panel de Actions.
- Los pasos anteriores no bloquean la ejecucion de un paso posterior si se quiere
  validar de forma independiente.
- Es posible disparar la validacion de un paso concreto con `workflow_dispatch`.

Cada `validate-step-NN.yml` se dispara en `push`, `pull_request` y
`workflow_dispatch`. No llama al base: corre el validador localmente en el runner.

---

## Parte 3 -- Los validadores (scripts/validate-step-NN.py)

Un fichero Python por paso. Convencion: exit 0 si el paso esta completado, exit 1 si no.

Cada validador define:
- `EXPECTED_ARTIFACT` — el fichero que el estudiante tiene que modificar en ese paso.
- `REQUIRED_MARKERS` — lista de cadenas que deben aparecer en ese fichero para que
  el paso se considere completado.

Logica: si `EXPECTED_ARTIFACT` no existe, falla. Si existe pero falta alguno de
los `REQUIRED_MARKERS`, falla. Si todos estan presentes, imprime `STEP N VALID`
y devuelve exit 0.

Criterios para buenos marcadores:
- Deben aparecer de forma natural en el trabajo correcto del estudiante, no ser
  comentarios ni placeholders artificiales.
- Ninguno debe estar presente en el repo antes de que el estudiante haga nada.
  Si ya estan, el validador da falso positivo desde el primer push.
- Preferir pocos marcadores especificos sobre muchos genericos.

---

## Parte 4 -- La maquina de estados (scripts/tutorial_engine.py)

Usada exclusivamente por los tests funcionales. Simula el flujo completo del
tutorial (start → validate_step × N → complete → reset) sin ejecutar GitHub Actions.
No interviene en el flujo real de CI del estudiante.

Gestiona un fichero JSON de estado con los campos: `started`, `completed`,
`current_step`, `total_steps`. Los metodos principales son `start()`,
`validate_step(step)`, `complete()` y `reset()`.

---

## Parte 5 -- La configuracion del tutorial (.tutorial/config.yml)

Metadatos que los tests funcionales y el base leen para operar sin hardcodear
valores. Campos obligatorios:

| Campo | Descripcion |
|---|---|
| `tutorial.name` | Nombre completo del tutorial — debe coincidir con `tutorial-name` en todos los callers |
| `tutorial.level` | `foundations`, `professional` o `advanced` |
| `tutorial.total_steps` | Numero de pasos reales (sin contar el 0) — debe coincidir con `total-steps` en `test-tutorial.yml` |
| `tutorial.default_language` | Idioma del tutorial (`es` o `en`) |
| `tutorial.base_repository` | `ORG/security-tutorial-base` |

---

## Parte 6 -- Los ficheros de paso (.tutorial/steps/NN-nombre.md)

Un fichero Markdown por paso, incluyendo el paso 0. Convencion de nombre: numero
con dos digitos + guion + nombre-en-kebab-case (por ejemplo: `01-nombre-del-paso.md`).

El paso 0 (`00-introduccion.md`) es libre: explica el contexto, el objetivo del
tutorial y como se recorre. No tiene secciones obligatorias.

### Secciones obligatorias en los pasos 1 a N

`reusable-tutorial-tests.yml` comprueba que cada fichero de paso del 01 al N:

1. **Empiece con** `# Paso N. Titulo del paso` (exactamente ese formato).
2. **Contenga las 8 secciones** siguientes (pueden estar en cualquier orden):

| Seccion | Contenido esperado |
|---|---|
| `## Objetivo` | Una frase que resume que aprende o practica el estudiante |
| `## Contexto profesional` | Por que este paso importa en un entorno real (casos concretos, no teoria) |
| `## Explicacion tecnica` | Detalle tecnico necesario para hacer el cambio correctamente |
| `## Archivos que se modifican` | Lista de ficheros con descripcion de que parte se cambia |
| `## Accion esperada del usuario` | Instrucciones concretas: que escribir, donde, como ejecutar si aplica |
| `## Validacion automatica` | Que comprueba el workflow: archivo objetivo y marcadores esperados |
| `## Criterio de finalizacion` | Cuando se considera completado el paso |
| `## Enlace al siguiente paso` | `Siguiente paso: Paso N+1.` |

---

## Parte 7 -- El README.md estatico

El README del template es estatico, escrito a mano. Ninguna automatizacion lo
sobreescribe. Debe contener tres elementos que `reusable-tutorial-tests.yml`
comprueba en CI:

1. La cadena `Empezar tutorial` (boton badge o enlace de fork).
2. El enlace `../../actions/workflows/start.yml`.
3. Al menos un enlace a `.tutorial/steps/`.

Estructura recomendada: titulo, descripcion, boton de fork, seccion de acceso al
repo (crear desde template, volver al portal), seccion de gestion del progreso con
los 5 enlaces de workflows, tabla de pasos, y descripcion del paso 0.

Los enlaces `../../actions/workflows/NOMBRE.yml` funcionan tanto en el template
como en el fork porque GitHub los resuelve relativos al repositorio actual.

---

## Parte 8 -- Gestion de credenciales en los workflows

### 8.1 Credenciales del sistema de tutorial

El sistema de progresion (start, completion, validate, reset) solo necesita
`GITHUB_TOKEN`. Es el token automatico que GitHub inyecta en cada ejecucion de
Actions. No requiere configuracion adicional.

El permiso minimo necesario en los workflows que escriben en el repositorio es
`contents: write`. Se declara a nivel de job, no a nivel global del workflow.

### 8.2 Credenciales de las herramientas que el tutorial enseña

Si el tutorial cubre herramientas que requieren tokens propios (escaners externos,
APIs de tercero, registros de contenedores, proveedores cloud, etc.), esos secretos
deben documentarse explicitamente en el README del template para que el estudiante
los configure antes de empezar.

El estudiante los configura en su fork via la interfaz web (Settings > Secrets and
variables > Actions) o desde CLI con `gh secret set NOMBRE_DEL_TOKEN --repo ORG/REPO`.

### 8.3 Como pasar secretos de un caller a un reusable

Los secretos nunca se hardcodean en el YAML. Se pasan via el bloque `secrets:`
del job caller al workflow reutilizable:

- En el caller: declarar `secrets: mi_token: ${{ secrets.MI_TOKEN }}` en el job.
- En el reusable: declarar el secreto bajo `on: workflow_call: secrets:` con
  `required: true` o `required: false` segun si es obligatorio.

Si un secreto es opcional, el reusable debe comprobar si tiene valor antes de
usarlo. Un secreto vacio no debe hacer fallar el workflow.

### 8.4 Secretos compartidos entre repos

Cuando varios repos del mismo tutorial comparten credenciales (por ejemplo, un
token de escaneo reutilizado en todos los templates), se configuran como organization
secrets en lugar de repo secrets. El workflow los consume de la misma forma; la
diferencia es el alcance de configuracion y de rotacion.

### 8.5 Reglas de seguridad

- Nunca imprimir el valor de un secreto en los logs.
- Nunca almacenar secretos en ficheros del repositorio, aunque sean temporales.
- Los secretos de herramientas externas deben rotar segun la politica de la
  organizacion. Documentar el periodo de rotacion en `docs/credential-management-modern.md`.
- Si el tutorial incluye ejemplos de credenciales en ficheros de codigo (para
  ensenar a identificarlas), esas cadenas deben ser claramente ficticias y no
  activar los detectores de secretos. Ver `docs/sensitive-files-catalog.md` para
  la lista de patrones que los escaner reconocen.

### 8.6 Permisos del GITHUB_TOKEN

Por defecto el GITHUB_TOKEN tiene permisos de lectura en la mayoria de recursos
y escritura solo en `contents`. Si un workflow necesita permisos adicionales hay
que declararlos explicitamente en el job:

| Permiso | Cuando se necesita |
|---|---|
| `contents: write` | Modificar ficheros del repo (README, artefactos del tutorial) |
| `issues: write` | Crear o cerrar issues de progreso |
| `security-events: write` | Subir resultados SARIF a Code Scanning |
| `pull-requests: write` | Comentar en PRs del estudiante |

El principio es el minimo privilegio: declarar solo los permisos que el job
necesita, nunca `permissions: write-all`.
---

## Parte 9 -- Procedimiento de validacion del sistema completo

### 9.1 Verificar estructura localmente

Simular el mismo Python que ejecuta `reusable-tutorial-tests.yml`: comprobar que
existen los 5 workflows requeridos, `.tutorial/config.yml`, y los ficheros de paso
del 00 al N.

### 9.2 Confirmar que todos los validadores fallan en el estado inicial

Correr cada `scripts/validate-step-NN.py` sobre el repo sin modificar. Todos deben
imprimir `STEP VALIDATION FAILED`. Si alguno imprime `STEP N VALID`, el marcador
ya esta en el repo y el estudiante no tendra nada que hacer en ese paso.

### 9.3 Confirmar que los tests funcionales pasan

Correr `scripts/test_tutorial_functional.py` con `pyyaml` instalado. Debe pasar
en el estado inicial del repo. Si falla, hay un problema de estructura: workflows
faltantes, secciones faltantes en los steps, o enlaces incorrectos en el README.

### 9.4 Verificacion end-to-end con un fork de prueba

1. Hacer fork del template en una cuenta de prueba.
2. Confirmar que el README muestra el Paso 0 (la landing page estatica).
3. Ir a Actions > Start Tutorial > Run workflow.
4. Confirmar que el tutorial avanza al paso 1.
5. Aplicar la modificacion del paso 1 y hacer push.
6. Confirmar que `validate-step-01.yml` pasa en ese push.
7. Repetir hasta el paso final.
8. Ejecutar Actions > Completion.
9. Confirmar que se genera la evidencia de finalizacion.

---

## Checklist antes de publicar el template

```
[ ] .tutorial/config.yml existe con name, level, total_steps, base_repository
[ ] Existe exactamente un fichero 00-*.md en .tutorial/steps/
[ ] Existen ficheros 01-*.md hasta NN-*.md para todos los pasos
[ ] Cada fichero de paso empieza con "# Paso N. Titulo"
[ ] Cada fichero de paso contiene las 8 secciones obligatorias
[ ] Existe un validate-step-NN.yml por cada paso (del 01 al N)
[ ] Ningun REQUIRED_MARKERS esta presente en el repo antes de empezar
[ ] Todos los validate-step-NN.py fallan en el estado inicial del repo
[ ] functional-tests.yml pasa en el estado inicial del repo
[ ] test-tutorial.yml pasa en CI
[ ] README.md contiene "Empezar tutorial", enlace a start.yml y a .tutorial/steps/
[ ] Los thin callers usan el ORG/security-tutorial-base y la rama correctos
[ ] tutorial-name en todos los callers coincide con el name en config.yml
[ ] total-steps en test-tutorial.yml coincide con total_steps en config.yml
[ ] Los secretos se pasan por secrets: en el workflow, nunca hardcodeados en YAML
[ ] La verificacion end-to-end (Parte 9.4) se ha completado con un fork de prueba
```
