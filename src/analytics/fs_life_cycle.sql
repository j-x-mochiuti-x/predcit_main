WITH tb_life_cycle_atual AS (
    SELECT IdCliente, life_cicle
    FROM life_cycle

    WHERE DtRef = date('2024-03-01', '-1 day')
)

tb_life_cycle_D28 AS (
    SELECT IdCliente,
            life_cicle
    FROM life_cycle
    WHERE dtRef = date('2024-03-01', '-29 day')
)