# ADR-002 — RabbitMQ + Kafka (no uno solo)

- Estado: aceptado (Q3/Q9).
- Contexto: lore pide comandos críticos (pago/OTA) y streaming masivo (views/precios/puntos).
- Decisión: RabbitMQ para `booking.reservada/cerrada, pago.confirmado, ota.sync` (ACK+DLQ). Kafka para `catalog.viewed/price-changed, stay.finished` (fan-out loyalty+reporting).
- Alternativas: solo Kafka o solo Rabbit — rechazado (Kafka sobra para ACK rápido, Rabbit se satura con 100x views).
- Consecuencias: operar 2 brokers en compose/K8s; P5 dueño de ambos.
