DROP TABLE IF EXISTS abt_fiel;
CREATE TABLE IF NOT EXISTS abt_fiel AS

WITH tb_join AS (
    SELECT t1.DtRef,
           t1.IdCliente,
           t1.life_cicle,
           t2.life_cicle,
           CASE WHEN t2.life_cicle = '02 FIEL' THEN 1 ELSE 0 END AS flFiel,
           ROW_NUMBER() OVER (PARTITION BY t1.IdCliente ORDER BY random()) AS randomCol

    FROM life_cycle AS t1
    LEFT JOIN tblife_cicle AS t2
    ON t1.IdCliente = t2.IdCliente
    AND date(t1.DtRef, '+28 day') = date(t2.DtRef)

    WHERE ((t1.DtRef >= '2024-03-01' AND t1.dtRef <= '2025-08-01')
            OR t1.dtRef='2025-09-01')
    AND t1.descLifeCycle <> '05-ZUMBI'
),

tb_cohor  AS (
    SELECT t1.DtRef,
           t1.IdCliente,
           t1.flFiel

    FROM tb_join AS t1
    WHERE randomCol <= 2
    ORDER BY IdCliente, DtRef
)

SELECT t1.*,
       t2.idadeDias, 
       t2.qtdeAtivacaoVida,
       t2.qtdeAtivacao7,
       t2.qtdeAtivacao14,
       t2.qtdeAtivacao28,
       t2.qtdeAtivacao56,
       t2.qtdeTransacaoVida,
       t2.qtdeTransacao7,
       t2.qtdeTransacao14,
       t2.qtdeTransacao28,
       t2.qtdeTransacao56,
       t2.saldoVida,
       t2.saldos7,
       t2.saldos14,
       t2.saldos28,
       t2.saldos56,
       t2.qtdePontosPosVida,
       t2.qtdePontosPos7,
       t2.qtdePontosPos14,
       t2.qtdePontosPos28,
       t2.qtdePontosPos56,
       t2.qtdePontosNegaVida,
       t2.qtdePontosNega7,
       t2.qtdePontosNega14,
       t2.qtdePontosNega28,
       t2.qtdePontosNega56,
       t2.qtdetransacaoManha,
       t2.qtdetransacaoTarde,
       t2.qtdetransacaoNoite,
       t2.pctdetransacaoManha,
       t2.pctdetransacaoTarde,
       t2.pctdetransacaoNoite,
       t2.qtdeTransacaoDiaVida,
       t2.qtdeTransacaoDiaDia7,
       t2.qtdeTransacaoDiaDia14,
       t2.qtdeTransacaoDiaDia28,
       t2.qtdeTransacaoDiaDia56,
       t2.pctAtivacaoMAU,
       t2.qtdeHorasVida,
       t2.qtdeHorasD7,
       t2.qtdeHorasD14,
       t2.qtdeHorasD28,
       t2.qtdeHorasD56,
       t2.avgIntervaloDiasVida,
       t2.avgIntervaloD28,
       t2.qtdeChatMessage,
       t2.qtdeAirflowLover,
       t2.qtdeResgatarPonei,
       t2.qtdeRLover,
       t2.qtdeListadePresenca,
       t2.qtdePresençaStreak,
       t2.qtdeTrocadePontosStreamElements,
       t2.qtdeReembolsoStreamElements,
       t2.qtdeRPG,
       t2.qtdeChurn_Model,
       t3.qtdeFrequencia,
       t3.descLifeCycleAtual,
       t3.descLifeCycleD28,
       t3.pctCurioso,
       t3.pctFiel,
       t3.pctTurista,
       t3.pctDesencantada,
       t3.pctZumbi,
       t3.pctReconquistado,
       t3.pctReborn,
       t3.avgFreqGrupo,
       t3.ratioFreqGrupo,
       t4.qtdeCursosCompletos,
       t4.qtdeCursosIncompletos,
       t4.carreira,
       t4.coletaDados2024,
       t4.dsDatabricks2024,
       t4.dsPontos2024,
       t4.estatistica2024,
       t4.estatistica2025,
       t4.github2024,
       t4.github2025,
       t4.iaCanal2025,
       t4.lagoMago2024,
       t4.machineLearning2025,
       t4.matchmakingTramparDeCasa2024,
       t4.ml2024,
       t4.mlflow2025,
       t4.pandas2024,
       t4.pandas2025,
       t4.python2024,
       t4.python2025,
       t4.sql2020,
       t4.sql2025,
       t4.streamlit2025,
       t4.tramparLakehouse2024,
       t4.tseAnalytics2024,
       t4.qtdDiasUltiAtividade

FROM tb_cohor AS t1

LEFT JOIN fs_transacional AS t2
ON t1.IdCliente = t2.IdCliente
AND t1.DtRef = t2.DtRef

LEFT JOIN fs_life_cycle AS t3
ON t1.IdCliente = t3.IdCliente
AND t1.DtRef = t3.DtRef

LEFT JOIN fs_education AS t4
ON t1.IdCliente = t4.IdCliente
AND t1.DtRef = t4.DtRef

WHERE t3.dtRef IS NOT NULL
;