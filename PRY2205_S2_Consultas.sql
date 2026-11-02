-- CASO 1

SELECT
    NUMFACTURA AS "N° Factura",
    TO_CHAR(
    FECHA,
    'DD "de" Month YYYY',
    'NLS_DATE_LANGUAGE = SPANISH'
) AS "Fecha Emisión",
    LPAD(RUTCLIENTE, 10, '0') AS "RUT Cliente",
    TO_CHAR(ROUND(NETO, 0), '$9G999G990',
    'NLS_NUMERIC_CHARACTERS = '',.''') AS "Monto Neto",

    TO_CHAR(ROUND(IVA, 0), '$9G999G990',
    'NLS_NUMERIC_CHARACTERS = '',.''') AS "Monto Iva",

    TO_CHAR(ROUND(TOTAL, 0), '$9G999G990',
    'NLS_NUMERIC_CHARACTERS = '',.''') AS "Total Factura",
CASE
    WHEN TOTAL BETWEEN 0 AND 50000 THEN 'Bajo'
    WHEN TOTAL BETWEEN 50001 AND 100000 THEN 'Medio'
    WHEN TOTAL > 100000 THEN 'Alto'
    ELSE 'Sin clasificación'
END AS "Categoría Monto",
    DECODE(
    CODPAGO,
    1, 'EFECTIVO',
    2, 'TARJETA DEBITO',
    3, 'TARJETA CREDITO',
    'CHEQUE'
) AS "Forma de pago"
FROM FACTURA
WHERE EXTRACT(YEAR FROM FECHA) =
      EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY FECHA DESC, NETO DESC;


-- CASO 2: CLASIFICACIÓN DE CLIENTES
SELECT
    LPAD(RUTCLIENTE, 12, '*') AS "RUT",
    INITCAP(NOMBRE) AS "Cliente",
    NVL(TO_CHAR(TELEFONO), 'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(CODCOMUNA), 'Sin comuna') AS "COMUNA",
    ESTADO AS "ESTADO",
CASE
    WHEN SALDO / CREDITO < 0.5 THEN
        'Bueno (' ||
        TO_CHAR(ROUND(CREDITO - SALDO, 0), '$9G999G990',
            'NLS_NUMERIC_CHARACTERS = '',.''') || ')'

    WHEN SALDO / CREDITO BETWEEN 0.5 AND 0.8 THEN
        'Regular (' ||
        TO_CHAR(ROUND(SALDO, 0), '$9G999G990',
            'NLS_NUMERIC_CHARACTERS = '',.''') || ')'

    WHEN SALDO / CREDITO > 0.8 THEN 'Crítico'
END AS "Estado Crédito",
    NVL(
    UPPER(SUBSTR(MAIL, INSTR(MAIL, '@') + 1)),
    'Correo no registrado'
) AS "Dominio Correo"
FROM CLIENTE
WHERE ESTADO = 'A'
  AND CREDITO > 0
ORDER BY NOMBRE ASC;

-- CASO 3: STOCK DE PRODUCTOS

SELECT
    CODPRODUCTO AS "ID",
    INITCAP(DESCRIPCION) AS "Descripción de Producto",
    NVL2(
    VALORCOMPRADOLAR,
    TO_CHAR(VALORCOMPRADOLAR, 'TM9',
        'NLS_NUMERIC_CHARACTERS = '',.''') || ' USD',
    'Sin registro'
) AS "Compra en USD",
NVL2(
    VALORCOMPRADOLAR,
    TO_CHAR(
        ROUND(VALORCOMPRADOLAR * &TIPOCAMBIO_DOLAR, 0),
        '$999G999G990',
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) || ' PESOS',
    'Sin registro'
) AS "USD convertido",
    TOTALSTOCK AS "Stock",
CASE
    WHEN TOTALSTOCK IS NULL THEN 'Sin datos'
    WHEN TOTALSTOCK < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
    WHEN TOTALSTOCK <= &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
    ELSE 'OK'
END AS "Alerta Stock",
CASE
    WHEN TOTALSTOCK > 80 THEN
        TO_CHAR(
            ROUND(VUNITARIO * 0.90, 0),
            '$999G999G990',
            'NLS_NUMERIC_CHARACTERS = '',.'''
        )
    ELSE 'N/A'
END AS "Precio Oferta"
FROM PRODUCTO
WHERE UPPER(DESCRIPCION) LIKE '%ZAPATO%'
  AND LOWER(PROCEDENCIA) = 'i'
ORDER BY CODPRODUCTO DESC;