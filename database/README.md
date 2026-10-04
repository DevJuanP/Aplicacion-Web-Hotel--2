# database/ — Migraciones y seed (PostgreSQL)

Deja la BD lista ejecutando los scripts **en este orden**:

| Orden | Archivo | Contenido |
|---|---|---|
| 1 | `01_schema.sql` | DDL: 12 tablas + PK/FK/UNIQUE/DEFAULT (derivado de las entidades JPA) |
| 2 | `02_procedures.sql` | Procedimientos/funciones CRUD (`procedmientos Actualizados.sql` limpio) |
| 3 | `03_reports.sql` | Funciones de reportes + dashboard |
| 4 | `04_indexes.sql` | Índices de apoyo a reportes |
| 5 | `seed.sql` | Datos semilla (`Datos Hotel.sql` + `TIPO_PERSONA`) |

`run_all.sql` ejecuta todo lo anterior en orden (atajo opcional).

## Uso

### Opción A — todo de una vez (recomendado)

```powershell
cd database
psql -U postgres -d DB_HOTEL -f run_all.sql
```

### Opción B — paso a paso

```powershell
cd database
psql -U postgres -d DB_HOTEL -f 01_schema.sql
psql -U postgres -d DB_HOTEL -f 02_procedures.sql
psql -U postgres -d DB_HOTEL -f 03_reports.sql
psql -U postgres -d DB_HOTEL -f 04_indexes.sql
psql -U postgres -d DB_HOTEL -f seed.sql
```

> Crea antes la BD vacía si no existe: `createdb -U postgres DB_HOTEL`
> (el nombre `DB_HOTEL` es el que usa el backend en `application.properties`).
> En pgAdmin: clic derecho en Databases → Create → `DB_HOTEL`, luego
> Query Tool → abrir cada archivo en orden → Execute.

### Verificación rápida

```sql
SELECT COUNT(*) FROM HABITACION;        -- 10
SELECT COUNT(*) FROM PRODUCTO;          -- 10
SELECT COUNT(*) FROM IMAGEN_HABITACION; -- 10
SELECT * FROM fn_Dashboard_Estadisticas();
```

## Notas

- Los scripts son **re-ejecutables**: usan `IF NOT EXISTS` / `CREATE OR REPLACE` / `ON CONFLICT DO NOTHING`.
- `seed.sql` está pensado para una BD creada con `01_schema.sql` (los `UNIQUE` en `descripcion`/`nombre` los crea ese script y son los que permiten el `ON CONFLICT`).
- Los **usuarios no van en el seed** porque la clave usa BCrypt. Al arrancar el backend, `DataInitializer` crea automáticamente:
  - Administrador → `yaxoncalle@gmail.com` / `123123`
  - Empleado → `Trabajadorpaul@gmail.com` / `456456`
- Limpieza respecto a los archivos originales: se quitaron los `SELECT` sueltos de depuración (`select * from venta`, `select * from persona`, …); el `DROP FUNCTION sp_RegistrarVenta(INT, VARCHAR, TEXT)` se conservó con `IF EXISTS` porque esa función cambió de retorno `BOOLEAN` → `INT` y `CREATE OR REPLACE` no permite ese cambio.
