WITH tb_transacoes AS (
    SELECT *,
        substr(DtCriacao,0,11) AS dtDia
    FROM transacoes
    WHERE DtCriacao < '2026-02-26'
)

SELECT IdCliente,
    count(DISTINCT dtDia) AS qtdeAtivacaoDia,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-7 day') THEN dtDia END) AS qtdeAtivacao7,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-14 day') THEN dtDia END) AS qtdeAtivacao14,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-28 day') THEN dtDia END) AS qtdeAtivacao28,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-56 day') THEN dtDia END) AS qtdeAtivacao56,

    count(DISTINCT IdTransacao) AS qtdeTransacaoDia,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-7 day') THEN IdTransacao END) AS qtdeTransacao7,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-14 day') THEN IdTransacao END) AS qtdeTransacao14,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-28 day') THEN IdTransacao END) AS qtdeTransacao28,
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-56 day') THEN IdTransacao END) AS qtdeTransacao56
FROM tb_transacoes
GROUP BY IdCliente