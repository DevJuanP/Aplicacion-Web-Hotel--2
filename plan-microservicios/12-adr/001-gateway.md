# ADR-001 — API Gateway único (Spring Cloud Gateway)

- Estado: aceptado (Q3).
- Contexto: front web/app + admin necesitan un entrypoint, JWT centralizado y RateLimiter para 100x lectura.
- Decisión: `Spring Cloud Gateway` en `:8080`, descubre vía Eureka, valida JWT, propaga `X-User-*`.
- Alternativas: sin gateway (llamada directa) — rechazado (rompe lore 2, expone 7 puertos, sin RL central).
- Consecuencias: punto único de fallo → desplegar 2 réplicas + HPA.
