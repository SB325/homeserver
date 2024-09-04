UPDATE pg_extension SET extrelocatable = TRUE WHERE extname = 'postgis';
ALTER EXTENSION postgis SET SCHEMA :new_schema_name;
SET search_path TO public;