/* Criacao da view [VW_Pagamentos_Cartao]
*/

USE [dbAtosCapital]
GO

CREATE VIEW [dbo].[VW_Pagamentos_Cartao]
AS

SELECT -- Colunas
	 [tbEmpresa].[nrCNPJ]
	,[tbPagamentoVenda].[nrNSU]
	,CONVERT(VARCHAR, [tbPagamentoVenda].[dtEmissao], 3) AS [dtVenda]
	,[tbBandeira].[idBandeira] AS [cdBandeira]
	,[tbBandeira].[dsBandeira]
	,FORMAT([tbPagamentoVenda].[vlPagamento], 'C', 'pt-br') AS [vlVenda]
	,[tbPagamentoVenda].[qtParcelas]
	,[tbPagamentoVenda].[idPagamentoVenda] AS [cdERP]

FROM [card].[tbPagamentoVenda]

LEFT JOIN [card].[tbBandeira]
ON [tbPagamentoVenda].[idBandeira] = [tbBandeira].[idBandeira]

LEFT JOIN [card].[tbEmpresa]
ON [tbPagamentoVenda].[idEmpresa] = [tbEmpresa].[idEmpresa]

LEFT JOIN [card].[tbFormaPagamento]
ON [tbPagamentoVenda].[idFormaPagamento] = [tbFormaPagamento].[idFormaPagamento]

WHERE -- Condição para apenas Cartao de Credito(3) e Debito(4)
	[tbPagamentoVenda].[idFormaPagamento] = 3 OR
	[tbPagamentoVenda].[idFormaPagamento] = 4
;