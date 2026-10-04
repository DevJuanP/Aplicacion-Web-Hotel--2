-- =============================================================
-- Hotel Cibertec · Ejecutor maestro (opcional)
-- Uso desde la carpeta database/:
--   psql -U postgres -d DB_HOTEL -f run_all.sql
-- Ejecuta las migraciones + seed en el orden correcto.
-- =============================================================

\echo '--- 01_schema.sql ---'
\i 01_schema.sql

\echo '--- 02_procedures.sql ---'
\i 02_procedures.sql

\echo '--- 03_reports.sql ---'
\i 03_reports.sql

\echo '--- 04_indexes.sql ---'
\i 04_indexes.sql

\echo '--- seed.sql ---'
\i seed.sql

\echo '--- Base de datos lista ---'
