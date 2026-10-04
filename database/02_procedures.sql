-- =============================================================
-- Hotel Cibertec · Migración 02 — Procedimientos y funciones CRUD
-- Orden: ejecutar DESPUÉS de 01_schema.sql
-- Origen: "procedmientos Actualizados.sql" (limpio: sin SELECTs
--          sueltos de depuración ni DROP redundantes).
-- Nota: DROP FUNCTION IF EXISTS sp_RegistrarVenta(...) se mantiene
--       porque esa función cambió de tipo de retorno BOOLEAN → INT
--       y CREATE OR REPLACE no permite cambiar el tipo de retorno.
-- =============================================================

-- ---------------- CATEGORIA ----------------

CREATE OR REPLACE PROCEDURE sp_RegistrarCategoria(
    IN p_Descripcion VARCHAR,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE Descripcion = p_Descripcion) THEN
        INSERT INTO CATEGORIA(Descripcion) VALUES (p_Descripcion);
    ELSE
        Resultado := FALSE;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ModificarCategoria(
    IN p_IdCategoria INT,
    IN p_Descripcion VARCHAR,
    IN p_Estado BOOLEAN,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF NOT EXISTS (SELECT 1 FROM CATEGORIA WHERE Descripcion = p_Descripcion AND IdCategoria <> p_IdCategoria) THEN
        UPDATE CATEGORIA
        SET Descripcion = p_Descripcion,
            Estado = p_Estado
        WHERE IdCategoria = p_IdCategoria;
    ELSE
        Resultado := FALSE;
    END IF;
END;
$$;

-- ---------------- PISO ----------------

CREATE OR REPLACE PROCEDURE sp_RegistrarPiso(
    IN p_Descripcion VARCHAR,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF NOT EXISTS (SELECT 1 FROM PISO WHERE Descripcion = p_Descripcion) THEN
        INSERT INTO PISO(Descripcion) VALUES (p_Descripcion);
    ELSE
        Resultado := FALSE;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ModificarPiso(
    IN p_IdPiso INT,
    IN p_Descripcion VARCHAR,
    IN p_Estado BOOLEAN,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF NOT EXISTS (SELECT 1 FROM PISO WHERE Descripcion = p_Descripcion AND IdPiso <> p_IdPiso) THEN
        UPDATE PISO
        SET Descripcion = p_Descripcion,
            Estado = p_Estado
        WHERE IdPiso = p_IdPiso;
    ELSE
        Resultado := FALSE;
    END IF;
END;
$$;

-- ---------------- HABITACION ----------------

CREATE OR REPLACE PROCEDURE sp_RegistrarHabitacion(
    IN p_Numero VARCHAR,
    IN p_Detalle VARCHAR,
    IN p_Precio NUMERIC,
    IN p_IdPiso INT,
    IN p_IdCategoria INT,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;
    IF NOT EXISTS (SELECT 1 FROM HABITACION WHERE numero = p_Numero) THEN
        INSERT INTO HABITACION(numero, detalle, precio, idpiso, idcategoria, idestadohabitacion, estado)
        VALUES (p_Numero, p_Detalle, p_Precio, p_IdPiso, p_IdCategoria, 1, TRUE);
    ELSE
        Resultado := FALSE;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ModificarHabitacion(
    IN p_IdHabitacion INT,
    IN p_Numero VARCHAR(50),
    IN p_Detalle VARCHAR(255),
    IN p_Precio NUMERIC(10,2),
    IN p_IdPiso INT,
    IN p_IdCategoria INT,
    IN p_IdEstadoHabitacion INT,
    IN p_Estado BOOLEAN,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF NOT EXISTS (SELECT 1 FROM HABITACION WHERE numero = p_Numero AND idhabitacion <> p_IdHabitacion) THEN
        UPDATE HABITACION
        SET numero = p_Numero,
            detalle = p_Detalle,
            precio = p_Precio,
            idpiso = p_IdPiso,
            idcategoria = p_IdCategoria,
            idestadohabitacion = p_IdEstadoHabitacion,
            estado = p_Estado
        WHERE idhabitacion = p_IdHabitacion;
    ELSE
        Resultado := FALSE;
    END IF;
END;
$$;

-- ---------------- PRODUCTO ----------------

CREATE OR REPLACE PROCEDURE sp_RegistrarProducto(
    IN p_Nombre VARCHAR,
    IN p_Detalle VARCHAR,
    IN p_Precio NUMERIC,
    IN p_Cantidad INT,
    IN p_ImagenUrl VARCHAR,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF EXISTS (
        SELECT 1
        FROM PRODUCTO
        WHERE Nombre = p_Nombre
    ) THEN
        Resultado := FALSE;
    ELSE
        INSERT INTO PRODUCTO(
            Nombre,
            Detalle,
            Precio,
            Cantidad,
            Imagen_Url,
            Estado,
            FechaCreacion
        )
        VALUES(
            p_Nombre,
            p_Detalle,
            p_Precio,
            p_Cantidad,
            p_ImagenUrl,
            TRUE,
            CURRENT_TIMESTAMP
        );
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_ModificarProducto(
    IN p_IdProducto INT,
    IN p_Nombre VARCHAR,
    IN p_Detalle VARCHAR,
    IN p_Precio NUMERIC,
    IN p_Cantidad INT,
    IN p_Estado BOOLEAN,
    IN p_ImagenUrl VARCHAR,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    Resultado := TRUE;

    IF EXISTS (
        SELECT 1
        FROM PRODUCTO
        WHERE Nombre = p_Nombre
          AND IdProducto <> p_IdProducto
    ) THEN
        Resultado := FALSE;
    ELSE
        UPDATE PRODUCTO
        SET Nombre = p_Nombre,
            Detalle = p_Detalle,
            Precio = p_Precio,
            Cantidad = p_Cantidad,
            Estado = p_Estado,
            Imagen_Url = p_ImagenUrl
        WHERE IdProducto = p_IdProducto;
    END IF;
END;
$$;

-- ---------------- PERSONA ----------------

CREATE OR REPLACE FUNCTION sp_RegistrarPersona(
    p_TipoDocumento VARCHAR, p_Documento VARCHAR, p_Nombre VARCHAR,
    p_Apellido VARCHAR, p_Correo VARCHAR, p_Clave VARCHAR, p_IdTipoPersona INT
) RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PERSONA WHERE Documento = p_Documento) THEN
        INSERT INTO PERSONA(TipoDocumento, Documento, Nombre, Apellido, Correo, Clave, IdTipoPersona, Estado, fechaCreacion)
        VALUES (p_TipoDocumento, p_Documento, p_Nombre, p_Apellido, p_Correo, p_Clave, p_IdTipoPersona, TRUE, NOW());
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_ModificarPersona(
    p_IdPersona INT,
    p_TipoDocumento VARCHAR,
    p_Documento VARCHAR,
    p_Nombre VARCHAR,
    p_Apellido VARCHAR,
    p_Correo VARCHAR,
    p_Clave VARCHAR,
    p_IdTipoPersona INT,
    p_Estado BOOLEAN,
    p_FotoUrl VARCHAR
) RETURNS BOOLEAN AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM PERSONA WHERE Documento = p_Documento AND IdPersona <> p_IdPersona) THEN
        UPDATE PERSONA
        SET TipoDocumento = p_TipoDocumento,
            Documento = p_Documento,
            Nombre = p_Nombre,
            Apellido = p_Apellido,
            Correo = p_Correo,
            Clave = p_Clave,
            IdTipoPersona = p_IdTipoPersona,
            Estado = p_Estado,
            foto_url = p_FotoUrl
        WHERE IdPersona = p_IdPersona;

        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ---------------- RECEPCION / SALIDA ----------------

CREATE OR REPLACE PROCEDURE sp_RegistrarRecepcion(
    IN p_IdCliente INT,
    IN p_TipoDocumento VARCHAR,
    IN p_Documento VARCHAR,
    IN p_Nombre VARCHAR,
    IN p_Apellido VARCHAR,
    IN p_Correo VARCHAR,
    IN p_IdHabitacion INT,
    IN p_FechaSalida DATE,
    IN p_PrecioInicial NUMERIC,
    IN p_Adelanto NUMERIC,
    IN p_PrecioRestante NUMERIC,
    IN p_Observacion VARCHAR,
    OUT Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE v_IdCliente INT;
BEGIN
    Resultado := TRUE;
    v_IdCliente := p_IdCliente;

    -- 1. Asegurar que no haya otra recepción activa en la misma habitación
    UPDATE RECEPCION
    SET Estado = FALSE
    WHERE IdHabitacion = p_IdHabitacion AND Estado = TRUE;

    -- 2. Lógica de cliente
    IF v_IdCliente IS NULL OR v_IdCliente = 0 OR NOT EXISTS (SELECT 1 FROM PERSONA WHERE IdPersona = v_IdCliente) THEN
        INSERT INTO PERSONA(TipoDocumento, Documento, Nombre, Apellido, Correo, IdTipoPersona, Estado)
        VALUES (p_TipoDocumento, p_Documento, p_Nombre, p_Apellido, p_Correo, 3, TRUE)
        RETURNING IdPersona INTO v_IdCliente;
    END IF;

    -- 3. Actualizar estado de la habitación (2 = OCUPADO)
    UPDATE HABITACION SET IdEstadoHabitacion = 2 WHERE IdHabitacion = p_IdHabitacion;

    -- 4. Insertar la nueva recepción
    INSERT INTO RECEPCION(IdCliente, IdHabitacion, FechaEntrada, FechaSalida, PrecioInicial, Adelanto, PrecioRestante, Observacion, Estado)
    VALUES (v_IdCliente, p_IdHabitacion, CURRENT_DATE, p_FechaSalida, p_PrecioInicial, p_Adelanto, p_PrecioRestante, p_Observacion, TRUE);

EXCEPTION WHEN OTHERS THEN
    Resultado := FALSE;
END;
$$;

CREATE OR REPLACE PROCEDURE sp_RegistrarSalida(
    IN p_IdRecepcion INT,
    IN p_IdHabitacion INT,
    IN p_CostoPenalidad NUMERIC,
    IN p_TotalPagado NUMERIC,
    OUT p_Resultado BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM RECEPCION WHERE IdRecepcion = p_IdRecepcion) THEN
        p_Resultado := FALSE;
        RETURN;
    END IF;

    -- 2. Actualizar recepción
    UPDATE RECEPCION
    SET Estado = FALSE,
        FechaSalidaConfirmacion = CURRENT_TIMESTAMP,
        TotalPagado = p_TotalPagado,
        CostoPenalidad = p_CostoPenalidad
    WHERE IdRecepcion = p_IdRecepcion;

    -- 3. Marcar consumos como pagados
    UPDATE VENTA
    SET Estado = 'PAGADO'
    WHERE IdRecepcion = p_IdRecepcion AND Estado != 'PAGADO';

    -- 4. Habitación a estado 3 (limpieza/mantenimiento)
    UPDATE HABITACION
    SET IdEstadoHabitacion = 3
    WHERE IdHabitacion = p_IdHabitacion;

    p_Resultado := TRUE;
    -- Sin COMMIT/ROLLBACK: Spring Boot los controla con @Transactional
EXCEPTION WHEN OTHERS THEN
    p_Resultado := FALSE;
    RAISE; -- relanza para que Spring Boot ejecute su propio ROLLBACK
END;
$$;

-- ---------------- VENTA ----------------
-- La firma anterior devolvía BOOLEAN; la actual devuelve el INT
-- del nuevo IdVenta, por eso se elimina la versión vieja primero.

DROP FUNCTION IF EXISTS sp_RegistrarVenta(INT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION sp_RegistrarVenta(
    p_IdRecepcion INT,
    p_Estado VARCHAR,
    p_Detalles TEXT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_IdVenta INT;
    v_TotalVenta NUMERIC(10,2) := 0.00;
    v_Detalle RECORD;
    v_JsonData JSON;
BEGIN
    v_JsonData := p_Detalles::JSON;

    -- 1. Validar existencia
    IF NOT EXISTS (SELECT 1 FROM RECEPCION WHERE IdRecepcion = p_IdRecepcion) THEN
        RAISE EXCEPTION 'La recepción con ID % no existe.', p_IdRecepcion;
    END IF;

    -- 2. Insertar cabecera
    INSERT INTO VENTA (IdRecepcion, Total, Estado, FechaCreacion)
    VALUES (p_IdRecepcion, 0.00, p_Estado, CURRENT_TIMESTAMP)
    RETURNING IdVenta INTO v_IdVenta;

    -- 3. Procesar detalles
    FOR v_Detalle IN
        SELECT
            (elem->>'idProducto')::INT AS id_prod,
            (elem->>'cantidad')::INT AS cant,
            (elem->>'precioUnitario')::NUMERIC(10,2) AS precio
        FROM json_array_elements(v_JsonData) AS elem
    LOOP
        IF (SELECT Cantidad FROM PRODUCTO WHERE IdProducto = v_Detalle.id_prod) < v_Detalle.cant THEN
            RAISE EXCEPTION 'Stock insuficiente para el producto ID %', v_Detalle.id_prod;
        END IF;

        INSERT INTO DETALLE_VENTA (IdVenta, IdProducto, Cantidad, preciounitario, SubTotal)
        VALUES (v_IdVenta, v_Detalle.id_prod, v_Detalle.cant, v_Detalle.precio, (v_Detalle.cant * v_Detalle.precio));

        UPDATE PRODUCTO
        SET Cantidad = Cantidad - v_Detalle.cant
        WHERE IdProducto = v_Detalle.id_prod;

        v_TotalVenta := v_TotalVenta + (v_Detalle.cant * v_Detalle.precio);
    END LOOP;

    -- 4. Finalizar
    UPDATE VENTA SET Total = v_TotalVenta WHERE IdVenta = v_IdVenta;

    RETURN v_IdVenta;
EXCEPTION WHEN OTHERS THEN
    RAISE;
END;
$$;

-- Siguiente paso: 03_reports.sql
