-- =============================================================
-- Hotel Cibertec · Migración 01 — Esquema base (DDL)
-- Base de datos : PostgreSQL
-- Orden         : 01_schema → 02_procedures → 03_reports
--                 → 04_indexes → seed.sql
-- Fuente        : entidades JPA (com.hotel.cibertec.entity.*)
--                 + columnas exigidas por los procedimientos
-- =============================================================
-- Notas:
--  1. Nombres sin comillas: PostgreSQL los pliega a minúsculas,
--     por eso 'HABITACION' y 'habitacion' son la misma tabla.
--  2. TIPO_PERSONA lleva PK manual (sin SERIAL) porque la entidad
--     no usa @GeneratedValue: los ids 1/2/3 los pone el seed.
--  3. Los UNIQUE en descripcion/nombre replican reglas de negocio
--     que ya exigen los procedimientos (sp_RegistrarCategoria,
--     sp_RegistrarPiso, sp_RegistrarProducto) y permiten que el
--     seed.sql sea re-ejecutable (ON CONFLICT DO NOTHING).
--  4. Los DEFAULT (TRUE / CURRENT_TIMESTAMP) cubren a los
--     procedimientos que insertan sin esas columnas
--     (ej. sp_RegistrarCategoria solo inserta descripcion).
-- =============================================================

SET client_encoding = 'UTF8';

-- ---------- Tablas maestras (sin dependencias) ----------

