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
    count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-56 day') THEN IdTransacao END) AS qtdeTransacao56,
    
    sum(qtdePontos) AS saldoVida,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-7 day') THEN qtdePontos ELSE 0 END) AS saldos7,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-14 day') THEN qtdePontos ELSE 0 END) AS saldos14,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-28 day') THEN qtdePontos ELSE 0 END) AS saldos28,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-56 day') THEN qtdePontos ELSE 0 END) AS saldos56,

    sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPosVida,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-7 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPos7,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-14 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPos14,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-28 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPos28,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-56 day') AND qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS qtdePontosPos56,

    sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNegaVida,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-7 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNega7,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-14 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNega14,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-28 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNega28,
    sum(CASE WHEN dtDia >= date('2026-02-26', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNega56
FROM tb_transacoes
GROUP BY IdCliente