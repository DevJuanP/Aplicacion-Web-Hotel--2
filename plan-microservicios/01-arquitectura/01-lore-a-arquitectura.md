# 01 — Del lore a la arquitectura

Monolito actual: 1 hotel, Spring Boot 3.5/Java 21, 12 tablas, 59 endpoints, JWT sin roles (`CONTRATO_API.md`).

## Lore → decisión

**1. De 1 hotel a cadena (3/10/50 sedes). Clientes y fidelización globales, tarifas por sede, redeploy con miedo.**
→ DB-per-service + `SEDE` + `TARIFA{sede,categoria,temporada}` dueña de catalog. Cambio de tarifa = `PUT /internal/tarifas` + evento `catalog.price-changed` (Kafka), sin redeploy booking. `PERSONA/LOYALTY` globales sin `sede_id`.

**2. Nuevo canal digital: web+app, lectura 100x escritura. Si se cae app, recepción física sigue.**
→ Separar `catalog-service` (escalable lectura, cacheable, RateLimiter alto en Gateway) de `booking-service` (crítico, réplicas propias, CB). Landing pública solo lee catalog. Recepción = `booking` aislado con fallback si catalog lento.

**3. Integraciones externas: OTAs + pagos, ritmo distinto, SLA propio. Falla OTA no tumba caja.**
→ `integration-service` propio (anti-corruption layer). Habla con Booking/Expedia mock + pasarela mock vía RabbitMQ `ota.sync.request` con retry+DLQ. Pago `pago.confirmado` por RabbitMQ con ACK. Si OTA cae, CB abre y caja (`sales`) sigue.

**4. Nuevas líneas: restaurante, eventos, spa, cada una con inventario y facturación.**
→ `sales-service` dueño de `PRODUCTO+VENTA+DETALLE+carrito` (fase 1: consumos habitación). Eventos/spa quedan como extensión futura del mismo bounded context, no nuevos servicios en 2 semanas. Dejar `VENTA.detalles` extensible con `tipo: MINIBAR/RESTAURANTE/EVENTO`.

**5. Viernes feriado: deploy reportes tumba todo, cola en recepción.**
→ `reporting-service` stateless, solo lectura/agregación, Bulkhead + sin llamadas sync en camino crítico. Demo obligatoria: `docker kill reporting` y booking sigue vendiendo. Deploy independiente por servicio + Gateway + HPA.

## Principios congelados

- DB-per-service, sin JOIN cross-service, IDs lógicos + validación por Feign/evento.
- Sync (Feign) solo para validación puntual con CB; todo lo demás async.
- SPs cross-domain (`sp_RegistrarRecepcion/Venta/Salida`) no se migran tal cual → se convierten en sagas (ver 05).
- Gateway único entrypoint. Nada llama directo entre front y servicios.
