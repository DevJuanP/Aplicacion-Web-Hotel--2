# ADR-004 — Monorepo nuevo, legacy intacto (strangler)

- Estado: aceptado (Q5).
- Contexto: 5 devs, 2 semanas, agentes IA, necesidad de Feign/Config compartidos.
- Decisión: monorepo `hotel-chain/` Maven multi-módulo + `docker-compose.yml` + `k8s/` + `docs/`. Este repo `Aplicacion-Web-Hotel--2` congelado como `legacy-ref`, copiar paquetes por dominio.
- Alternativas: modificar in-place / polyrepos — rechazado (miedo a romper demo, infierno permisos).
- Consecuencias: copiar `entity/dto` y adaptar `sede_id`; mantener `CONTRATO_API.md` como referencia.
