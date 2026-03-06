SELECT idCliente,
        count(DISTINCT substr(DtCriacao,0,11)) AS qtdeFrequencia,
        sum(CASE WHEN QtdePontos > 0 THEN QtdePontos ELSE 0 END) AS qtdePontosPos,
        sum(abs(qtdePontos)) AS qtdePontosAbs
 FROM transacoes
WHERE DtCriacao < '2025-09-01'
AND DtCriacao >= date('2025-09-01','-28 day')
GROUP BY idCliente
ORDER BY qtdeFrequencia


