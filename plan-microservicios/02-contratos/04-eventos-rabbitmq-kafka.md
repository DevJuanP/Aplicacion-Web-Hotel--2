# 04 — Eventos: RabbitMQ (comandos) vs Kafka (streaming)

## Principio (lore 2 y 3)

- **RabbitMQ = comandos que no se pueden perder, bajo volumen, con ACK/DLQ.** Reserva creada, pago, sync OTA.
- **Kafka = hechos de alto volumen / replay / fan-out.** Views, cambios precio, estadía terminada → loyalty + reporting.
- **Feign = validación puntual.** Nunca para broadcast.

## 4.1 RabbitMQ (direct/topic, durable, `spring-rabbit`)

Vhost `/hotel`, usuario `hotel`.

| Exchange | Routing key / cola | Prod → Cons | Payload | Retry/DLQ |
|---|---|---|---|---|
| `hotel.booking` (topic) | `booking.reservada` → `q.booking.created` | booking → integration, sales | `{reservaId,sedeId,clienteId,habitacionId,desde,hasta,total}` | 3x + `q.booking.created.dlq` |
| `hotel.booking` | `booking.cerrada` → `q.booking.closed` | booking → sales, integration | `{reservaId,totalAlojamiento,totalConsumos,penalidad}` | 3x + DLQ |
| `hotel.payments` (direct) | `pago.confirmado` → `q.payments.confirmed` | integration → booking, sales | `{pagoId,reservaId,monto,estado:PAGADO/RECHAZADO}` | manual ACK, DLQ |
| `hotel.ota` (topic) | `ota.sync.request` → `q.ota.sync` | booking/catalog → integration | `{sedeId,habitacionId,desde,hasta,accion:BLOCK/RELEASE}` | TTL 30s + DLQ, CB a OTAs mock |

Demo clase: publicar `ota.sync.request` con OTA mock caído → DLQ crece, caja sigue.

## 4.2 Kafka (3 particiones, ret 7d, `spring-kafka`)

Bootstrap `kafka:9092`. Prefijo `hotel.*`.

| Topic | Prod → Cons | Evento ejemplo | Uso |
|---|---|---|---|
| `hotel.catalog.viewed` | gateway/catalog → reporting | `{sedeId,habitacionId,ts,canal:WEB/APP}` | medir 100x lectura (lore 2) |
| `hotel.catalog.price-changed` | catalog → gateway-cache, reporting, integration(OTA) | `{sedeId,categoriaId,precio,temporada}` | invalidar caché, re-publicar a OTA |
| `hotel.stay.finished` | booking → loyalty, reporting | `{reservaId,clienteId,sedeId,noches,total}` | `loyalty: +10pts/noche`, reporting ingest |

Consumer groups: `loyalty-grp`, `reporting-grp`, `ota-grp`. `enable-auto-commit:false`, `AckMode.MANUAL`.

## 4.3 Qué NO hacer

- No publicar `VENTA` por Feign en loop (usar `booking.cerrada`).
- No usar Kafka para `pago.confirmado` (necesita ACK transaccional rápido → Rabbit).
- No usar Rabbit para `viewed` (saturaría colas).
