/* Criacao da Stored Procedure [SP_Corrige_Parcelas]
*/

USE [dbAtosCapital]
GO

CREATE PROCEDURE [dbo].[SP_Corrige_Parcelas]
	 @idPagamentoVenda int
	,@qtParcelas int
	,@prTaxaAdministracao numeric(9,2)
AS

BEGIN
	--Valida se o pagamento venda existe
	DECLARE @PagamentoVendaCount INT;
	SELECT @PagamentoVendaCount = COUNT(*)
	FROM [card].[tbPagamentoVenda]
	WHERE [idPagamentoVenda] = @idPagamentoVenda

	DECLARE @IdExiste BIT = IIF(@PagamentoVendaCount != 0, 'true', 'false')

	IF(@IdExiste = 'true')
		BEGIN
		-- Recupera o id do status de parcela 'Aberta' com base na tabela [tbStatusParcela]
		DECLARE @IdParcelaAberta INT
		SELECT @IdParcelaAberta = [idStatusParcela]
		FROM [card].[tbStatusParcela]
		WHERE [dsStatusParcela] = 'Aberta'

		-- Verifica se todas as parcelas estão com o status de aberta
		DECLARE @TodasParcelasAbertas BIT = 'true'
		SELECT @TodasParcelasAbertas = IIF([idStatusParcela] != @IdParcelaAberta, 'false', 'true')
		FROM [card].[tbParcela]
		WHERE
			[idPagamentoVenda] = @idPagamentoVenda AND -- Apenas parcelas referentes ao pagamento venda
			@TodasParcelasAbertas = 'true' -- Caso uma parcela não esteja aberta, saia do looping 

		-- Na condicao de todas as parcelas abertas
		IF(@TodasParcelasAbertas = 'true')
		BEGIN
			-- Declaração de dados das parecelas
			DECLARE
				 --@IdPagamentoVenda INT
				 @NrParcela INT
				,@IdEmpresa INT
				,@DtEmissao DATE
				,@DtVencimento DATE
				,@VlParcela NUMERIC(9,2)
				,@VlTaxaAdministracao NUMERIC(9,2)
				,@IdContaCorrente INT
				,@DtPagamento DATE = NULL
				,@vlPago DECIMAL = NULL
				,@IdStatusParcela INT = @IdParcelaAberta
				,@IdMovimentoBanco INT

			-- Dados reaproveitados das parcelas anteriores
			SELECT
				 @IdEmpresa = [idEmpresa] 
				,@DtEmissao = [dtEmissao]
				,@IdContaCorrente = [idContaCorrente]
				,@IdMovimentoBanco = [idMovimentoBanco]
			FROM [card].[tbParcela]
			WHERE [idPagamentoVenda] = @idPagamentoVenda

			-- Remove as parcelas antigas
			DELETE FROM [card].[tbParcela]
			WHERE [idPagamentoVenda] = @idPagamentoVenda

			-- Dados exclusivos das novas parcelas
			SELECT
				 @VlParcela = ([vlPagamento] / @qtParcelas)
				,@VlTaxaAdministracao = @VlParcela * (@prTaxaAdministracao/100)
			FROM [card].[tbPagamentoVenda]
			WHERE [idPagamentoVenda] = @idPagamentoVenda

			-- Update na tabela card.tbPagamentoVenda
			UPDATE [card].[tbPagamentoVenda]
			SET [qtParcelas] = @qtParcelas
			WHERE [idPagamentoVenda] = @idPagamentoVenda

			DECLARE @index INT = 1
			WHILE (@index <= @qtParcelas) -- Looping para inserir novas parcelas
			BEGIN
				-- Dados individuais da parcela
				SET @NrParcela = @index
				SET @DtVencimento = DATEADD(DAY, @index * 30, @dtEmissao)

				-- Insercao da parcela no banco de dados
				INSERT INTO [card].[tbParcela](
					 idPagamentoVenda
					,nrParcela
					,idEmpresa
					,dtEmissao
					,dtVencimento
					,vlParcela
					,vlTaxaAdministracao
					,idContaCorrente
					,dtPagamento
					,vlPago
					,idStatusParcela
					,idMovimentoBanco
				)
				VALUES(
					 @idPagamentoVenda
					,@NrParcela
					,@IdEmpresa
					,@DtEmissao
					,@DtVencimento
					,@VlParcela
					,@VlTaxaAdministracao
					,@IdContaCorrente
					,@DtPagamento
					,@VlPago
					,@IdStatusParcela
					,@IdMovimentoBanco
				)
			
				SET @index = @index + 1; -- Proximo looping
			END -- Fim do Looping -- WHILE (@index <= @qtParcelas)

		END -- Fim da Condicao -- IF(@TodasParcelasAbertas = 'true')

	END -- Fim da Condicao -- IF(@IdExiste = 'true')

END -- Fim do Stored Procedure












