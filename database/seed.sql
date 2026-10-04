-- =============================================================
-- Hotel Cibertec · seed.sql — Datos semilla (demo)
-- Orden: ejecutar DESPUÉS de 01_schema.sql (requiere las tablas).
--        No depende de 02/03/04, pero el flujo recomendado es
--        correrlo al final: 01 → 02 → 03 → 04 → seed.
-- Origen: "Datos Hotel.sql" + TIPO_PERSONA (la app los necesita:
--         1=Administrador, 2=Empleado, 3=Cliente; ver DataInitializer).
-- Re-ejecutable: cada bloque usa ON CONFLICT / NOT EXISTS, así que
--          correrlo dos veces no duplica datos.
-- NOTA: pensado para una BD creada con 01_schema.sql (los UNIQUE en
--       descripcion/nombre los crea ese script). Sobre un esquema
--       generado por Hibernate (ddl-auto=update) los ON CONFLICT en
--       descripcion/nombre fallarían por falta del UNIQUE; en ese
--       caso usa los INSERT originales de "Datos Hotel.sql".
-- Usuarios: NO se incluyen aquí (la clave va con BCrypt). Al arrancar
--          el backend, DataInitializer crea automáticamente:
--            · Administrador: yaxoncalle@gmail.com / 123123
--            · Empleado:      Trabajadorpaul@gmail.com / 456456
-- =============================================================

BEGIN;

-- ---------- 0. Tipos de persona (ids fijos: los usa el backend) ----------

INSERT INTO TIPO_PERSONA (idtipopersona, descripcion, estado, fechacreacion)
VALUES
    (1, 'Administrador', TRUE, NOW()),
    (2, 'Empleado',      TRUE, NOW()),
    (3, 'Cliente',       TRUE, NOW())
ON CONFLICT (idtipopersona) DO NOTHING;

-- ---------- 1. Catálogos (tablas maestras) ----------

INSERT INTO ESTADO_HABITACION (descripcion, estado, fechacreacion)
VALUES
    ('DISPONIBLE',    TRUE, NOW()),
    ('OCUPADO',       TRUE, NOW()),
    ('MANTENIMIENTO', TRUE, NOW())
ON CONFLICT (descripcion) DO NOTHING;

INSERT INTO CATEGORIA (descripcion, estado, fechacreacion)
VALUES
    ('Matrimonial', TRUE, NOW()),
    ('Doble',       TRUE, NOW()),
    ('Individual',  TRUE, NOW())
ON CONFLICT (descripcion) DO NOTHING;

INSERT INTO PISO (descripcion, estado, fechacreacion)
VALUES
    ('PRIMERO', TRUE, NOW()),
    ('SEGUNDO', TRUE, NOW()),
    ('TERCERO', TRUE, NOW())
ON CONFLICT (descripcion) DO NOTHING;

-- ---------- 2. Habitaciones (10) ----------
-- idestadohabitacion=1 (DISPONIBLE), idpiso/idcategoria según catálogos.

INSERT INTO HABITACION (numero, detalle, precio, idestadohabitacion, idpiso, idcategoria, estado, fechacreacion)
VALUES
    ('001', 'WIFI + BAÑO + TV + CABLE',     70.00, 1, 1, 3, TRUE, NOW()),
    ('002', 'WIFI + BAÑO + TV + CABLE',     80.00, 1, 1, 2, TRUE, NOW()),
    ('003', 'BAÑO + TV + CABLE',            60.00, 1, 1, 3, TRUE, NOW()),
    ('004', 'WIFI + BAÑO + TV + CABLE',     80.00, 1, 1, 2, TRUE, NOW()),
    ('005', 'WIFI + BAÑO',                  50.00, 1, 1, 3, TRUE, NOW()),
    ('006', 'WIFI + BAÑO + TV 4K + CABLE',  80.00, 1, 2, 3, TRUE, NOW()),
    ('007', 'WIFI + BAÑO + TV 4K + CABLE',  90.00, 1, 2, 2, TRUE, NOW()),
    ('008', 'WIFI + BAÑO + TV + CABLE',     70.00, 1, 2, 3, TRUE, NOW()),
    ('009', 'WIFI + BAÑO + TV + CABLE',     80.00, 1, 2, 2, TRUE, NOW()),
    ('010', 'WIFI + BAÑO + TV + CABLE',     70.00, 1, 2, 3, TRUE, NOW())
