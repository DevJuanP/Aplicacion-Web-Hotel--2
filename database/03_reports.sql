-- =============================================================
-- Hotel Cibertec · Migración 03 — Funciones de reportes y dashboard
-- Orden: ejecutar DESPUÉS de 02_procedures.sql
-- Origen: sección "reportes del sistema" de
--          "procedmientos Actualizados.sql" (limpia).
-- =============================================================

-- Limpieza de versiones anteriores (nombres en desuso). Son no-op
-- en una BD nueva gracias al IF EXISTS.
DROP FUNCTION IF EXISTS fn_Reporte_ProductosBajoStock(INT);
DROP FUNCTION IF EXISTS fn_Reporte_Ventas(TIMESTAMP, TIMESTAMP);
DROP FUNCTION IF EXISTS fn_Reporte_Ocupacion(TIMESTAMP, TIMESTAMP);
DROP FUNCTION IF EXISTS fn_Reporte_Cobros(TIMESTAMP, TIMESTAMP);

-- ---------------- Cobros consolidados ----------------

CREATE OR REPLACE FUNCTION fn_Reporte_Cobros_Consolidado(p_inicio TIMESTAMP, p_fin TIMESTAMP)
RETURNS TABLE(
    numero_habitacion TEXT,
    nombre_cliente TEXT,
    total_alojamiento NUMERIC,
    total_consumos NUMERIC,
    total_general NUMERIC,
    fecha_cierre TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        h.numero::TEXT,
        (p.nombre || ' ' || p.apellido)::TEXT,
        r.totalpagado AS total_alojamiento,
        COALESCE((SELECT SUM(v.total) FROM VENTA v WHERE v.idrecepcion = r.idrecepcion AND v.estado = 'PAGADO'), 0) AS total_consumos,
        (r.totalpagado + COALESCE((SELECT SUM(v.total) FROM VENTA v WHERE v.idrecepcion = r.idrecepcion AND v.estado = 'PAGADO'), 0)) AS total_general,
        r.fechaSalidaConfirmacion
    FROM RECEPCION r
    JOIN HABITACION h ON r.idhabitacion = h.idhabitacion
    JOIN PERSONA p ON r.idcliente = p.idpersona
    WHERE p.idtipopersona = 3
    AND r.fechaSalidaConfirmacion BETWEEN p_inicio AND p_fin;
END;
$$ LANGUAGE plpgsql;

-- ---------------- Ventas validadas (solo PAGADO) ----------------

CREATE OR REPLACE FUNCTION fn_Reporte_Ventas_Validadas(p_inicio TIMESTAMP, p_fin TIMESTAMP)
RETURNS TABLE(nombre_producto TEXT, cantidad_total BIGINT, total_ingresado NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.nombre::TEXT,
        SUM(dv.cantidad)::BIGINT,
        SUM(dv.subtotal)::NUMERIC
    FROM VENTA v
    JOIN DETALLE_VENTA dv ON v.idventa = dv.idventa
    JOIN PRODUCTO p ON dv.idproducto = p.idproducto
    WHERE v.fechacreacion BETWEEN p_inicio AND p_fin
    AND v.estado = 'PAGADO' -- regla crítica para no inflar recaudación
    GROUP BY p.nombre;
END;
$$ LANGUAGE plpgsql;

-- ---------------- Ocupación efectiva ----------------

CREATE OR REPLACE FUNCTION fn_Reporte_Ocupacion_Efectiva(p_inicio TIMESTAMP, p_fin TIMESTAMP)
RETURNS TABLE(num_habitacion TEXT, desc_categoria TEXT, veces_alquilada BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT h.numero::TEXT, c.descripcion::TEXT, COUNT(r.idrecepcion)::BIGINT
    FROM RECEPCION r
    JOIN HABITACION h ON r.idhabitacion = h.idhabitacion
    JOIN CATEGORIA c ON h.idcategoria = c.idcategoria
    WHERE r.fechaSalidaConfirmacion BETWEEN p_inicio AND p_fin -- filtro por salida efectiva
    GROUP BY h.numero, c.descripcion;
END;
$$ LANGUAGE plpgsql;

-- ---------------- Dashboard (una sola fila) ----------------

CREATE OR REPLACE FUNCTION fn_Dashboard_Estadisticas()
RETURNS TABLE(ocupadas BIGINT, disponibles BIGINT, bajo_stock BIGINT, ingresos_hoy NUMERIC) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (SELECT COUNT(*) FROM HABITACION WHERE idestadohabitacion = 2),
        (SELECT COUNT(*) FROM HABITACION WHERE idestadohabitacion = 1),
        (SELECT COUNT(*) FROM PRODUCTO WHERE cantidad <= 10),
        -- Suma de ventas + pagos de habitación realizados hoy
        (SELECT COALESCE(SUM(total), 0) + (SELECT COALESCE(SUM(totalpagado), 0)
         FROM RECEPCION WHERE fechasalidaconfirmacion::date = CURRENT_DATE)
         FROM VENTA WHERE fechacreacion::date = CURRENT_DATE);
END;
$$ LANGUAGE plpgsql;

-- Siguiente paso: 04_indexes.sql
