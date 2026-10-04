# 11 — Reparto 5 devs × 2 semanas (con agentes IA + skills)

## Equipo

- **P1 Infra/Gateway:** config+eureka+gateway, Docker/K8s base, RateLimiter. Entrega URLs + `compose up`.
- **P2 Identity+Loyalty:** identity (JWT con rol, resolve-or-create) + loyalty (consume `stay.finished`, `+10pts/noche`). Tablas `PERSONA/TIPO/LOYALTY`.
- **P3 Catalog:** `SEDE/TARIFA/HABITACION`, CRUD + `/internal/*` + `price-changed/viewed` Kafka. Dueño seeds multisede.
- **P4 Booking+Sales (crítico):** booking saga + sales (carrito→venta) + Feigns + CB/fallbacks. Dueño demo `kill reporting/catalog`.
- **P5 Integration+Reporting+Obs:** integration (pago+OTA mock, Rabbit) + reporting (agregador+Bulkhead) + Prometheus/Grafana/Loki/Zipkin + dashboards + JMeter.

Frontend landing: P3 o P5 (3 vistas) en semana 2; admin: todos migran su `environment.ts`.

## Cronograma

**Semana 1 — infra + CRUDs + Feign (sin brokers aún con mock):**
- D1-2: P1 levanta config/eureka/gateway+compose Postgres. Resto crea esqueleto Spring Boot por servicio copiando `entity/dto/repository/service` legacy (strangler). Congelar DTOs 03.
- D3-4: CRUDs por servicio verdes vía Gateway + JWT básico. P3 crea `SEDE/TARIFA` + seeds 3 sedes.
- D5-7 (clase): Feigns 03 con fallback stub + `@PreAuthorize` base. DoD S1: `compose up`, login → reservar 1 sede → venta → reporte parcial, todo por `:8080`.

**Semana 2 — async + transversales + demo:**
- D8-9: Rabbit (P4+P5) `reservada/cerrada/pago` + DLQ. Kafka (P3+P2+P5) `viewed/price-changed/stay.finished`. Loyalty suma puntos.
- D10-11: CB/Retry/RL/Bulkhead (P4) + seguridad roles por sede (P2+P1) + obs (P5) + landing (P3).
- D12-13: Docker finales + manifests Kind + HPA + JMeter 200rps + dashboards.
- D14: Ensayo demo feriado: `kill reporting` → booking sigue; `kill catalog` → fallback mostrador; `kill OTA` → DLQ. Grabar video backup.

## DoD global (para aprobar)

- `docker compose up` 10/10 healthy, Postman collection verde por Gateway.
- JWT con rol, `CLIENTE` no accede a `/reportes`.
- `catalogCB OPEN` visible en Grafana + fallback 503 controlado.
- DLQ con mensaje OTA fallido sin tumbar caja.
- `kubectl apply -k k8s/` en Kind levanta + HPA escala.
- Skills IA: crear `skillしてください catalog-crud`, `booking-saga`, `feign-cb`, `kafka-events` a partir de estos md para que agentes generen código homogéneo.

## Riesgos y recortes

- Si atrasan: fusionar `loyalty→identity` y `integration→booking` (bajar a 5 runtime) sin perder los 9 techs (brokers quedan igual).
- No tocar `sp_*` legacy más que para leer lógica; no intentar saga distribuida XA.
- Landing mockeable con JSON estático si falta tiempo, pero Gateway público debe existir.
