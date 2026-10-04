# Plan Expansión Hotel Monolito → Cadena Microservicios

> Estado: entendimiento compartido cerrado (Rondas grilling Q1-Q14 = sí).
> Legacy intacto en `../` (`cibertec/`, `cibertec-angular/`, `database/`, `CONTRATO_API.md`). Esto es solo planificación, no código.

## Cómo leer esto (5 devs, 2 semanas, con agentes IA)

1. `../01-arquitectura/01-lore-a-arquitectura.md` — por qué cada decisión existe (para exponer en clase).
2. `../01-arquitectura/02-servicios-y-bounded-context.md` — qué construye cada uno (fronteras).
3. `../02-contratos/03-contratos-feign.md` + `../02-contratos/04-eventos-rabbitmq-kafka.md` — contratos congelados. No cambiar sin ADR.
4. `../03-datos/05-modelo-datos-multisede.md` — tablas nuevas + DB-per-service.
5. `../04-transversales/06-seguridad.md`, `../04-transversales/07-resiliencia.md`, `../04-transversales/08-observabilidad.md`, `../04-transversales/09-docker-k8s.md` — transversales (cumplen los 9 exigidos).
6. `../05-frontend/10-frontend-landing.md` — landing cadena + admin.
7. `../06-gestion/11-reparto-5-devs-2-semanas.md` — quién hace qué, día por día, DoD.
8. `../12-adr/` — decisiones registradas.
9. `../diagramas/hotel-cadena-arquitectura.html` — gráfico Archify validado showcase.

## Mapa 9 exigidos → dónde se cumplen

| # | Exigido | Dónde | Archivo |
|---|---|---|---|
| 1 | Feign Client | sync booking→identity/catalog | `03-contratos-feign.md` |
| 2 | RabbitMQ | comandos críticos + DLQ | `04-eventos-rabbitmq-kafka.md` |
| 3 | Kafka | streaming alto volumen | `04-eventos-rabbitmq-kafka.md` |
| 4 | Spring Cloud | Gateway+Eureka+Config | `02-servicios-y-bounded-context.md`, `09-docker-k8s.md` |
| 5 | Seguridad | JWT+roles en Gateway | `06-seguridad.md` |
| 6 | Resiliencia | Resilience4j CB+Retry+RL | `07-resiliencia.md` |
| 7 | Docker | 1 imagen/servicio + compose | `09-docker-k8s.md` |
| 8 | Kubernetes | manifests + HPA Kind | `09-docker-k8s.md` |
| 9 | Observabilidad | Prometheus+Grafana+Loki+Zipkin | `08-observabilidad.md` |
| + | CircuitBreaker | booking→catalog/identity | `07-resiliencia.md` |

## Respuestas cortas a tus preguntas

- **¿API Gateway?** Sí, `Spring Cloud Gateway` único entrypoint, valida JWT, rate-limit lectura, rutea `/api/*`.
- **¿Kafka o RabbitMQ?** Ambos: RabbitMQ comandos (reserva/pago/OTA), Kafka eventos masivos (views, price-changed, stay.finished).
- **¿Microservicios?** 7 funcionales + 3 infra (ver 02).
- **¿Landing?** Sí, mínima 3 vistas, solo lee catalog vía Gateway.
- **¿Más tablas?** Sí: `SEDE`, `TARIFA`, `LOYALTY`, `PAGO`. Ver 05.
- **¿Monorepo o separados?** Monorepo nuevo `hotel-chain/` multi-módulo Maven.
- **¿Modificar este repo?** No. Congelar como `legacy-ref`, copiar paquetes por servicio (strangler).

Siguiente paso: crear `hotel-chain/` y repartir según `11-reparto*`.
