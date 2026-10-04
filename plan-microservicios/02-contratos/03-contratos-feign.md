# 03 — Contratos Feign (sync, con CB)

Base: `spring-cloud-starter-openfeign`, discovery vía Eureka (`lb://`), `Resilience4j` en cada cliente (ver 07). Solo GET/PUT puntuales. Nada de listas masivas por Feign (eso va por Kafka o reporting).

## 3.1 booking → identity

```java
@FeignClient(name="identity-service", fallback=IdentityFallback.class)
public interface IdentityClient {
  @GetMapping("/internal/clientes/{id}")
  ClienteDto getById(@PathVariable Long id);
  @PostMapping("/internal/clientes/resolve-or-create")
  ClienteDto resolveOrCreate(@RequestBody ClienteRefDto dto); // nombre,doc,correo
}
```

`ClienteDto{idPersona,nombre,apellido,correo,tipoPersona}` — copia de `PersonaDto` legacy sin `clave`.

## 3.2 booking → catalog

```java
@FeignClient(name="catalog-service", fallback=CatalogFallback.class)
public interface CatalogClient {
  @GetMapping("/internal/habitaciones/{id}/disponibilidad")
  DisponibilidadDto check(@PathVariable Long id,
    @RequestParam String desde, @RequestParam String hasta);
  @PutMapping("/internal/habitaciones/{id}/lock")
  void lock(@PathVariable Long id, @RequestBody LockDto lock); // reserva_id, desde,hasta
  @PutMapping("/internal/habitaciones/{id}/release")
  void release(@PathVariable Long id, @RequestBody ReleaseDto r);
  @GetMapping("/internal/tarifas")
  TarifaDto tarifa(@RequestParam Long sedeId, @RequestParam Long categoriaId,
    @RequestParam String fecha);
}
```

Fallback `lock` → `503 RESERVA_RECHAZADA_REINTENTE` (no bloquear recepción, solo esa reserva).

## 3.3 sales → booking (validar recepción activa)

```java
@FeignClient(name="booking-service", fallback=BookingFallback.class)
public interface BookingClient {
  @GetMapping("/internal/reservas/{id}/activa")
  ReservaActivaDto activa(@PathVariable Long id);
}
```

## 3.4 reporting → * (agregador, timeout 3s + Bulkhead, nunca en checkout)

- `GET /internal/reservas?desde&hasta&sedeId` (booking)
- `GET /internal/ventas?desde&hasta` (sales)
- `GET /internal/catalogo/resumen?sedeId` (catalog)

Si alguno falla, reporting devuelve parcial + `warnings[]`, nunca 500.

## Reglas

- Todo Feign con `connectTimeout 1s, readTimeout 2s`, `Retry 3x solo GET`, `CB` obligatorio.
- Header interno `X-Internal: <secret-compose>` + `X-User-Id/Rol` propagado por Gateway (ver 06).
- Versionar DTOs con `ApiResponse<T>` igual que legacy para no romper Angular.
