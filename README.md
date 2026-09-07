# 🏨 Sistema de Gestión Hotelera

Aplicación web para la administración integral de un hotel: usuarios, clientes, habitaciones, categorías, pisos, recepciones, ventas y productos.

**Grupo 7 · Cibertec**

## Stack

| Frontend | Backend | Base de Datos |
|---|---|---|
| Angular, TypeScript, Bootstrap 5, SweetAlert2 | Spring Boot, Spring Security, JWT, JPA/Hibernate, Maven | PostgreSQL |

## Funcionalidades

- Autenticación JWT
- Gestión de usuarios, clientes, habitaciones, categorías y pisos
- Registro de recepciones, ventas y salida de habitaciones
- Control de habitaciones ocupadas y gestión de productos

## Estructura

```text
Proyecto Ht/
├── FrontendHotel/
├── BackendHotel/
└── hotel.sql
```

## Instalación

```bash
git clone https://github.com/Yax-CalleCas/Sistema-de-Gesti-n-Hotelera.git
```

**1. Base de datos** — Crear una BD en PostgreSQL y ejecutar `hotel.sql`.

**2. Backend** — Editar `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/nombre_bd
spring.datasource.username=postgres
spring.datasource.password=tu_password
```
Ejecutar:
```bash
mvn clean install
mvn spring-boot:run
```
📍 `http://localhost:8081`

**3. Frontend**
```bash
cd hotel
npm install
ng serve
```
📍 `http://localhost:4200`

## Acceso

Registrar usuarios desde el sistema o usar los ya existentes en la base de datos.

## Licencia

Proyecto académico — Cibertec.
