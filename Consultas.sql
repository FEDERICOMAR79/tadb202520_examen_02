SELECT
    c.nombre_ciudad AS ciudad,
    MIN(p.duracion) AS duracion_minima_contrato,
    ROUND(AVG(CAST(p.duracion AS FLOAT)), 2) AS duracion_promedio_contrato,
    MAX(p.duracion) AS duracion_maxima_contrato
FROM esquema_corregido.procesos p
JOIN esquema_corregido.entidades e
  ON p.id_entidad = e.id_entidad
JOIN esquema_corregido.ciudades c
  ON e.id_ciudad = c.id_ciudad
GROUP BY c.nombre_ciudad
ORDER BY c.nombre_ciudad;

-- Índice para acelerar JOIN procesos -> entidades y agregados de duracion
CREATE INDEX idx_procesos_id_entidad
ON esquema_corregido.procesos (id_entidad, duracion);

-- Índice para acelerar JOIN entidades -> ciudades
CREATE INDEX idx_entidades_id_ciudad
ON esquema_corregido.entidades (id_ciudad);




WITH conteos_modalidad AS (
    SELECT mes,
           nombre_modalidad_contratacion,
           COUNT(*) AS cnt,
           ROW_NUMBER() OVER (PARTITION BY mes ORDER BY COUNT(*) DESC) AS rn
    FROM esquema_corregido.procesos_mes
    GROUP BY mes, nombre_modalidad_contratacion
),
modalidad_top AS (
    SELECT mes, nombre_modalidad_contratacion
    FROM conteos_modalidad
    WHERE rn = 1
),
conteos_tipo AS (
    SELECT mes,
           nombre_tipo_contrato,
           COUNT(*) AS cnt,
           ROW_NUMBER() OVER (PARTITION BY mes ORDER BY COUNT(*) DESC) AS rn
    FROM esquema_corregido.procesos_mes
    GROUP BY mes, nombre_tipo_contrato
),
tipo_top AS (
    SELECT mes, nombre_tipo_contrato
    FROM conteos_tipo
    WHERE rn = 1
),
precios_mes AS (
    SELECT mes,
           MIN(precio_base) AS precio_min,
           MAX(precio_base) AS precio_max,
           ROUND(AVG(CAST(precio_base AS FLOAT)), 2) AS precio_prom
    FROM esquema_corregido.procesos_mes
    GROUP BY mes
)
SELECT pm.mes,
       m.nombre_modalidad_contratacion AS modalidad_mas_recurrente,
       t.nombre_tipo_contrato AS tipo_mas_recurrente,
       pm.precio_min,
       pm.precio_max,
       pm.precio_prom,
       COUNT(*) OVER (PARTITION BY pm.mes) AS cantidad_procesos
FROM precios_mes pm
JOIN modalidad_top m ON pm.mes = m.mes
JOIN tipo_top t ON pm.mes = t.mes
ORDER BY pm.mes;

SELECT
    mes,
    MIN(precio_base) AS precio_minimo,
    MAX(precio_base) AS precio_maximo,
    ROUND(AVG(CAST(precio_base AS FLOAT)), 2) AS precio_promedio
FROM esquema_corregido.procesos_mes
GROUP BY mes
ORDER BY mes;

-- Índice para búsquedas y agrupaciones por mes
CREATE NONCLUSTERED INDEX idx_procesos_mes_mes
    ON esquema_corregido.procesos_mes (mes);

-- Índice para top modalidad por mes
CREATE NONCLUSTERED INDEX idx_procesos_mes_modalidad
    ON esquema_corregido.procesos_mes (mes, nombre_modalidad_contratacion);

-- Índice para top tipo de contrato por mes
CREATE NONCLUSTERED INDEX idx_procesos_mes_tipo
    ON esquema_corregido.procesos_mes (mes, nombre_tipo_contrato);

-- Índice para precios (MIN, MAX, AVG) agrupados por mes
CREATE NONCLUSTERED INDEX idx_procesos_mes_precios
    ON esquema_corregido.procesos_mes (mes)
    INCLUDE (precio_base);
