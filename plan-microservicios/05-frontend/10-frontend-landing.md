# 10 — Frontend: landing cadena + admin

## Decisión

- `web-publica/` nueva (Angular, mismo skill que ya dominan, 1 dev): 3 rutas, sin JWT, solo `GET` vía Gateway público. Justifica lore 2.
- `hotel-admin/` = `cibertec-angular/hotel` actual migrado a Gateway (`environment.ts → http://localhost:8080`), con JWT. Sin rewrite.

## Landing mínima (DoD)

- `/` home cadena: hero + 3 sedes (GET `/public/catalog/sedes`) + fotos (`IMAGEN_HABITACION.urls`).
- `/sedes/:id`: detalle sede + categorías + `TARIFA` vigente.
- `/buscar?sede&desde&hasta&personas`: `GET /public/catalog/disponibilidad?sedeId&desde&hasta` (RateLimiter 200rps, cache 30s en Gateway). Botón `Reservar` → `POST /api/booking/reservar` (pide login CLIENTE).
- Si `catalog` caído → landing muestra caché + banner, admin/recepción sigue (resiliencia visible).

## Admin (cambios mínimos)

1. `src/environments/environment.ts`: `apiUrl=http://localhost:8080/api`.
2. `venta.service.ts:28`: usar `/venta/buscar/${id}` (bug §11 CONTRATO_API).
3. `recepcion.service registrar-salida`: tipar `ApiResponse<string>` no `boolean`.
4. Interceptor: adjuntar `Bearer`, manejar `503 CATALOG_DOWN` con toast "modo mostrador".

## Tablas que la alimentan

`SEDE`, `HABITACION+urlsImagenes`, `TARIFA`. Seeds con fotos placeholder por sede.
