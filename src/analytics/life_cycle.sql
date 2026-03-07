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
),

tb_freq_valor AS (
        SELECT idCliente,
                count(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
                sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos
                -- sum(abs(qtdePontos)) AS qtdePontosAbs
        FROM transacoes
        WHERE DtCriacao < '{date}'
        AND DtCriacao >= date('{date}','-28 day')
        GROUP BY idCliente
        ORDER BY qtdeFrequencia
),

tb_cluster AS (
        SELECT *,
        CASE
                WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 1500 THEN '12-HYPER'
                WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '22-EFICIENTES'
                WHEN qtdeFrequencia <= 10 AND qtdePontosPos >= 750 THEN '11-INDECISO'
                WHEN qtdeFrequencia > 10 AND qtdePontosPos >= 1500 THEN '21-ESFORÇADO'
                WHEN qtdeFrequencia < 5 THEN '00-LURKER'
                WHEN qtdeFrequencia <= 10 THEN '01-PREGUIÇOSO'
                WHEN qtdeFrequencia > 10 THEN '20-POTENCIAL'
        END AS cluster
FROM tb_freq_valor
)

SELECT t1.*,
        t2.qtdeFrequencia,
        t2.qtdePontosPos,
        t2.cluster
FROM tblife_cicle AS t1
LEFT JOIN tb_cluster AS t2
ON t1.IdCliente = t2.IdCliente