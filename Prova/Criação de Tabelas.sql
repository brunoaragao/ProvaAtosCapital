CREATE DATABASE dbAtosCapital;
go

use dbAtosCapital;
go

CREATE SCHEMA card;
go

CREATE TABLE card.tbEmpresa
(
idEmpresa int not null primary key identity(1,1),
nrCNPJ varchar(14) not null,
dsRazaoSocial varchar(100) not null,
dsFantasia varchar(100) not null 
)

CREATE TABLE card.tbBandeira
(
idBandeira int not null primary key identity(1,1),
dsBandeira varchar(100) not null
) 

CREATE TABLE card.tbFormaPagamento
(
idFormaPagamento int not null primary key identity(1,1),
dsFormaPagamento varchar(100)
)

CREATE TABLE card.tbPagamentoVenda
(
idPagamentoVenda int not null primary key,
idEmpresa int not null references card.tbEmpresa(idEmpresa),
nrNSU varchar(50) null,
dtEmissao date not null,
idBandeira int null references card.tbBandeira(idBandeira),
vlPagamento numeric(9,2) not null,
qtParcelas int not null,
idFormaPagamento int not null references card.tbFormaPagamento(idFormaPagamento),
)

CREATE TABLE card.tbStatusParcela
(
idStatusParcela int not null primary key identity(1,1),
dsStatusParcela varchar(50) not null
)

CREATE TABLE card.tbBanco
(
idBanco int not null primary key identity(1,1),
cdBanco VARCHAR(5) not null,
nmBanco VARCHAR(100) NOT NULL
)

CREATE TABLE card.tbContaCorrente
(
idContaCorrente int not null primary key identity(1,1),
idEmpresa int not null references card.tbEmpresa(idEmpresa),
idBanco int not null references card.tbBanco(idBanco),
dsContaCorrente varchar(50) not null,
nrAgencia varchar(50) not null,
nrConta varchar(50) not null
)

CREATE TABLE card.tbMovimentoBanco
(
idMovimentoBanco int not null primary key identity(1,1),
idEmpresa int not null references card.tbEmpresa(idEmpresa),
idContaCorrente int not null references card.tbContaCorrente(idContaCorrente),
dtMovimento date not null,
nrDocumento varchar(20) null,
dsMovimento varchar(50) not null,
vlMovimento numeric(9,2) not null,
tpOperacao char(1) not null
)

GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'E - Entrada
S - Saída' , @level0type=N'SCHEMA',@level0name=N'card', @level1type=N'TABLE',@level1name=N'tbMovimentoBanco', @level2type=N'COLUMN',@level2name=N'tpOperacao'
GO


CREATE TABLE card.tbParcela
(
idPagamentoVenda int not null references card.tbPagamentoVenda(idPagamentoVenda),
nrParcela int not null,
idEmpresa int not null references card.tbEmpresa(idEmpresa),
dtEmissao date not null,
dtVencimento date not null,
vlParcela numeric (9,2) not null,
vlTaxaAdministracao numeric(9,2) not null,
idContaCorrente int not null references card.tbContaCorrente(idContaCorrente),
dtPagamento date null,
vlPago numeric(9,2) null,
idStatusParcela int not null references card.tbStatusParcela(idStatusParcela),
idMovimentoBanco int null references card.tbMovimentoBanco(idMovimentoBanco),
)

ALTER TABLE card.tbParcela ADD CONSTRAINT PK_tbParcela primary key(idPagamentoVenda,nrParcela);