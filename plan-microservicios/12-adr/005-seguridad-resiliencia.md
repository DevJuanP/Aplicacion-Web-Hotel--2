# ADR-005 — Seguridad JWT con rol + resiliencia con CB (incluye demo feriado)

- Estado: aceptado (Q10/Q11).
- Contexto: legacy JWT sin rol + `permitAll /persona,/producto` + caída total por reportes.
- Decisión: JWT con `idPersona, rol`, Gateway valida, `@PreAuthorize` por servicio. Resilience4j `catalogCB/identityCB/otaCB + Retry(GET) + RateLimiter(catalog 200rps) + Bulkhead(reporting) + TimeLimiter 2s`, fallbacks 503 controlados.
- Demo: `docker stop reporting/catalog/ota-mock` en clase, Grafana muestra `OPEN`, booking sigue.
- Alternativas: sin CB / roles en Gateway solo — rechazado (no cumple puntos 5,6 ni lore 5).
