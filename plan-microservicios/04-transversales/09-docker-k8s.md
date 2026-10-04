# 09 — Docker + Kubernetes

## Docker (entrega principal)

Un `Dockerfile` JRE21 por servicio (multi-stage `maven:3.9-eclipse-temurin-21 → eclipse-temurin:21-jre`).
`hotel-chain/docker-compose.yml`:

- infra: `postgres:16` (1 contenedor, N DBs), `rabbitmq:3-management`, `kafka:3.7 (KRaft)`, `eureka` no necesita imagen extra.
- app: `config:8888, discovery:8761, gateway:8080, identity:8081, catalog:8082, booking:8083, sales:8084, loyalty:8085, integration:8086, reporting:8087`.
- obs (profile `obs`): `prometheus, grafana:3000, loki, zipkin:9411`.

Comandos congelados:
`docker compose up --build` (demo), `docker compose --profile obs up`, `docker kill reporting-service` (prueba resiliencia).

## Kubernetes (Kind, entrega secundaria pero versionada)

`hotel-chain/k8s/`:
- `namespace/hotel.yaml`, `configmap/global.yaml` (urls brokers, jwt.secret ref `sealed-secret` demo), `postgres/statefulset.yaml` (o `cloudsql` mock).
- Por servicio: `deployment.yaml (liveness /actuator/health, readiness) + service.yaml (ClusterIP, solo gateway LoadBalancer/NodePort)`.
- `gateway/hpa.yaml`, `catalog/hpa.yaml`, `booking/hpa.yaml`: `min 2 max 5, CPU 70%, RPS 100`.
- `ingress/gateway-ingress.yaml` (`/api/*`, `/public/*`).

Target: `kind create cluster --name hotel && kubectl apply -k k8s/`. No se exige cloud real para aprobar; si hay tiempo, `minikube tunnel` para landing.

## DoD

- `compose up` levanta 10/10 healthy en <3min en laptop.
- `kubectl get pods -n hotel` 10/10 Running en Kind + HPA escala catalog a 3 con `k6/JMeter 200rps`.
