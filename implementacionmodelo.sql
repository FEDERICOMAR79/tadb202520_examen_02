CREATE DATABASE secop_antioquia_db;
USE secop_antioquia_db;
CREATE LOGIN secop_user WITH PASSWORD = 'unaClav3';
CREATE USER secop_user FOR LOGIN secop_user;
ALTER ROLE db_ddladmin ADD MEMBER secop_user;
ALTER ROLE db_datareader ADD MEMBER secop_user;
ALTER ROLE db_datawriter ADD MEMBER secop_user;
GRANT EXECUTE TO secop_user;
CREATE SCHEMA secop;
CREATE SCHEMA esquema_corregido;


INSERT INTO esquema_corregido.departamentos (nombre_departamento)
SELECT DISTINCT TRIM(departamento_entidad)
FROM esquema_inicial.datos_originales
WHERE departamento_entidad IS NOT NULL AND TRIM(departamento_entidad) <> '';
GO


INSERT INTO esquema_corregido.ciudades (nombre_ciudad, id_departamento)
SELECT DISTINCT TRIM(d.ciudad_entidad), dep.id_departamento
FROM esquema_inicial.datos_originales d
JOIN esquema_corregido.departamentos dep ON TRIM(d.departamento_entidad) = dep.nombre_departamento
WHERE d.ciudad_entidad IS NOT NULL AND TRIM(d.ciudad_entidad) <> '';
GO


INSERT INTO esquema_corregido.ordenes_entidad (nombre_orden_entidad)
SELECT DISTINCT TRIM(orden_entidad)
FROM esquema_inicial.datos_originales
WHERE orden_entidad IS NOT NULL AND TRIM(orden_entidad) <> '';
GO


INSERT INTO esquema_corregido.entidades_centralizadas (nombre_entidad_centralizada)
SELECT DISTINCT TRIM(entidad_centralizada)
FROM esquema_inicial.datos_originales
WHERE entidad_centralizada IS NOT NULL AND TRIM(entidad_centralizada) <> '';
GO


INSERT INTO esquema_corregido.modalidades_contratacion (nombre_modalidad_contratacion)
SELECT DISTINCT TRIM(modalidad_contratacion)
FROM esquema_inicial.datos_originales
WHERE modalidad_contratacion IS NOT NULL AND TRIM(modalidad_contratacion) <> '';
GO


INSERT INTO esquema_corregido.unidades_duracion (nombre_unidad_duracion) VALUES ('días');
GO


INSERT INTO esquema_corregido.tipos_contrato (nombre_tipo_contrato)
SELECT DISTINCT TRIM(tipo_contrato)
FROM esquema_inicial.datos_originales
WHERE tipo_contrato IS NOT NULL AND TRIM(tipo_contrato) <> '';
GO




INSERT INTO esquema_corregido.unidades_duracion (nombre_unidad_duracion)
SELECT DISTINCT TRIM(unidad_duracion)
FROM esquema_inicial.datos_originales
WHERE unidad_duracion IS NOT NULL AND TRIM(unidad_duracion) <> '';
GO

CREATE TABLE esquema_corregido.ciudades (
    id_ciudad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_ciudad VARCHAR(50) NOT NULL,
    id_departamento INT NOT NULL FOREIGN KEY REFERENCES esquema_corregido.departamentos(id_departamento),
    CONSTRAINT ciudad_departamento_uk UNIQUE (id_departamento, nombre_ciudad)
);
USE secop_antioquia_db;
-- Creación de esquema
CREATE SCHEMA esquema_inicial;


CREATE TABLE esquema_inicial.datos_originales (
    nit_entidad VARCHAR(100),
    departamento_entidad VARCHAR(20),
    ciudad_entidad VARCHAR(50),
    orden_entidad VARCHAR(50),
    entidad_centralizada VARCHAR(20),
    id_proceso VARCHAR(100),
    fecha_proceso VARCHAR(20),
    precio_base VARCHAR(50),
    modalidad_contratacion VARCHAR(100),
    duracion VARCHAR(20),
    unidad_duracion VARCHAR(20),
    tipo_contrato VARCHAR(100)
);

USE secop_antioquia_db;
GO


CREATE TABLE esquema_corregido.departamentos (
    id_departamento INT IDENTITY(1,1) PRIMARY KEY,
    nombre_departamento VARCHAR(50) NOT NULL,
    CONSTRAINT departamentos_nombre_uk UNIQUE (nombre_departamento)
);
GO


