-- Caso 1: análisis de propiedades
SELECT
    UPPER(id_tipo_propiedad) AS tipo,
    COUNT(*) AS total_propiedades,
    TO_CHAR(
        MAX(valor_arriendo), '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS max_arriendo,
    TO_CHAR(
        ROUND(AVG(valor_arriendo)), '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS promedio_arriendo,
    TO_CHAR(
        MIN(valor_arriendo), '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS min_arriendo,
    CASE
        WHEN MAX(valor_arriendo) > 1000000 THEN 'PREMIUM'
        ELSE 'ESTÁNDAR'
    END AS clasificacion,
    TO_CHAR(
        SUM(NVL(valor_gasto_comun, 0)), '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS total_gastos_comunes
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(NVL(valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(NVL(valor_gasto_comun, 0)) DESC;





-- Caso 2: analisis de antiguedad de empleados
SELECT
    UPPER(nombre_emp || ' ' || appaterno_emp) AS "Nombre Empleado",
    TO_CHAR(
        sueldo_emp, '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS "Sueldo con Formato",
    CASE
        WHEN sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "Clasificación Sueldo",
    TRUNC(
        MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12
    ) AS "Años Antigüedad",
    CASE
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 20 THEN
            'Corresponde bono 15%: ' ||
            TO_CHAR(
                ROUND(sueldo_emp * 0.15), '$999G999G990',
                'NLS_NUMERIC_CHARACTERS = '',.'''
            )
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) >= 11 THEN
            'Corresponde bono 10%: ' ||
            TO_CHAR(
                ROUND(sueldo_emp * 0.10), '$999G999G990',
                'NLS_NUMERIC_CHARACTERS = '',.'''
            )
        ELSE
            'Corresponde bono  5%: ' ||
            TO_CHAR(
                ROUND(sueldo_emp * 0.05), '$999G999G990',
                'NLS_NUMERIC_CHARACTERS = '',.'''
            )
    END AS bono
FROM empleado
WHERE id_categoria_emp = 3
  AND id_sucursal <> &CODIGO_SUCURSAL
  AND MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12 > 5
ORDER BY sueldo_emp DESC;





-- Caso 3: listado de clientes por clasificacion de renta
-- Se considera telefono registrado si existe celular o telefono fijo.
SELECT
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS clasificacion_renta,
    COUNT(*) AS cantidad_clientes,
    TO_CHAR(
        ROUND(AVG(renta_cli)), '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS renta_promedio,
    CASE
        WHEN COUNT(NVL(celular_cli, fonofijo_cli)) = 0
            THEN 'Clientes sin Teléfono'
        ELSE 'Clientes con Teléfono'
    END AS estado_telefono
FROM cliente
GROUP BY
    CASE
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli >= 600000 THEN 'ALTA'
        WHEN renta_cli >= 300000 THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING AVG(renta_cli) > 200000;