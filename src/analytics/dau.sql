WITH tb_daily as (

    SELECT substr(DtCriacao,0, 11) AS DtDia,
        COUNT(DISTINCT IdCliente) AS DAU
    FROM transacoes
    GROUP BY 1
    ORDER BY DtDia
    LIMIT 10
)

SELECT * FROM tb_daily