CREATE TABLE esquema_corregido.ciudades (
    id_ciudad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_ciudad VARCHAR(100) NOT NULL,
    id_departamento INT NOT NULL,
    CONSTRAINT ciudad_departamento_uk UNIQUE (id_departamento, nombre_ciudad),
    CONSTRAINT fk_ciudades_departamentos FOREIGN KEY (id_departamento)
        REFERENCES esquema_corregido.departamentos(id_departamento)
);
GO


CREATE TABLE esquema_corregido.ordenes_entidad (
    id_orden_entidad INT IDENTITY(1,1) PRIMARY KEY,
    nombre_orden_entidad VARCHAR(100) NOT NULL,
    CONSTRAINT ordenes_entidad_nombre_uk UNIQUE (nombre_orden_entidad)
);
GO


CREATE TABLE esquema_corregido.entidades_centralizadas (
    id_entidad_centralizada INT IDENTITY(1,1) PRIMARY KEY,
    nombre_entidad_centralizada VARCHAR(100) NOT NULL,
    CONSTRAINT entidades_centralizadas_nombre_uk UNIQUE (nombre_entidad_centralizada)
);
GO


CREATE TABLE esquema_corregido.unidades_duracion (
    id_unidad_duracion INT IDENTITY(1,1) PRIMARY KEY,
    nombre_unidad_duracion VARCHAR(50) NOT NULL,
    CONSTRAINT unidades_nombre_uk UNIQUE (nombre_unidad_duracion)
);
GO


CREATE TABLE esquema_corregido.modalidades_contratacion (
    id_modalidad_contratacion INT IDENTITY(1,1) PRIMARY KEY,
    nombre_modalidad_contratacion VARCHAR(200) NOT NULL,
    CONSTRAINT modalidades_nombre_uk UNIQUE (nombre_modalidad_contratacion)
);
GO


CREATE TABLE esquema_corregido.tipos_contrato (
    id_tipo_contrato INT IDENTITY(1,1) PRIMARY KEY,
    nombre_tipo_contrato VARCHAR(200) NOT NULL,
    CONSTRAINT tipos_nombre_uk UNIQUE (nombre_tipo_contrato)
);
GO


CREATE TABLE esquema_corregido.entidades (
    id_entidad INT IDENTITY(1,1) PRIMARY KEY,
    nit_entidad BIGINT NOT NULL,
    id_ciudad INT NOT NULL,
    id_orden_entidad INT NOT NULL,
    id_entidad_centralizada INT NOT NULL,
    CONSTRAINT entidades_nit_uk UNIQUE (nit_entidad),
    CONSTRAINT fk_entidades_ciudades FOREIGN KEY (id_ciudad)
        REFERENCES esquema_corregido.ciudades(id_ciudad),
    CONSTRAINT fk_entidades_ordenes FOREIGN KEY (id_orden_entidad)
        REFERENCES esquema_corregido.ordenes_entidad(id_orden_entidad),
    CONSTRAINT fk_entidades_centralizadas FOREIGN KEY (id_entidad_centralizada)
        REFERENCES esquema_corregido.entidades_centralizadas(id_entidad_centralizada)
);
GO


CREATE TABLE esquema_corregido.procesos (
    id_proceso VARCHAR(100) PRIMARY KEY,
    id_entidad INT NOT NULL,
    fecha_proceso DATE NOT NULL,
    precio_base BIGINT NOT NULL,
    id_modalidad_contratacion INT NOT NULL,
    duracion INT NOT NULL,  -- Duración en días
    id_unidad_duracion INT NOT NULL,
    id_tipo_contrato INT NOT NULL,
    CONSTRAINT fk_procesos_entidades FOREIGN KEY (id_entidad)
        REFERENCES esquema_corregido.entidades(id_entidad),
    CONSTRAINT fk_procesos_modalidades FOREIGN KEY (id_modalidad_contratacion)
        REFERENCES esquema_corregido.modalidades_contratacion(id_modalidad_contratacion),
    CONSTRAINT fk_procesos_unidades_duracion FOREIGN KEY (id_unidad_duracion)
        REFERENCES esquema_corregido.unidades_duracion(id_unidad_duracion),
    CONSTRAINT fk_procesos_tipos_contrato FOREIGN KEY (id_tipo_contrato)
        REFERENCES esquema_corregido.tipos_contrato(id_tipo_contrato)
);
GO


INSERT INTO esquema_corregido.departamentos (nombre_departamento)
SELECT DISTINCT TRIM(departamento_entidad)
FROM esquema_inicial.datos_originales
WHERE departamento_entidad IS NOT NULL AND TRIM(departamento_entidad) <> '';


