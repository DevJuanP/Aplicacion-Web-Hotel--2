# 07 — Resiliencia (incluye CircuitBreaker)

Stack: `resilience4j-spring-boot3` + `spring-boot-starter-aop`. Todo Feign envuelto. Gateway con `CircuitBreaker + Fallback`.

## Config base (copiar a cada `application.yml`)

```yaml
resilience4j:
  circuitbreaker:
    instances:
      catalogCB: { slidingWindowSize: 10, failureRateThreshold: 50,
        waitDurationInOpenState: 30s, permittedCallsInHalfOpen: 2 }
      identityCB: { slidingWindowSize: 10, failureRateThreshold: 60, waitDurationInOpenState: 20s }
      otaCB: { slidingWindowSize: 5, failureRateThreshold: 50, waitDurationInOpenState: 60s }
  retry:
    instances:
      feignGet: { maxAttempts: 3, waitDuration: 200ms }
  ratelimiter:
    instances:
      catalogRL: { limitForPeriod: 200, limitRefreshPeriod: 1s, timeoutDuration: 0 }
      bookingRL: { limitForPeriod: 50, limitRefreshPeriod: 1s }
  timelimiter:
    instances:
      feignTL: { timeoutDuration: 2s }
  bulkhead:
    instances:
      reportingBH: { maxConcurrentCalls: 5, maxWaitDuration: 0 }
```

## Comportamiento por caso (demo del viernes feriado)

- `booking → catalog.lock` con `@CircuitBreaker(name=catalogCB, fallbackMethod=lockFallback)`:
  `lockFallback → 503 {code: CATALOG_DOWN, message: "Recepción manual activa, intente en mostrador"}`. Recepción física (mismo servicio, endpoint local) sigue listando/creando sin catalog si `?modo=offline`.
- `booking → identity` caído → `identityCB` abre, reservas nuevas rechazadas pero check-out/cobro en curso sigue (usa snapshot local).
- `integration → OTA mock` caído → `otaCB` abre, eventos van a `q.ota.sync.dlq`, reintento nocturno. Caja no se bloquea.
- `gateway → reporting` lento → `TimeLimiter 5s` + `Bulkhead`, devuelve `504` solo en reportes, resto ok. Probar con `docker stop reporting-service` en vivo.
- Rabbit: `retry 3x + DLQ`, Kafka: `SeekToCurrentErrorHandler + DLT topic`.

## Qué medir en clase (JMeter)

- `GET /public/catalog/disponibilidad` 200rps → `catalogRL` no debe tumbar booking.
- Matar `catalog` 30s → `catalogCB` OPEN en Grafana, booking devuelve fallback, al recuperar → HALF_OPEN → CLOSED.
- DoD: screenshot Grafana `circuitbreaker_calls{state=open}` + log fallback.
