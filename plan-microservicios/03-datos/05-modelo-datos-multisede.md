# 05 — Modelo datos multisede (DB-per-service)

Un servidor Postgres por ambiente, 1 schema/DB por servicio. Sin FK cross-service. Solo IDs lógicos.

## 5.1 Nuevas tablas

```sql
-- catalog-service
CREATE TABLE SEDE(id SERIAL PK, nombre VARCHAR(120) UNIQUE NOT NULL,
  ciudad VARCHAR(80), direccion VARCHAR(200), estrellas INT, estado BOOLEAN DEFAULT true);
CREATE TABLE TARIFA(id SERIAL PK, sede_id INT NOT NULL, categoria_id INT NOT NULL,
  temporada VARCHAR(20) NOT NULL, -- ALTA/BAJA/FERIADO
  precio_noche NUMERIC NOT NULL, moneda CHAR(3) DEFAULT 'PEN',
  UNIQUE(sede_id,categoria_id,temporada));
ALTER TABLE HABITACION ADD COLUMN sede_id INT NOT NULL DEFAULT 1;

-- booking-service (solo lo suyo)
-- RECEPCION(id, sede_id, idcliente(INT lógico), idhabitacion(INT lógico),
--  fechaentrada/salida, precioinicial/adelanto/totalpagado, estado)
ALTER TABLE RECEPCION ADD COLUMN sede_id INT NOT NULL DEFAULT 1;

-- loyalty-service
CREATE TABLE LOYALTY(id SERIAL PK, persona_id INT UNIQUE NOT NULL,
  puntos INT DEFAULT 0, nivel VARCHAR(20) DEFAULT 'BRONCE');

-- integration-service
CREATE TABLE PAGO(id SERIAL PK, reserva_id INT NOT NULL,
  proveedor VARCHAR(30), monto NUMERIC, estado VARCHAR(20), payload JSONB);
CREATE TABLE OTA_SYNC(id SERIAL PK, sede_id INT, accion VARCHAR(20),
  estado VARCHAR(20), payload JSONB, created_at TIMESTAMP DEFAULT now());
```

`PERSONA/TIPO_PERSONA` quedan globales en identity, sin `sede_id`.

## 5.2 Migración desde SPs legacy

- `sp_RegistrarRecepcion` (hoy inserta PERSONA + cambia HABITACION + inserta RECEPCION) → saga en booking:
  1. `Feign resolveOrCreate(cliente)` → `idCliente`
  2. `Feign tarifa(sede,categoria,fecha)` + `lock(habitacion)`
  3. `INSERT RECEPCION` local
  4. `Rabbit booking.reservada`
  Si (2) falla → compensar: no insertar, devolver 503. No rollback distribuido.
- `sp_RegistrarVenta(JSON)` → se queda entero dentro de sales (no cruza servicios).
- `sp_RegistrarSalida` → `UPDATE RECEPCION` + `Feign release` + `Rabbit booking.cerrada` + `Kafka stay.finished`.
- `fn_Reporte_*` → se reescriben en reporting como agregación Feign + tablas replica Kafka (fase 2), no como functions Postgres cross-schema.

## 5.3 Seeds multisede

- Sedes: `Miraflores-Lima`, `Cusco-Centro`, `Arequipa`.
- Cada `HABITACION` existente → `sede_id=1`. Crear 5 por sede 2 y 3 con mismo `PISO/CATEGORIA`.
- Tarifas ejemplo: `Miraflores/SIMPLE/ALTA=250`, `Cusco/SIMPLE/ALTA=180`.