ON CONFLICT (numero) DO NOTHING;

-- ---------- 3. Productos (10) ----------

INSERT INTO PRODUCTO (nombre, detalle, precio, cantidad, estado, imagen_url, fechacreacion)
VALUES
    ('Agua Mineral 500ml',  'Botella de agua sin gas, cortesía',          3.50, 100, TRUE,  'https://goo.su/tUKXkxv',  '2026-06-15 08:00:00'),
    ('Pack Snacks Salados', 'Maní tostado y papas fritas',                8.00,  50, TRUE,  'https://goo.su/RXVpS',    '2026-06-15 08:30:00'),
    ('Kit de Aseo Dental',  'Cepillo de dientes y pasta dental de viaje', 5.00, 200, TRUE,  'https://goo.su/0zVTzol', '2026-06-15 09:00:00'),
    ('Chocolate Artesanal', 'Barra de chocolate bitter 70% cacao',        12.00,  30, TRUE,  'https://goo.su/sqwNBKk', '2026-06-15 09:30:00'),
    ('Vino Tinto (Mini)',   'Botella de vino tinto 187ml',               25.00,  20, TRUE,  'https://goo.su/U044BG',   '2026-06-15 10:00:00'),
    ('Gaseosa Cola 355ml',  'Bebida carbonatada clásica',                 6.00,  80, TRUE,  'https://goo.su/endpZf',   '2026-06-15 10:30:00'),
    ('Kit de Costura',      'Agujas, hilos varios y botones',             4.50,  40, FALSE, 'https://goo.su/wPRA7lJ',  '2026-06-15 11:00:00'),
    ('Jabón Artesanal',     'Jabón aromático de lavanda',                 7.50, 150, TRUE,  'https://goo.su/GQngW',    '2026-06-15 11:30:00'),
    ('Cerveza Artesanal',   'Cerveza rubia local 330ml',                 15.00,  60, TRUE,  'https://acortar.link/00pCwy', '2026-06-15 12:00:00'),
    ('Té Premium Variado',  'Caja con 5 sobres de té de hierbas',         9.00,  70, TRUE,  'https://acortar.link/KUR6bM', '2026-06-15 12:30:00')
ON CONFLICT (nombre) DO NOTHING;

-- ---------- 4. Imágenes de habitaciones (1 por habitación) ----------
-- Se resuelve el id por numero (no se asume que los ids sean 1-10)
-- y el NOT EXISTS evita duplicados en re-ejecuciones.

INSERT INTO IMAGEN_HABITACION (url_imagen, idhabitacion)
SELECT v.url, h.idhabitacion
FROM (VALUES
    ('https://acortar.link/vM4zPm', '001'),
    ('https://acortar.link/7Efz6S', '002'),
    ('https://acortar.link/dyMlXN', '003'),
    ('https://acortar.link/QEkGYe', '004'),
    ('https://acortar.link/u6tBRW', '005'),
    ('https://acortar.link/I6jGNY', '006'),
    ('https://acortar.link/9h1RaI', '007'),
    ('https://acortar.link/AFXmu5', '008'),
    ('https://acortar.link/1rtO9Y', '009'),
    ('https://acortar.link/auhVCk', '010')
) AS v(url, numero)
JOIN HABITACION h ON h.numero = v.numero
WHERE NOT EXISTS (
    SELECT 1 FROM IMAGEN_HABITACION x
    WHERE x.url_imagen = v.url AND x.idhabitacion = h.idhabitacion
);

COMMIT;

-- ---------- Verificación rápida (opcional) ----------
-- SELECT COUNT(*) FROM HABITACION;        -- esperado: 10
-- SELECT COUNT(*) FROM PRODUCTO;          -- esperado: 10
-- SELECT COUNT(*) FROM IMAGEN_HABITACION; -- esperado: 10
