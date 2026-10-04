-- =============================================================
-- Hotel Cibertec · Migración 04 — Índices de apoyo a reportes
-- Orden: ejecutar DESPUÉS de 03_reports.sql (las tablas ya existen
--        desde 01_schema.sql; el orden respecto a 02/03 es libre).
-- Todos usan IF NOT EXISTS: re-ejecución segura.
-- =============================================================

-- Para el reporte de Ventas (filtros por fecha y joins)
CREATE INDEX IF NOT EXISTS idx_venta_fecha              ON VENTA (fechacreacion);
CREATE INDEX IF NOT EXISTS idx_detalle_venta_idventa    ON DETALLE_VENTA (idventa);
CREATE INDEX IF NOT EXISTS idx_detalle_venta_idproducto ON DETALLE_VENTA (idproducto);

-- Para el reporte de Ocupación
CREATE INDEX IF NOT EXISTS idx_recepcion_fecha_entrada  ON RECEPCION (fechaentrada);
CREATE INDEX IF NOT EXISTS idx_recepcion_idhabitacion   ON RECEPCION (idhabitacion);

-- Para el reporte de Cobros
CREATE INDEX IF NOT EXISTS idx_recepcion_fecha_salida   ON RECEPCION (fechaSalidaConfirmacion);
CREATE INDEX IF NOT EXISTS idx_persona_idtipopersona    ON PERSONA (idtipopersona);

-- Para productos bajo stock
CREATE INDEX IF NOT EXISTS idx_producto_cantidad        ON PRODUCTO (cantidad);

-- Siguiente paso: seed.sql
