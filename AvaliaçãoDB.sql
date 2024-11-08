CREATE DATABASE Loja_Roupas

--Classifica��o das tabelas

--tabela vendas
CREATE TABLE Marcas (
ID_Marcas INT PRIMARY KEY,
Nome_dMarca VARCHAR(50)
)

--tabela das roupas
CREATE TABLE Estilo_dRoupa (
ID_Estilo INT PRIMARY KEY,
Tamanho VARCHAR(2),
Cor VARCHAR(20),
Genero_Roupa VARCHAR,
Tipo_dRoupa VARCHAR(50),

ID_Marcas INT FOREIGN KEY(ID_Marcas) --CHAVE ESTRANGEIRA DA TABELA MARCAS
REFERENCES Marcas(ID_Marcas)
)

--tabela das vendas
CREATE TABLE Vendas (
ID_Venda INT PRIMARY KEY,
Pre�o_dVenda FLOAT,
DATA_dVenda DATETIME,

ID_Estilo INT FOREIGN KEY(ID_Estilo) --CHAVE ESTRANGEIRA DA TABELA ESTILO DE ROUPA
REFERENCES Estilo_dRoupa(ID_Estilo),

ID_Cliente INT FOREIGN KEY(ID_Cliente) -- CHAVE ESTRANGEIRA DA TABELA CLIENTE
REFERENCES CLIENTE(ID_Cliente)
)

--tabela clientes
CREATE TABLE CLIENTE (
ID_Cliente INT PRIMARY KEY,
Nome_Cliente VARCHAR(50),
Telefone VARCHAR(11),
Genero VARCHAR(1)
)

--Inser��o de dados

--CLIENTE
INSERT INTO CLIENTE(ID_Cliente, Nome_Cliente, Telefone, Genero) 
VALUES
(1, 'Geraldo', '123456789', 'M'),
(2, 'Rodrigo', '234567890', 'M'),
(3, 'Roberta', '345678901', 'F'),
(4, 'Thais', '456789012', 'F')

--MARCAS
INSERT INTO Marcas(ID_Marcas, Nome_dMarca)
VALUES
(1, 'Nike'),
(2, 'Puma'),
(3, 'Adidas'),
(4, 'Hering')

--ESTILO DE ROUPA
INSERT INTO Estilo_dRoupa(ID_Estilo ,Tamanho ,Cor ,Genero_Roupa ,Tipo_dRoupa, ID_Marcas )
VALUES
(1, 'P', 'Vermelho', 'M', 'Blusa' ,1 ),
(2, 'M', 'Preto', 'F', 'Cal�a Legging',2 ),
(3, 'G', 'Branco', 'M', 'Camiseta',3 ),
(4, 'GG', 'Preto', 'M', 'Camiseta', 2),
(5, 'P', 'Azul', 'F', 'Cal�a Jeans',4 ),
(6, 'PP', 'Laranja', 'F', 'Blusa', 2)

--VENDAS
INSERT INTO  Vendas (ID_Venda,Pre�o_dVenda, DATA_dVenda, ID_Cliente,ID_Estilo )
VALUES
(1, 2000,2017-10-12 ,1, 1 ),
(2, 2600,2018-10-01 ,2, 2),
(3, 2300,2018-01-12 ,3, 3),
(4, 3000,2018-01-15 ,4, 4)

select * from Vendas
select * from CLIENTE
select * from Estilo_dRoupa
select * from Marcas

--VIEW DA LOJA: verifica o total gasto de acordo com o id do cliente

CREATE VIEW vw_compras01 AS
SELECT 
	Nome_Cliente,
	Genero,
	Vendas.ID_Cliente,
	Vendas.Pre�o_dVenda as 'Total gasto'
FROM CLIENTE
full JOIN Vendas ON CLIENTE.ID_Cliente = Vendas.ID_Cliente;

SELECT * FROM vw_compras01

--SUBQUERIE DA LOJA : verifica quais s�o os ids das marcas que  existem no estilo de roupa

SELECT 
ID_Marcas
FROM Marcas
WHERE EXISTS (
    SELECT 1
    FROM Estilo_dRoupa
    WHERE Estilo_dRoupa.ID_Marcas = Marcas.ID_Marcas
);

--CTE DA LOJA: verifica quais clientes fizeram vendas, retorna o g�nero, nome e id de tais clientes.

WITH ClientesEVendas AS (
SELECT 
	Nome_Cliente,
	Genero,
	Vendas.ID_Cliente
FROM CLIENTE
full JOIN Vendas ON CLIENTE.ID_Cliente = Vendas.ID_Cliente
)
SELECT 
	Nome_Cliente,
	Genero,
	ID_Cliente
FROM 
	ClientesEVendas

--WINDOW FUNCTIONS: agrupa as vendas em dois grupos de acordo com o seu valor(em ordem crescente)

SELECT
ID_Venda,
Pre�o_dVenda,
NTILE(2) OVER (ORDER BY Pre�o_dVenda) AS 'Grupos de Vendas'
FROM Vendas

--FUNCTIONS: Verifica os ids e nomes das marcas que estejam na tabela estilo de roupa

CREATE FUNCTION MarcasPorID (@MarcasID INT)
RETURNS TABLE
AS
RETURN (
    SELECT m.ID_Marcas, m.Nome_dMarca
    FROM Marcas m
    full JOIN Estilo_dRoupa ed ON m.ID_Marcas = ed.ID_Marcas
    WHERE ed.ID_Marcas = @MarcasID
);

SELECT *
FROM dbo.MarcasPorID(2)
   
--PROCEDURES: adiciona dados na tabela vendas

CREATE PROCEDURE SP_ADD_VENDAS
    @ID_VENDA INT,
    @DATA_dVenda DATETIME,
    @Pre�o_dVenda FLOAT,
    @ID_Estilo INT,
	@ID_Cliente INT
AS
    INSERT INTO Vendas(ID_Venda, DATA_dVenda, Pre�o_dVenda, ID_Estilo, ID_Cliente)
    VALUES (@ID_VENDA, @DATA_dVenda, @Pre�o_dVenda, @ID_Estilo, @ID_Cliente);
GO

EXEC SP_ADD_VENDAS
   @ID_VENDA = 5,
   @DATA_dVenda = '2018-10-12',
   @Pre�o_dVenda = '2100',
   @ID_Estilo = 5,
   @ID_Cliente = 5

   SELECT * FROM Vendas

 --TRIGGERS: Ao inv�s de deletar um cliente � acionado um gatilho avisando que tal cliente n�o pode ser deletado

 CREATE OR ALTER TRIGGER Deletar_CLIENTE
ON CLIENTE
INSTEAD OF DELETE
AS
BEGIN
	PRINT 'Esse CLIENTE n�o pode ser deletado'
END
GO

DELETE FROM CLIENTE
WHERE ID_Cliente = 3

