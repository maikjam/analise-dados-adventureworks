/*
Quais clientes aumentaram o volume de compras ao longo do tempo?

OBJETIVO: Identificar clientes com crescimento no volume de compras entre dois períodos.
MÉTRICA: Soma de 'OrderQty' comparando o 2º semestre de 2013 com o 1º semestre de 2014.
BASE DE DADOS: AdventureWorks (Sales.Customer, Sales.SalesOrderHeader, Sales.SalesOrderDetail, Person.Person).
*/

/*OBSERVÇÕES FINAIS 
Atráves de ssa base de dados é possivel estabelecer novo criterios para consultas futuras como 
indentificar os produtos que esse clientes obtiveram, consultar dados de contato, para campanhas futuras 
*/


-- 1. Consolidação de Identidade do Cliente
-- Agrupa informações de Pessoa Física e Jurídica para evitar duplicidade de IDs na análise.
-- Elimina o DISTINCT dinimuido a carga sobre o processamento de dados 

WITH TotalCusID AS (
	SELECT 
		cus.CustomerID,
		cus.StoreID,
		cus.PersonID,
		per.FirstName,
		per.LastName
	FROM 
		Sales.Customer as cus
	LEFT JOIN 
		Person.Person AS per
	ON 
		cus.PersonID = per.BusinessEntityID
	GROUP BY 
		cus.CustomerID,
		cus.StoreID,
		cus.PersonID,
		per.FirstName,
		per.LastName
	),

-- 2. Cálculo do Volume por Período
-- Agrega a quantidade total de itens (OrderQty) comprados em dois semestres consecutivos.
-- Período A: 30/06/2013 a 30/12/2013 | Período B: 30/12/2013 a 30/06/2014.
-- Case como filtro de exeção validando de forma simples ID clientr dentro do periodo solicitado

VolumeProduto AS (
	SELECT
		soh.CustomerID,
	SUM(CASE
		WHEN  soh.OrderDate BETWEEN '20130630' AND '20131230' THEN sod.OrderQTY
		ELSE 0
		END) AS [Total Primeiro Periodo],
	SUM(CASE
		WHEN  soh.OrderDate BETWEEN '20131230' AND '20140630' THEN sod.OrderQTY
		ELSE 0
		END) AS [Total Segundo Periodo]
		
	FROM 
		Sales.SalesOrderDetail AS  sod
	INNER JOIN 
		Sales.SalesOrderHeader AS soh
	ON
		sod.SalesOrderID = soh.SalesOrderID
	GROUP BY 
		soh.CustomerID
),

-- 3. Cálculo de Performance (Variação Percentual)
-- Calcula o delta percentual entre os períodos. 
-- O uso de NULLIF previne o erro de divisão por zero para novos clientes.
-- Caáculo que avalia o aumento de copmpra de produto por cliente usando NULLIF para eliminar divizão por 0

CalculoCrescimento AS (
	SELECT 
		vop.CustomerID,
		(
		(vop.[Total Segundo Periodo] - vop.[Total Primeiro Periodo]) * 100.0
		/ NULLIF(vop.[Total Primeiro Periodo], 0)
		) AS 
			[Percentual Crescimento]
		
	FROM 
		VolumeProduto AS vop
)

-- 4. Consulta Final e Classificação
-- Retorna a lista de clientes com crescimento positivo, formatando nomes e tipos de conta.
 -- Ordena pelos que mais cresceram

 SELECT 
	vop.CustomerID [ID Ciente],
	(tci.FirstName + ' ' + tci.LastName) AS [Nome Cliente],
	sto.Name AS 
		[Nome Loja],
	CASE
		WHEN 
			tci.StoreID IS NOT NULL THEN 'Pessoa Juridica'
		WHEN 
			tci.PersonID IS NOT NULL THEN 'Pessoa Fisica'
		ELSE 
			'Indefinido'
	END AS 
		[Tipo Cliente],
		vop.[Total Primeiro Periodo],
		vop.[Total Segundo Periodo],
		ccr.[Percentual Crescimento]

FROM 
	TotalCusID AS tci

LEFT JOIN 
	Sales.Store AS  sto
ON
	tci.StoreID = sto.BusinessEntityID
LEFT JOIN 
	VolumeProduto AS vop
ON 
	tci.CustomerID = vop.CustomerID
LEFT JOIN 
	CalculoCrescimento AS ccr
ON
	tci.CustomerID = ccr.CustomerID
WHERE 
	ccr.[Percentual Crescimento] > 0
ORDER BY 
    ccr.[Percentual Crescimento] DESC;
