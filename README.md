# Backend - API REST con Node.js y Express

## Descripción

Backend API desarrollado en JavaScript con Node.js y Express. Esta versión forma parte de la Fase 2 del proyecto institucional para Innovatech Chile, migrando la infraestructura hacia un entorno de microservicios robusto. La API gestiona la lógica de negocio y la persistencia de datos mediante una base de datos MySQL, operando de forma aislada dentro de contenedores en AWS.

## Versiones y Herramientas Requeridas

### Infraestructura y DevOps

- **Docker**: Versión 20.10+ (Para creación de imágenes y contenedores).
- **Docker Compose**: Versión 2.0+ (Para orquestación del stack de servicios).
- **GitHub Actions**: Para la ejecución del pipeline CI/CD automatizado.

### Lenguajes y Runtime

- **Node.js**: Versión 18.0.0 o superior - Elegida por su estabilidad y compatibilidad con la imagen base utilizada en el Dockerfile.
- **npm**: Versión 8.0.0 o superior (incluido con Node.js)

### Dependencias Principales

- **express**: ^4.18.2 - Framework web para la creación de la API REST.
- **cors**: ^2.8.5 - Permite que el Frontend (en subred pública) se comunique con esta API (en subred privada) sin bloqueos de seguridad del navegador.
- **mysql2**: ^3.6.0 - Driver para la conexión con el contenedor de base de datos MySQL.
- **dotenv**: ^16.3.1 - Permite gestionar variables de entorno y Secrets de AWS de forma segura, evitando exponer credenciales en el código fuente.

### Dependencias de Desarrollo

- **nodemon**: ^3.0.1 - Utilizado exclusivamente en el entorno de desarrollo local para agilizar el ciclo de cambios.

## Instalación

Para garantizar la paridad entre el entorno de desarrollo y la instancia EC2 de Innovatech, se utiliza Docker:

```bash
# Construir imagen y levantar stack completo (Back + DB)
docker-compose up --build -d
```

```bash
# Instalar dependencias
npm install
```

```bash
# Instalar dependencias de desarrollo
npm install --save-dev nodemon
```

## Configuración

El sistema utiliza un archivo .env para gestionar parámetros críticos y Secrets. Para producción en AWS, estos valores se configuran en GitHub Secrets y se inyectan al contenedor.

1. Copiar el archivo de variables de entorno:

```bash
cp .env.example .env
```

2. Configuración del archivo .env:

- **PORT**: 3000
- **DB_HOST**: localhost
- **DB_USER**: root
- **DB_PASSWORD**: tu_password_aqui
- **DB_NAME**: proyecto_db
- **DB_PORT**: 3306

## Ejecución

Despliegue con Docker (Producción / AWS)

Este es el método principal para asegurar la paridad de entornos y el aislamiento del servicio:

```bash
# Levantar el stack completo (Backend + Base de Datos)
docker-compose up -d --build
```

```bash
# Para producción
npm start

# Para desarrollo (con recarga automática)
npm run dev
```

## Diseño de Contenedorización

Se aplicaron las siguientes buenas prácticas en el Dockerfile:

- **Multi-stage Build**: Dividido en etapas (builder y runner) para reducir el peso de la imagen y no incluir dependencias de desarrollo en producción.

- **Usuario No-Root**: Se creó un usuario de sistema para ejecutar la aplicación, evitando riesgos de seguridad por escalada de privilegios.

- **Optimización de Capas**: Uso de .dockerignore y agrupación de comandos RUN para minimizar el almacenamiento.

## Persistencia de datos

Se ha implementado persistencia para la base de datos utilizando Named Volumes en Docker.

Configuración: db_data:/var/lib/mysql.

Justificación: Se seleccionó esta estrategia sobre los bind mounts para garantizar que los datos de Innovatech Chile permanezcan íntegros incluso si el contenedor es destruido, actualizado o recreado por el pipeline de CI/CD.

## Endpoints de la API

La API expone los siguientes recursos para la integración con el Frontend de la marca:

### Usuarios
- `GET /api/usuarios` - Obtener todos los usuarios
- `POST /api/usuarios` - Crear un nuevo usuario
- `PUT /api/usuarios/:id` - Actualizar un usuario existente
- `DELETE /api/usuarios/:id` - Eliminar un usuario

### Ejemplo de uso

Para verificar que el contenedor del Backend responde correctamente desde la instancia EC2 o entorno local:

```bash
# Obtener todos los usuarios
curl http://localhost:3000/api/usuarios

# Crear un nuevo usuario
curl -X POST http://localhost:3000/api/usuarios \
  -H "Content-Type: application/json" \
  -d '{"nombre":"Juan Pérez","email":"juan@example.com","edad":25}'
```

## Puertos Requeridos

### Para funcionamiento en contenedor:

- **Puerto 3000**: Expuesto para consumo de la API.

- **Puerto 3306**: Cerrado al exterior, solo accesible internamente por la red de Docker.

- **Seguridad**:** Solo el contenedor del Frontend (en subred pública) tiene permiso para comunicarse con este Backend, asegurando el aislamiento de los datos.

## Pipeline de CI/CD

El flujo automatizado en .github/workflows/main.yml se activa mediante push en la rama deploy:

- **Build & Push**: Construye la imagen y la publica en Docker Hub (elegido por su facilidad de integración y gestión de imágenes públicas/privadas).

- **Continuous Deployment**: Se conecta vía SSH a la instancia EC2 para hacer un pull de la nueva imagen y reiniciar los servicios sin intervención manual.

- **Gestión de Secrets**: Se utilizan GitHub Secrets para ocultar las credenciales de AWS y el token del Registry, cumpliendo con los estándares de seguridad de Innovatech Chile.

## Principios DevOps Aplicados

- **Automatización**: Eliminación de errores manuales mediante el pipeline.

- **Mantenibilidad**: La estructura modular permite actualizar la API sin afectar la base de datos.

-**Escalabilidad**: El diseño permite replicar contenedores del backend tras un balanceador de carga si el tráfico de la empresa aumenta.

## Estructura del Proyecto
```
backend/
├── .github/workflows/main.yml/deploy.yml  # Pipeline de automatización CI/CD
├── Dockerfile                  # Construcción Multi-stage y Usuario No-Root
├── docker-compose.yml          # Orquestación de servicios y Volúmenes
├── server.js          # Punto de entrada de la aplicación
├── package.json       # Gestión de dependencias y scripts
├── .env.example       # Plantilla de configuración de entorno
├── .env              # Variables de entorno (crear manualmente)
└── README.md         # Documentación técnica del proyecto
```

## Notas de Operación

- **Persistencia**: La información se almacena en el volumen nombrado db_data. Si el contenedor se detiene, los datos permanecerán seguros.
- **Producción**: En AWS, asegúrese de que el Security Group permita tráfico entrante al puerto 3000 solo desde la IP/SG del servidor Frontend.
- **Automatización**: Toda modificación técnica debe ser enviada a la rama deploy para su reflejo automático en la infraestructura Cloud de Innovatech Chile.