INSERT INTO esquema_corregido.ciudades (nombre_ciudad, id_departamento)
SELECT DISTINCT TRIM(d.ciudad_entidad), dep.id_departamento
FROM esquema_inicial.datos_originales d
JOIN esquema_corregido.departamentos dep
  ON TRIM(d.departamento_entidad) = dep.nombre_departamento
WHERE d.ciudad_entidad IS NOT NULL AND TRIM(d.ciudad_entidad) <> '';


INSERT INTO esquema_corregido.ordenes_entidad (nombre_orden_entidad)
SELECT DISTINCT TRIM(orden_entidad)
FROM esquema_inicial.datos_originales
WHERE orden_entidad IS NOT NULL AND TRIM(orden_entidad) <> '';


INSERT INTO esquema_corregido.entidades_centralizadas (nombre_entidad_centralizada)
SELECT DISTINCT TRIM(entidad_centralizada)
FROM esquema_inicial.datos_originales
WHERE entidad_centralizada IS NOT NULL AND TRIM(entidad_centralizada) <> '';


INSERT INTO esquema_corregido.entidades (nit_entidad, id_ciudad, id_orden_entidad, id_entidad_centralizada)
SELECT nit_entidad, id_ciudad, id_orden_entidad, id_entidad_centralizada
FROM (
    SELECT
        CAST(d.nit_entidad AS BIGINT) AS nit_entidad,
        c.id_ciudad,
        oe.id_orden_entidad,
        ec.id_entidad_centralizada,
        ROW_NUMBER() OVER (PARTITION BY d.nit_entidad ORDER BY d.orden_entidad DESC) AS rn
    FROM esquema_inicial.datos_originales d
    JOIN esquema_corregido.departamentos dep
      ON LTRIM(RTRIM(d.departamento_entidad)) = dep.nombre_departamento
    JOIN esquema_corregido.ciudades c
      ON LTRIM(RTRIM(d.ciudad_entidad)) = c.nombre_ciudad
     AND c.id_departamento = dep.id_departamento
    JOIN esquema_corregido.ordenes_entidad oe
      ON oe.nombre_orden_entidad = LTRIM(RTRIM(d.orden_entidad))
    JOIN esquema_corregido.entidades_centralizadas ec
      ON ec.nombre_entidad_centralizada = LTRIM(RTRIM(d.entidad_centralizada))
    WHERE d.nit_entidad IS NOT NULL
) t
WHERE t.rn = 1;



INSERT INTO esquema_corregido.modalidades_contratacion (nombre_modalidad_contratacion)
SELECT DISTINCT TRIM(modalidad_contratacion)
FROM esquema_inicial.datos_originales
WHERE modalidad_contratacion IS NOT NULL AND TRIM(modalidad_contratacion) <> '';


INSERT INTO esquema_corregido.unidades_duracion (nombre_unidad_duracion)
VALUES ('días');


INSERT INTO esquema_corregido.tipos_contrato (nombre_tipo_contrato)
SELECT DISTINCT TRIM(tipo_contrato)
FROM esquema_inicial.datos_originales
WHERE tipo_contrato IS NOT NULL AND TRIM(tipo_contrato) <> '';

CREATE OR ALTER FUNCTION esquema_corregido.f_limpiar_numero (@valor NVARCHAR(200))
RETURNS BIGINT
AS
BEGIN
    DECLARE @soloNumeros NVARCHAR(200) = '';
    DECLARE @i INT = 1;
    DECLARE @len INT = LEN(@valor);
    DECLARE @c NCHAR(1);

    WHILE @i <= @len
    BEGIN
        SET @c = SUBSTRING(@valor, @i, 1);
        IF @c LIKE '[0-9]'
            SET @soloNumeros = @soloNumeros + @c;
        SET @i = @i + 1;
    END

    RETURN TRY_CAST(@soloNumeros AS BIGINT);
END;
GO

