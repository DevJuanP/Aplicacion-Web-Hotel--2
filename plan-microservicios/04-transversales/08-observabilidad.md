# 08 — Observabilidad

Stack demo (todo en compose, perfil `obs`): `Micrometer + Prometheus + Grafana + Loki + Zipkin`.
Cada servicio: `micrometer-registry-prometheus`, `micrometer-tracing-bridge-brave`, `loki-logback-appender`.

## Qué exponer

- `GET /actuator/health,prometheus,metrics` (Gateway expone agregada).
- Métricas: `http_server_requests_seconds`, `resilience4j_circuitbreaker_calls`, `resilience4j_retry_calls`, `rabbitmq_consumed`, `kafka_consumer_lag`, `jvm_memory_used`.
- Logs JSON con `traceId/spanId, servicio, sedeId, reservaId` → Loki (`{servicio="booking"}`).
- Traces: `gateway → booking → catalog/identity` vía `spring-cloud-sleuth Brave → Zipkin :9411`.

## Dashboards mínimos (Grafana provisionado)

1. `Golden signals` por servicio: RPS, p95, errores 5xx.
2. `Resiliencia`: estado CB (closed/open/half), retries, rate-limit rejects.
3. `Brokers`: `rabbitmq queue depth + DLQ`, `kafka lag por group`.
4. `Negocio`: reservas/min por sede, tarifa media, puntos loyalty emitidos.

## Tareas P5

- Agregar deps + `management:tracing+metrics` en `config-server` para heredar.
- `prometheus.yml` con targets `gateway:8080, booking:8083...`, `loki-config.yml`, `grafana/dashboards/*.json`.
- DoD: `http://localhost:3000` muestra los 4 dashboards + trace completo de `POST /api/booking/reservar` en Zipkin.
