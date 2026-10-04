# Hotel Cadena — De 1 hotel a muchos (plan en simple)

Antes teníamos **1 hotel con todo junto**. Si algo se malograba, se caía todo.
Ahora vamos a tener **una cadena de hoteles** donde cada parte trabaja por separado.
Si una parte falla, las demás siguen atendiendo.

> Este es solo el plan. El sistema viejo sigue intacto al lado. Aquí solo explicamos qué vamos a construir.

## La idea en 30 segundos

- Pasamos de 1 local a 3 sedes: Miraflores, Cusco, Arequipa.
- Los clientes y sus puntos son los mismos en todas las sedes.
- Cada sede tiene sus habitaciones y sus precios.
- La web recibe miles de visitas, la recepción no se puede caer nunca.
- Si Booking o la pasarela de pagos falla, la caja del hotel sigue funcionando.

## Los 10 servicios (7 negocio + 3 soporte)

### Negocio (lo que el hotel hace)

1. **identity :8081** - carnet del hotel. Guarda personas, hace login y da el pase (JWT). Si no te reconoce, no entras.
2. **catalog :8082** - vitrina. Guarda sedes, habitaciones, fotos y precios. Aguanta las miles de consultas de la web.
3. **booking :8083** - recepción. El más importante. Crea reservas y hace check-in/check-out. Si todo lo demás se cae, este debe seguir atendiendo.
4. **sales :8084** - cafetería/minibar. Vende productos, carrito y la cuenta de consumos por habitación.
5. **loyalty :8085** - tarjeta de puntos. Escucha cuando terminas tu estadía y te suma puntos (10 por noche).
6. **integration :8086** - traductor con el exterior. Habla con Booking/Expedia y la pasarela de pagos. Si ellos fallan, guarda el pendiente sin tumbar la caja.
7. **reporting :8087** - contador. Solo mira y suma para reportes/dashboard. Está aislado para que nunca vuelva a tumbar recepción como el viernes de feriado.

### Soporte (ayudan por detrás, el cliente no los ve)

8. **gateway :8080** - puerta única. Toda la web/app entra por aquí, revisa tu pase y reparte.
9. **discovery :8761** - directorio. Sabe dónde vive cada servicio para que se encuentren.
10. **config :8888** - recetario central. Reparte la configuración a todos para no editar uno por uno.

## Cómo se hablan (sin tecnicismos)

- **En persona (Feign):** cuando recepción necesita preguntar algo puntual. Ejemplo: "¿este cliente existe?" o "¿esta habitación está libre?".
- **Por carta certificada (RabbitMQ):** avisos que no se pueden perder. Ejemplo: "se reservó", "se pagó", "avisar a Booking". Si falla, se guarda y se reintenta.
- **Por noticiero (Kafka):** chismes de a montones. Ejemplo: "alguien vio una habitación", "cambió un precio", "terminó una estadía". Varios escuchan a la vez.

## Dónde está cada cosa

- `00-indice/` — índice para ubicarte.
- `01-arquitectura/` — por qué lo dividimos así.
- `02-contratos/` — qué se preguntan y qué avisos se mandan.
- `03-datos/` — sedes, tarifas y puntos.
- `04-transversales/` — seguridad, que no se caiga, monitoreo, Docker y Kubernetes.
- `05-frontend/` — página pública + panel admin.
- `06-gestion/` — quién hace qué en 2 semanas.
- `12-adr/` — decisiones importantes.
- `diagramas/` — dibujo de todo el sistema.

## Para repartir el trabajo

Somos 5 en 2 semanas. Cada uno toma una parte:
P1 puerta y soporte, P2 carnet y puntos, P3 vitrina, P4 recepción y ventas, P5 traductor, contador y monitoreo.
