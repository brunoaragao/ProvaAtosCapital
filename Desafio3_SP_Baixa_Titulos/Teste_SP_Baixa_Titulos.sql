/* Teste da Stored Procedure [SP_Baixa_Titulos]
*/

USE [dbAtosCapital];
GO

EXEC [dbo].[SP_Baixa_Titulos] '20190917',1,2,'123456','RECEBIMENTO DE CARTÃO';

-- Impressao da [tbMovimentoBanco]
SELECT *
FROM [card].[tbMovimentoBanco]
WHERE [idEmpresa] = 1
ORDER BY [idMovimentoBanco]

-- Impressao da [tbParcela]
SELECT *
FROM [card].[tbParcela]
ORDER BY idMovimentoBanco DESC

-- Impressao do valor de movimento
SELECT
	 SUM([vlParcela]) AS [TotalValorParcelas]
	,SUM([vlTaxaAdministracao]) AS [TotalTaxasAdministracao]
	,SUM([vlParcela] - [vlTaxaAdministracao]) AS [VlMovimento]
FROM [card].[tbParcela]
WHERE [idMovimentoBanco] = 2