CREATE OR ALTER FUNCTION esquema_corregido.f_procesar_duracion (
    @duracion_raw NVARCHAR(100),
    @unidad_raw NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @num BIGINT = esquema_corregido.f_limpiar_numero(@duracion_raw);
    DECLARE @unidad NVARCHAR(100) = UPPER(LTRIM(RTRIM(@unidad_raw)));
    DECLARE @resultado INT;

    IF @unidad LIKE '%DÍA%' OR @unidad LIKE '%DIA%'
        SET @resultado = CEILING(TRY_CAST(@num AS FLOAT));
    ELSE IF @unidad LIKE '%SEMANA%'
        SET @resultado = FLOOR(TRY_CAST(@num AS FLOAT) * 7);
    ELSE IF @unidad LIKE '%MES%'
        SET @resultado = CEILING(TRY_CAST(@num AS FLOAT) * 30);
    ELSE IF @unidad LIKE '%AÑO%' OR @unidad LIKE '%ANIO%'
        SET @resultado = FLOOR(TRY_CAST(@num AS FLOAT) * 365);

    RETURN @resultado;
END;
GO



INSERT INTO esquema_corregido.procesos
    (id_proceso, id_entidad, fecha_proceso, precio_base, id_modalidad_contratacion, duracion, id_unidad_duracion, id_tipo_contrato)
SELECT DISTINCT
    LTRIM(RTRIM(d.id_proceso)),
    e.id_entidad,
    TRY_CONVERT(DATE, d.fecha_proceso, 101),   -- equivalente de TO_DATE
    esquema_corregido.f_limpiar_numero(d.precio_base),
    mc.id_modalidad_contratacion,
    esquema_corregido.f_procesar_duracion(d.duracion, d.unidad_duracion),
    (SELECT id_unidad_duracion FROM esquema_corregido.unidades_duracion WHERE nombre_unidad_duracion = 'días'),
    tc.id_tipo_contrato
FROM esquema_inicial.datos_originales d
JOIN esquema_corregido.entidades e
  ON e.nit_entidad = TRY_CAST(LTRIM(RTRIM(d.nit_entidad)) AS BIGINT)
JOIN esquema_corregido.modalidades_contratacion mc
  ON mc.nombre_modalidad_contratacion = LTRIM(RTRIM(d.modalidad_contratacion))
JOIN esquema_corregido.tipos_contrato tc
  ON tc.nombre_tipo_contrato = LTRIM(RTRIM(d.tipo_contrato))
WHERE LTRIM(RTRIM(d.id_proceso)) IS NOT NULL
  AND LTRIM(RTRIM(d.id_proceso)) <> '';


SELECT COUNT(*)
FROM esquema_corregido.procesos;
GO


CREATE OR ALTER VIEW esquema_corregido.procesos_completos
AS
SELECT
    p.id_proceso,
    p.fecha_proceso,
    p.precio_base,
    p.duracion,

    u.nombre_unidad_duracion AS unidad_duracion,
    tc.nombre_tipo_contrato AS tipo_contrato,
    mc.nombre_modalidad_contratacion AS modalidad_contratacion,

    e.nit_entidad,
    oe.nombre_orden_entidad AS orden_entidad,
    ec.nombre_entidad_centralizada AS entidad_centralizada,

    c.nombre_ciudad,
    d.nombre_departamento
FROM esquema_corregido.procesos p
JOIN esquema_corregido.entidades e
  ON p.id_entidad = e.id_entidad
JOIN esquema_corregido.ciudades c
  ON e.id_ciudad = c.id_ciudad
JOIN esquema_corregido.departamentos d
  ON c.id_departamento = d.id_departamento
JOIN esquema_corregido.ordenes_entidad oe
  ON e.id_orden_entidad = oe.id_orden_entidad
JOIN esquema_corregido.entidades_centralizadas ec
  ON e.id_entidad_centralizada = ec.id_entidad_centralizada
JOIN esquema_corregido.modalidades_contratacion mc
  ON p.id_modalidad_contratacion = mc.id_modalidad_contratacion
JOIN esquema_corregido.tipos_contrato tc
  ON p.id_tipo_contrato = tc.id_tipo_contrato
JOIN esquema_corregido.unidades_duracion u
  ON p.id_unidad_duracion = u.id_unidad_duracion;
GO



CREATE VIEW esquema_corregido.procesos_mes
WITH SCHEMABINDING
AS
SELECT
    CONVERT(CHAR(7), p.fecha_proceso, 120) AS mes,  -- Formato YYYY-MM
    mc.nombre_modalidad_contratacion,
    tc.nombre_tipo_contrato,
    p.precio_base,
    COUNT_BIG(*) AS count_big  -- Obligatorio en vistas indexadas
FROM esquema_corregido.procesos p
JOIN esquema_corregido.modalidades_contratacion mc
    ON p.id_modalidad_contratacion = mc.id_modalidad_contratacion
JOIN esquema_corregido.tipos_contrato tc
    ON p.id_tipo_contrato = tc.id_tipo_contrato
GROUP BY
    CONVERT(CHAR(7), p.fecha_proceso, 120),
    mc.nombre_modalidad_contratacion,
    tc.nombre_tipo_contrato,
    p.precio_base;
GO


CREATE UNIQUE CLUSTERED INDEX idx_procesos_mes_clustered
ON esquema_corregido.procesos_mes(mes, nombre_modalidad_contratacion, nombre_tipo_contrato, precio_base);
GO








