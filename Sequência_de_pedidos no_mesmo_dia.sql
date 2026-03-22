/*
Sequência de pedidos no mesmo dia

OBJETIVO: Identificar comportamentos atípicos de compra, detectando clientes 
com alto volume de pedidos (3 ou mais) realizados em um único dia.

MÉTRICA: Contagem de 'SalesOrderID' agrupada por 'CustomerID' e 'OrderDate'.
BASE DE DADOS: AdventureWorks (Sales.SalesOrderHeader).
RANKING: Utilização de RANK() para classificar os maiores volumes diários, 
permitindo empates técnicos.
*/

/* OBSERVÇÕES FINAIS 
Este monitoramento permite identificar densidade de pedidos diario por cliente,
avaliando perfil de compra B2B (Revendedores) dentro da base. 

*/

WITH RankTotalCompras AS (
SELECT 
	soh.CustomerID,
	COUNT(soh.SalesOrderID) AS TotalCompras, -- Conta a densidade de pedidos por dia 
	MAX(soh.OrderDate) AS DataEvento,		-- Identifica o dia específico da ocorrência

-- RANKING: Classifica quem teve o maior volume de compras diárias.
-- O RANK pula posições se houver empates, refletindo a densidade real.
RANK() OVER (
	ORDER BY 
	COUNT(soh.SalesOrderID) DESC)
	AS PosicaoRanking -- filtra o rank por data 

FROM Sales.SalesOrderHeader AS soh
GROUP BY soh.CustomerID, soh.OrderDate	-- Agrupar por Cliente e Data para isolar o comportamento diário
HAVING Count(soh.SalesOrderID) >= 3		-- Filtro de Negócio: Apenas casos com 3 ou mais pedidos no mesmo dia
)

SELECT
	rtc.CustomerID,
    rtc.TotalCompras,
    rtc.DataEvento,
    rtc.PosicaoRanking
FROM RankTotalCompras AS rtc

WHERE PosicaoRanking <= 3 -- Filtramos os Top 3 níveis de ranking (incluindo empates)
ORDER BY PosicaoRanking 



