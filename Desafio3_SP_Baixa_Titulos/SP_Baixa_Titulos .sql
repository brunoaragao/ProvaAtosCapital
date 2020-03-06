/* Criacao da Stored Procedure [SP_Baixa_Titulos]
*/

USE [dbAtosCapital]
GO

CREATE PROCEDURE [dbo].[SP_Baixa_Titulos]
	 @dtPagamento DATE
	,@idEmpresa INT
	,@idContaCorrente INT
	,@nrDocumento VARCHAR(20)
	,@dsMovimento VARCHAR(50)
AS
BEGIN
	-- Recupera o id dos status de parcela 'Aberta' e 'Liquidada' com base na tabela [tbStatusParcela]
	DECLARE
		 @IdParcelaAberta INT
		,@IdParcelaLiquidada INT
	Select
		 @IdParcelaAberta = IIF([dsStatusParcela] = 'Aberta', [idStatusParcela], @IdParcelaAberta)
		,@IdParcelaLiquidada = IIF([dsStatusParcela] = 'Liquidada', [idStatusParcela], @IdParcelaLiquidada)
	FROM [card].[tbStatusParcela]

	-- Definindo o valor total do movimento
	DECLARE @VlMovimento NUMERIC(9,2)
	SELECT
		@VlMovimento = SUM([vlParcela] - [vlTaxaAdministracao])
	FROM
		[card].[tbParcela]
	WHERE
		[dtVencimento] = @dtPagamento AND -- que vencem na data do pagamento
		[idEmpresa] = @idEmpresa AND -- que pertencem a empresa
		[idContaCorrente] = @idContaCorrente AND -- que correspondem a conta corrente
		[idStatusParcela] = @IdParcelaAberta -- parcelas abertas
		
	-- Verifica se ha algum valor de movimento
	IF(@VlMovimento IS NOT NULL)
	BEGIN
		-- Inserir na tabela [tbMovimentoBanco]
		INSERT INTO [card].[tbMovimentoBanco](
			 [idEmpresa]
			,[idContaCorrente]
			,[nrDocumento]
			,[dsMovimento]
			,[vlMovimento]
			,[tpOperacao]
			,[dtMovimento]
		)
		VALUES(
			 @idEmpresa
			,@idContaCorrente
			,@nrDocumento
			,@dsMovimento
			,@VlMovimento
			,'E'
			,@dtPagamento
		)

		-- Recupera o idMovimentoBanco
		DECLARE @IdMovimentoBanco INT = SCOPE_IDENTITY();

		-- Atualiza as colunas da tabela [tbParcela]
		UPDATE [card].[tbParcela] SET
			[dtPagamento] = @dtPagamento,
			[vlPago] = ([vlParcela] - [vlTaxaAdministracao]),
			[idStatusParcela] = @idParcelaLiquidada,
			[idMovimentoBanco] = @idMovimentoBanco
		WHERE
			[dtVencimento] = @dtPagamento AND -- que vencem na data do pagamento
			[idEmpresa] = @idEmpresa AND -- que pertencem a empresa
			[idContaCorrente] = @idContaCorrente AND -- que correspondem a conta corrente
			[idStatusParcela] = @IdParcelaAberta -- parcelas abertas
	END -- Fim da Condicao -- IF(@VlMovimento IS NOT NULL)
END -- Fim da Stored Procedure
