/* Teste da Stored Procedure [SP_Corrige_Parcelas]
*/

USE [dbAtosCapital]
GO

EXEC [dbo].[SP_Corrige_Parcelas] 61476419 ,2 ,2.00

SELECT
	*
FROM
	[card].[tbPagamentoVenda]
WHERE
	[idPagamentoVenda] = 61476419

SELECT
	*
FROM
	[card].[tbParcela]
WHERE
	[idPagamentoVenda] = 61476419