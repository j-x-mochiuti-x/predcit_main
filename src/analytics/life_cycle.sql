WITH tb_daily AS (
    SELECT DISTINCT
    IdCliente,
    substr(DtCriacao,1, 10) AS DtDia
    FROM transacoes
    WHERE DtCriacao < '{date}'
),

tb_idade AS (
SELECT IdCliente,
    --MIN(DtDia) AS DtPrimeiraEntrada,
    cast(MAX(julianday('{date}') - julianday(Dtdia)) AS int) AS DiasDesdePrimeiraEntrada,
    --MAX(DtDia) AS DtUltimaEntrada,
    cast(MIN(julianday('{date}') - julianday(Dtdia)) AS int) AS DiasDesdeUltimaEntrada
FROM tb_daily
GROUP BY IdCliente
),

tb_rn AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY IdCliente ORDER BY DtDia DESC) AS rnDia
    FROM tb_daily
),

tb_penultimaAtivacao AS (
    SELECT *,
    CAST(julianday('{date}') - julianday(Dtdia) AS INT) AS DiasDesdePenultimaEntrada
    FROM tb_rn
    WHERE rnDia = 2
),

tblife_cicle AS (
SELECT t1.*,
        t2.DiasDesdePenultimaEntrada,
        CASE
            WHEN DiasDesdePrimeiraEntrada <= 7 THEN '01 CURIOSO'
            WHEN DiasDesdeUltimaEntrada <= 7 AND DiasDesdePenultimaEntrada - DiasDesdeUltimaEntrada <= 14 THEN '02 LEAL'
            WHEN DiasDesdeUltimaEntrada BETWEEN 8 AND 14 THEN '03 TURISTA'
            WHEN DiasDesdeUltimaEntrada BETWEEN 15 AND 28 THEN '04 DESENCATANDO'
            WHEN DiasDesdeUltimaEntrada > 28 THEN '05 ZUMBI'
            WHEN DiasDesdeUltimaEntrada <= 7 AND DiasDesdePenultimaEntrada - DiasDesdeUltimaEntrada BETWEEN 15 AND 27 THEN '06 REATIVADO'
            WHEN DiasDesdeUltimaEntrada <= 7 AND DiasDesdePenultimaEntrada - DiasDesdeUltimaEntrada > 27 THEN '07 REBORN'
        END AS life_cicle
 FROM tb_idade AS t1
LEFT JOIN tb_penultimaAtivacao AS t2
ON t1.IdCliente = t2.IdCliente
)

SELECT date('{date}', '-1 day') AS DtRef, *
FROM tblife_cicle;
