# ADR-003 — DB per service + SEDE/TARIFA

- Estado: aceptado (Q4/Q8).
- Contexto: 1 hotel → cadena, tarifas por sede sin redeploy, clientes/loyalty globales.
- Decisión: 1 schema por servicio, `SEDE+TARIFA` en catalog, `sede_id` lógico en booking/habitación, `LOYALTY/PAGO/OTA_SYNC` nuevas. Sin FK cross-service. SPs cross-domain → sagas.
- Alternativas: DB compartida — rechazado (acopla deploys, rompe lore 1 y 5).
- Consecuencias: duplicar `sede_id`, seeds multisede, reporting por agregación.