CREATE TABLE IF NOT EXISTS TIPO_PERSONA (
    idtipopersona INTEGER PRIMARY KEY, -- PK manual, sin SERIAL (ver nota 2)
    descripcion   VARCHAR(255),
    estado        BOOLEAN   DEFAULT TRUE,
    fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ESTADO_HABITACION (
    idestadohabitacion SERIAL PRIMARY KEY,
    descripcion        VARCHAR(255) UNIQUE, -- ver nota 3
    estado             BOOLEAN   DEFAULT TRUE,
    fechacreacion      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS CATEGORIA (
    idcategoria   SERIAL PRIMARY KEY,
    descripcion   VARCHAR(255) UNIQUE, -- ver nota 3
    estado        BOOLEAN   DEFAULT TRUE,
    fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS PISO (
    idpiso        SERIAL PRIMARY KEY,
    descripcion   VARCHAR(255) UNIQUE, -- ver nota 3
    estado        BOOLEAN   DEFAULT TRUE,
    fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS PRODUCTO (
    idproducto    SERIAL PRIMARY KEY,
    nombre        VARCHAR(255) UNIQUE, -- ver nota 3 (sp_RegistrarProducto exige nombre único)
    detalle       VARCHAR(255),
    precio        NUMERIC(10,2),
    cantidad      INTEGER,
    estado        BOOLEAN DEFAULT TRUE,
    imagen_url    VARCHAR(500), -- length=500 según entidad Producto
    fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------- HABITACION (depende de ESTADO_HABITACION, PISO, CATEGORIA) ----------

CREATE TABLE IF NOT EXISTS HABITACION (
    idhabitacion       SERIAL PRIMARY KEY,
    numero             VARCHAR(255) NOT NULL UNIQUE, -- unique según entidad
    detalle            VARCHAR(255),
    precio             NUMERIC(10,2),
    idestadohabitacion INTEGER,
    idpiso             INTEGER,
    idcategoria        INTEGER,
    estado             BOOLEAN   NOT NULL DEFAULT TRUE,
    fechacreacion      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_habitacion_estado   FOREIGN KEY (idestadohabitacion) REFERENCES ESTADO_HABITACION (idestadohabitacion),
    CONSTRAINT fk_habitacion_piso     FOREIGN KEY (idpiso)             REFERENCES PISO (idpiso),
    CONSTRAINT fk_habitacion_categoria FOREIGN KEY (idcategoria)        REFERENCES CATEGORIA (idcategoria)
);

-- ---------- PERSONA (depende de TIPO_PERSONA) ----------

CREATE TABLE IF NOT EXISTS PERSONA (
    idpersona     SERIAL PRIMARY KEY,
    tipodocumento VARCHAR(255),
    documento     VARCHAR(255),
    nombre        VARCHAR(255),
    apellido      VARCHAR(255),
    correo        VARCHAR(255),
    clave         VARCHAR(255),
    foto_url      VARCHAR(255),
    idtipopersona INTEGER,
    estado        BOOLEAN   DEFAULT TRUE,
    fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_persona_tipopersona FOREIGN KEY (idtipopersona) REFERENCES TIPO_PERSONA (idtipopersona)
);
-- NOTA: no se agregan UNIQUE(documento/correo) a propósito:
-- sp_RegistrarRecepcion inserta personas sin validar duplicados
-- y un UNIQUE rompería ese flujo actual.

-- ---------- RECEPCION (depende de PERSONA, HABITACION) ----------

CREATE TABLE IF NOT EXISTS RECEPCION (
    idrecepcion              SERIAL PRIMARY KEY,
    idcliente                INTEGER,
    idhabitacion             INTEGER,
    fechaentrada             DATE,
    fechasalida              DATE,
    fechasalidaconfirmacion  TIMESTAMP,
    precioinicial            NUMERIC(10,2),
    adelanto                 NUMERIC(10,2),
    preciorestante           NUMERIC(10,2),
    totalpagado              NUMERIC(10,2),
    costopenalidad           NUMERIC(10,2),
    observacion              VARCHAR(255),
    estado                   BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_recepcion_cliente   FOREIGN KEY (idcliente)    REFERENCES PERSONA (idpersona),
    CONSTRAINT fk_recepcion_habitacion FOREIGN KEY (idhabitacion) REFERENCES HABITACION (idhabitacion)
);

-- ---------- VENTA (depende de RECEPCION) ----------

CREATE TABLE IF NOT EXISTS VENTA (
    idventa       SERIAL PRIMARY KEY,
    idrecepcion   INTEGER,
    total         NUMERIC(10,2),
    estado        VARCHAR(20), -- length=20 según entidad Venta
    fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_venta_recepcion FOREIGN KEY (idrecepcion) REFERENCES RECEPCION (idrecepcion)
);

-- ---------- DETALLE_VENTA (depende de VENTA, PRODUCTO) ----------

CREATE TABLE IF NOT EXISTS DETALLE_VENTA (
    iddetalleventa SERIAL PRIMARY KEY,
    idventa        INTEGER,
    idproducto     INTEGER,
    cantidad       INTEGER,
    preciounitario NUMERIC(10,2),
    subtotal       NUMERIC(10,2),
    -- ON DELETE CASCADE = cascade=ALL + orphanRemoval de la entidad Venta
    CONSTRAINT fk_detalle_venta    FOREIGN KEY (idventa)    REFERENCES VENTA (idventa)       ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto FOREIGN KEY (idproducto) REFERENCES PRODUCTO (idproducto)
);

-- ---------- IMAGEN_HABITACION (depende de HABITACION) ----------

CREATE TABLE IF NOT EXISTS IMAGEN_HABITACION (
    idimagen     SERIAL PRIMARY KEY,
    url_imagen   VARCHAR(255) NOT NULL,
    idhabitacion INTEGER,
    -- ON DELETE CASCADE = cascade=ALL de Habitacion.imagenes
    CONSTRAINT fk_imagen_habitacion FOREIGN KEY (idhabitacion) REFERENCES HABITACION (idhabitacion) ON DELETE CASCADE
);

-- ---------- carrito (depende de RECEPCION, PRODUCTO) ----------

CREATE TABLE IF NOT EXISTS carrito (
    idcarrito     SERIAL PRIMARY KEY,
    idrecepcion   INTEGER NOT NULL,
    idproducto    INTEGER NOT NULL,
    cantidad      INTEGER NOT NULL,
    fecharegistro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_carrito_recepcion FOREIGN KEY (idrecepcion) REFERENCES RECEPCION (idrecepcion),
    CONSTRAINT fk_carrito_producto  FOREIGN KEY (idproducto)  REFERENCES PRODUCTO (idproducto)
);

-- Siguiente paso: 02_procedures.sql
