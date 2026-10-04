# 02 — Servicios y bounded context

## Runtime funcionales (7)

| Servicio | Puerto | Dueño tablas | Origen legacy a copiar | Escala |
|---|---|---|---|---|
| `identity-service` | 8081 | `PERSONA, TIPO_PERSONA` | `Persona/TipoPersona/Login/SocialLoginController + JwtService, CustomUserDetailsService, DataInitializer` | 1-2 réplicas |
| `catalog-service` | 8082 | `SEDE*, HABITACION, IMAGEN_HABITACION, PISO, CATEGORIA, ESTADO_HABITACION, TARIFA*` | `Habitacion/Piso/Categoria/EstadoHabitacionController` | 2-5 réplicas (lectura) |
| `booking-service` ⭐ crítico | 8083 | `RECEPCION (+sede_id)` | `RecepcionController + sp_RegistrarRecepcion/Salida` → saga | 2-5 réplicas, HPA CPU 70% |
| `sales-service` | 8084 | `PRODUCTO, VENTA, DETALLE_VENTA, carrito` | `Producto/Venta/CarritoController + sp_RegistrarVenta` | 2 réplicas |
| `loyalty-service` (nuevo) | 8085 | `LOYALTY{persona_id,puntos,nivel}` | nuevo, consume `stay.finished` | 1 réplica |
| `integration-service` (nuevo) | 8086 | `PAGO{id,reserva_id,proveedor,estado,monto}, OTA_SYNC{id,sede_id,estado,payload}` | nuevo ACL | 1-2 réplicas |
| `reporting-service` | 8087 | ninguna (read-model, replica vía Kafka) | `ReporteController + fn_*` → agregador Feign + consumidor Kafka | 1 réplica, Bulkhead |

`*` = tabla nueva (ver 05).

## Infra Spring Cloud (3)

| Componente | Puerto | Rol |
|---|---|---|
| `config-server` | 8888 | `spring-cloud-config-server` native/git, todos leen `application.yml` por perfil |
| `discovery` (Eureka) | 8761 | registro `ms-*`, Feign usa `lb://` |
| `gateway` | 8080 | `spring-cloud-gateway`, única URL pública, valida JWT, RateLimiter, `StripPrefix`, CB por ruta |

## Reglas de frontera

- `booking` guarda solo `idCliente, idHabitacion, sede_id` + snapshot `precio_noche, numero`. No JOIN a `PERSONA/HABITACION`.
- `sales` guarda solo `idRecepcion` lógico. Expone `GET /ventas?recepcion=`.
- `catalog` es único que puede crear `SEDE/TARIFA/HABITACION`.
- `identity` es único que emite JWT y hashea `clave` (BCrypt).
- `reporting` nunca es llamado por `booking/sales` en camino crítico; él llama o consume.

## Puertos y rutas Gateway (congelar)

- `GET /api/catalog/** → lb://catalog-service`
- `POST /api/booking/**, /api/recepcion/** → lb://booking-service`
- `GET/POST /api/ventas/**, /api/productos/** → lb://sales-service`
- `POST /api/auth/** → lb://identity-service`
- `GET /api/reportes/** → lb://reporting-service` (Bulkhead, timeout 5s)
- `GET /public/catalog/**` sin JWT (landing)
