WITH tb_transacoes AS (
    SELECT *,
        substr(DtCriacao,0,11) AS dtDia
    FROM transacoes
    WHERE DtCriacao < '2026-02-26'
),

tb_agg_transacoes AS (
    SELECT IdCliente,
        count(DISTINCT dtDia) AS qtdeAtivacaoVida,
        count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-7 day') THEN dtDia END) AS qtdeAtivacao7,
        count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-14 day') THEN dtDia END) AS qtdeAtivacao14,
        count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-28 day') THEN dtDia END) AS qtdeAtivacao28,
        count(DISTINCT CASE WHEN dtDia >= date('2026-02-26', '-56 day') THEN dtDia END) AS qtdeAtivacao56,

        count(DISTINCT IdTransacao) AS qtdeTransacaoVida,
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
),

tb_agg_cal AS (
    SELECT *,
        COALESCE(1. * qtdeTransacaoVida / qtdeAtivacaoVida,0) AS qtdeTransacaoDiaVida,
        COALESCE(1. * qtdeTransacao7 / qtdeAtivacao7,0) AS qtdeTransacaoDiaDia7,
        COALESCE(1. * qtdeTransacao14 / qtdeAtivacao14,0) AS qtdeTransacaoDiaDia14,
        COALESCE(1. * qtdeTransacao28 / qtdeAtivacao28,0) AS qtdeTransacaoDiaDia28,
        COALESCE(1. * qtdeTransacao56 / qtdeAtivacao56,0) AS qtdeTransacaoDiaDia56,
        coalesce(1. * qtdeTransacao28 / 28, 0) AS pctAtivacaoMAU

    FROM tb_agg_transacoes
),

tb_horas_dia AS (
    SELECT IdCliente,
    dtDia,
    24 * (max(julianday(DtCriacao)) - min(julianday(DtCriacao))) AS duracao

    FROM tb_transacoes
    GROUP BY IdCliente, dtDia
),

tb_hora_cliente AS (
    SELECT IdCliente,
            SUM(duracao) AS qtdeHorasVida,
            SUM(CASE WHEN dtDia >= date('2026-02-26', '-7 day') THEN duracao ELSE 0 END) AS qtdeHorasD7,
            SUM(CASE WHEN dtDia >= date('2026-02-26', '-14 day') THEN duracao ELSE 0 END) AS qtdeHorasD14,
            SUM(CASE WHEN dtDia >= date('2026-02-26', '-28 day') THEN duracao ELSE 0 END) AS qtdeHorasD28,
            SUM(CASE WHEN dtDia >= date('2026-02-26', '-56 day') THEN duracao ELSE 0 END) AS qtdeHorasD56
    FROM tb_horas_dia
    GROUP BY IdCliente
)