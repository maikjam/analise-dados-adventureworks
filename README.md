# analise-dados-adventureworks

Análise de crescimento de volume de compras (SQL Server)

# Análise de Performance: Crescimento de Volume de Compras (SQL Server)

## 🎯 Entendimento da Demanda
O objetivo deste projeto é identificar clientes que apresentaram expansão no volume de compras ao longo do tempo, utilizando a base de dados **AdventureWorks**.

* **Ação:** O volume de compras é definido pelo total de produtos adquiridos por mês.
* **Filtro:** Somente clientes com crescimento positivo.
* **Período de Análise:** Comparação entre a média dos primeiros 6 meses de um ano contra os 6 meses finais do período (Junho/2013 a Junho/2014), avaliando a proporção de crescimento percentual.

## 🛠️ Disposição e Estrutura dos Dados
Para garantir solidez na análise, foram utilizadas as seguintes relações:
* `Sales.SalesOrderHeader`: CustomerID e períodos de datas (OrderDate).
* `Sales.SalesOrderDetail`: OrderQty para avaliar a quantidade de produtos por ordem.
* `Sales.Customer` e `Person.Person`: Referenciamento de BusinessEntityID para identificação de nomes.

## 🚀 Destaques Técnicos do Código
O script foi construído utilizando **CTEs (Common Table Expressions)** para modularizar a lógica e otimizar o processamento:

1.  **Consolidação de Identidade (`TotalCusID`):** Agrupa nomes e IDs para evitar o uso do `DISTINCT`, reduzindo drasticamente o uso de memória e carga de processamento.
2.  **Agregação Condicional (`VolumeProduto`):** Uso de `SUM(CASE WHEN...)` como filtro de exceção para validar o volume de produtos dentro dos períodos solicitados de forma simples e eficaz.
3.  **Cálculo de Performance (`CalculoCrescimento`):** Aplicação de lógica matemática com `NULLIF` para eliminar erros de "divisão por zero", garantindo a integridade do cálculo de porcentagem de crescimento.
4.  **Flexibilidade de Filtro:** Implementação de `CASE` para distinguir automaticamente entre Pessoa Física e Jurídica (Store), facilitando futuras campanhas de marketing direcionadas.

## 💡 Observações Finais & Próximos Passos
Através desta base consolidada, é possível estabelecer novos critérios para consultas futuras, como:
* Identificar os produtos específicos que impulsionaram o crescimento desses clientes.
* Extrair dados de contato para campanhas de fidelização e novos Dashboards.

---
*Este projeto demonstra minha capacidade de entender uma demanda de negócio, mapear os dados necessários e executar uma solução SQL otimizada.*
