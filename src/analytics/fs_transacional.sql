WITH tb_transacoes AS (
    SELECT *,
        substr(DtCriacao,0,11) AS dtDia,
        CAST(substr(DtCriacao, 12,2) AS int) AS dtHora
    FROM transacoes
    WHERE DtCriacao < '2026-02-26'
),

tb_agg_transacoes AS (
    SELECT IdCliente,

        max(julianday(date('2026-02-26', '-1 day')) - julianday(DtCriacao)) AS idadeDias,

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
        sum(CASE WHEN dtDia >= date('2026-02-26', '-56 day') AND qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS qtdePontosNega56,

        COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) AS qtdetransacaoManha,
        COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) AS qtdetransacaoTarde,
        COUNT(CASE WHEN dtHora > 21 AND dtHora < 10 THEN IdTransacao END) AS qtdetransacaoNoite,

        1. * COUNT(CASE WHEN dtHora BETWEEN 10 AND 14 THEN IdTransacao END) / count(IdTransacao) AS pctdetransacaoManha,
        1. * COUNT(CASE WHEN dtHora BETWEEN 15 AND 21 THEN IdTransacao END) / count(IdTransacao) AS pctdetransacaoTarde,
        1. * COUNT(CASE WHEN dtHora > 21 AND dtHora < 10 THEN IdTransacao END) / count(IdTransacao) AS pctdetransacaoNoite

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
),

tb_lag_dia AS (

    SELECT idCliente,
            dtDia,
            LAG(dtDia) OVER (PARTITION BY idCliente ORDER BY dtDia) AS lagDia
    FROM tb_horas_dia
),

tb_intervalo_dias AS (
    SELECT IdCliente,
            avg(julianday(dtDia) - julianDay(lagDia)) AS avgIntervaloDiasVida,
            avg(CASE WHEN dtDia >= date('2026-02-26', '-28 day') THEN julianday(dtDia) - julianday(lagDia) END) AS avgIntervaloD28
    FROM tb_lag_dia
    GROUP BY idCliente
),

tb_join AS (
    
    SELECT t1.*,
            t2.qtdeHorasVida,
            t2.qtdeHorasD7,
            t2.qtdeHorasD14,
            t2.qtdeHorasD28,
            t2.qtdeHorasD56,
            t3.avgIntervaloDiasVida,
            t3.avgIntervaloD28,
            t4.qtdeChatMessage,
            t4.qtdeAirflowLover,
            t4.qtdeResgatarPonei,
            t4.qtdeRLover,
            t4.qtdeListadePresenca,
            t4.qtdePresençaStreak,
            t4.qtdeTrocadePontosStreamElements,
            t4.qtdeReembolsoStreamElements,
            t4.qtdeRPG,
            t4.qtdeChurn_Model

    FROM tb_agg_cal AS t1

    LEFT JOIN tb_hora_cliente AS t2
    ON t1.IdCliente = t2.idCliente

    LEFT JOIN tb_intervalo_dias AS t3
    ON t1.idCliente = t3.idCliente

    LEFT JOIN tb_share_produtos AS t4
    ON t1.idCliente = t4.idCliente
),

tb_share_produtos AS (
    SELECT idCliente,
            1. * count(CASE WHEN DescNomeProduto = 'ChatMessage' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChatMessage,
            1. * count(CASE WHEN DescNomeProduto = 'Airflow Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeAirflowLover,
            1. * count(CASE WHEN DescNomeProduto = 'Resgatar Ponei' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeResgatarPonei,
            1. * count(CASE WHEN DescNomeProduto = 'R Lover' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRLover,
            1. * count(CASE WHEN DescNomeProduto = 'Lista de presença' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeListadePresenca,
            1. * count(CASE WHEN DescNomeProduto = 'Presença Streak' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdePresençaStreak,
            1. * count(CASE WHEN DescNomeProduto = 'Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeTrocadePontosStreamElements,
            1. * count(CASE WHEN DescNomeProduto = 'Reembolso: Troca de Pontos StreamElements' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeReembolsoStreamElements,
            1. * count(CASE WHEN DescCategoriaProduto ='rpg'THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeRPG,
            1. * count(CASE WHEN DescCategoriaProduto ='churn_model' THEN t1.IdTransacao END) / count(t1.IdTransacao) AS qtdeChurn_Model,
            t3.DescNomeProduto,
            t3.DescCategoriaProduto
    FROM tb_transacoes AS t1

    LEFT JOIN transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN produtos AS t3
    ON t2.IdProduto = t3.IdProduto

    GROUP BY idCliente
)

SELECT * FROM tb_join