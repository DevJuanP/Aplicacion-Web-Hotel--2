# 06 — Seguridad en microservicios

## Modelo

- Único emisor: `identity-service` (`POST /api/auth/login` igual que legacy, `BCrypt`, `exp 100min`).
- Token con claims (rompe legacy que solo guardaba `sub=correo`):
  `sub=correo, idPersona, rol=ADMINISTRADOR|EMPLEADO|CLIENTE, ver=1`.
- `gateway` = `oauth2ResourceServer(jwt)`, valida firma `jwt.secret` compartido vía `config-server`. Si falta/inválido → 401. Propaga `X-User-Id, X-User-Rol, X-User-Correo` a downstream. No re-valida cada servicio la firma salvo `booking/sales` (defensa en profundidad, misma secret).
- Cada servicio: `SecurityConfig STATELESS`, `permitAll` solo `/actuator/health`, `/internal/**` protegido por `X-Internal` secret + mTLS opcional fase 2. Todo `/api/**` con `@PreAuthorize("hasRole('EMPLEADO')")` etc.

## Matriz (cerrar hueco legacy `permitAll /persona,/producto`)

| Ruta Gateway | JWT | Rol |
|---|---|---|
| `POST /api/auth/**` | no | — |
| `GET /public/catalog/**` | no | — (landing, RateLimiter alto) |
| `GET /api/catalog/**` | sí | CLIENTE+ |
| `PUT/POST /api/catalog/**` | sí | EMPLEADO+ |
| `/api/booking/**, /api/recepcion/**` | sí | EMPLEADO (CLIENTE solo `POST /api/booking/reservar` web) |
| `/api/ventas/**` | sí | EMPLEADO |
| `/api/reportes/**` | sí | ADMINISTRADOR |
| `/internal/**` | secret interno, no por Gateway | — |

## Tareas por dev

- P2 (identity): agregar `rol` al JWT, endpoint `GET /internal/clientes/*`, cerrar `permitAll`, script `DataInitializer` con 3 sedes + roles.
- Gateway (P1): `JwtAuthFilter`, `roles` en `application.yml`, CORS `4200+3000`.
- Resto: copiar `JwtAuthenticationFilter` legacy pero leyendo `rol` del claim, activar `methodSecurity`.

## Riesgo curso

Google/Facebook login legacy tiene `clientId` placeholder → desactivar en microservicios, dejar solo `login correo/clave` para demo. Documentar como deuda.
