CREATE DATABASE exaula2
GO
USE exaula2
GO
CREATE TABLE fornecedor (
ID				INT				NOT NULL	PRIMARY KEY,
nome			VARCHAR(50)		NOT NULL,
logradouro		VARCHAR(100)	NOT NULL,
numero			INT				NOT NULL,
complemento		VARCHAR(30)		NOT NULL,
cidade			VARCHAR(70)		NOT NULL
)
GO
CREATE TABLE cliente (
cpf			CHAR(11)		NOT NULL		PRIMARY KEY,
nome		VARCHAR(50)		NOT NULL,	
telefone	VARCHAR(9)		NOT NULL,
)
GO
CREATE TABLE produto (
codigo		INT				NOT NULL	PRIMARY KEY,
descricao	VARCHAR(50)		NOT NULL,
fornecedor	INT				NOT NULL,
preco		DECIMAL(7,2)	NOT NULL
FOREIGN KEY (fornecedor) REFERENCES fornecedor(ID)
)
GO
CREATE TABLE venda (
codigo			INT				NOT NULL,
produto			INT				NOT NULL,
cliente			CHAR(11)		NOT NULL,
quantidade		INT				NOT NULL,
data			DATE			NOT NULL
PRIMARY KEY (codigo, produto, cliente, data)
FOREIGN KEY (produto) REFERENCES produto (codigo),
FOREIGN KEY (cliente) REFERENCES cliente (cpf)
)

-- Quantos produtos não foram vendidos (nome da coluna qtd_prd_nao_vend) ?

select p.descricao
from produto p left outer join venda v
on p.codigo = v.produto
where v.produto is null


--Descrição do produto, Nome do fornecedor, count() do produto nas vendas
select p.descricao, f.nome, sum(v.quantidade) as qtde_vendas
from produto p, fornecedor f, venda v
where p.fornecedor = f.ID
	and v.produto = p.codigo
group by p.descricao, f.nome


--Nome do cliente e Quantos produtos cada um comprou ordenado pela quantidade
select c.nome, count(v.cliente) as qtde_comprada
from cliente c, venda v
where c.cpf = v.cliente
group by c.nome
order by qtde_comprada

--Descrição do produto e Quantidade de vendas do produto com menor valor do catálogo de produtos

select top 1 p.descricao, v.quantidade
from produto p, venda v
where p.codigo = v.produto
group by p.descricao, v.quantidade, p.preco
order by p.preco asc


--Nome do Fornecedor e Quantos produtos cada um fornece

select f.nome, count(p.fornecedor) as qtde_produto_fornecida
from fornecedor f, produto p
where f.ID = p.fornecedor
group by f.nome

--Considerando que hoje é 20/10/2019, consultar, sem repetições, 
--o código da compra, nome do cliente, telefone do cliente (Mascarado XXXX-XXXX ou XXXXX-XXXX) e quantos dias da data da compra

select distinct v.codigo, c.nome, 
case when len(c.telefone) > 8 then 
SUBSTRING(c.telefone,1,5) + '-' + SUBSTRING(c.telefone,6,9) 
else 
	SUBSTRING(c.telefone,1,4) + '-' + SUBSTRING(c.telefone,5,8)
end as telefone,
DATEDIFF(DAY, v.data, GETDATE()) as tempo_da_compra
from venda v, cliente c
where v.cliente = c.cpf




--CPF do cliente, mascarado (XXX.XXX.XXX-XX), Nome do cliente e quantidade comprada dos clientes que compraram mais de 2 produtos

select SUBSTRING(c.cpf, 1,3)+'-'+ SUBSTRING(c.cpf, 4,3)+'-'+SUBSTRING(c.cpf, 7,3)+'-'+SUBSTRING(c.cpf, 10,2) as cpf,
c.nome, count(v.quantidade) as qtde_de_produtos
from cliente c, venda v 
where c.cpf = v.cliente
group by c.cpf, c.nome, v.quantidade
having  count(v.produto) > 2



-- Sem repetições, Código da venda, CPF do cliente, mascarado (XXX.XXX.XXX-XX), 
--Nome do Cliente e Soma do valor_total gasto(valor_total_gasto = preco do produto * quantidade de venda).Ordenar por nome do cliente

select distinct v.codigo, c.cpf, c.nome, sum(v.quantidade*p.preco) as valor_total_gasto
from venda v, cliente c, produto p
where v.cliente = c.cpf
	and v.produto = p.codigo
group by v.codigo, c.cpf, c.nome
order by c.nome


--Código da venda, data da venda em formato (DD/MM/AAAA) e uma coluna, chamada dia_semana, que escreva o dia da semana por extenso
 
 select v.codigo, CONVERT(char(10), v.data,103) as data_da_venda,
 case when day (getdate()) = 0 then
	'Segunda-feira'
else 
	case when day (getdate()) = 1 then
		'Terça-feira'	
	else
		case when day (getdate()) = 2 then
			'Quarta-feira'
		else 
			case when day (getdate()) = 3 then
				'Quinta-feira'
			else 
				case when day (getdate()) = 4 then
					'Sexta-feira'
					else 
						case when day (getdate()) = 5 then
							'Sabado'
						else 
							case when day (getdate()) = 6 then
								'Domingo'
						end
					end
				end
			end
		end
	end 
end as dia_da_semana
 from venda v
