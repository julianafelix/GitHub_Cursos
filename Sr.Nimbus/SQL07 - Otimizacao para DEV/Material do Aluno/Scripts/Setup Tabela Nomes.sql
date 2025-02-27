/*
	Cria as tabelas FirstName e LastName que ser�o utilizadas na primeira demo
	
	Autor: Luciano Caixeta Moreira
*/

USE TempDB
GO

IF EXISTS (SELECT [Name] FROM sys.objects WHERE TYPE = 'U' AND [Name] = 'FirstName')
	DROP TABLE FirstName
go

CREATE TABLE FirstName
(FName VARCHAR(255) NOT NULL)
go

IF EXISTS (SELECT [Name] FROM sys.objects WHERE TYPE = 'U' AND [Name] = 'LastName')
	DROP TABLE LastName
go

CREATE TABLE LastName
(LName VARCHAR(255) NOT NULL)
go

INSERT INTO FirstName VALUES ('Luciano')
INSERT INTO FirstName VALUES ('Patricia')
INSERT INTO FirstName VALUES ('Guilherme')
INSERT INTO FirstName VALUES ('Simone')
INSERT INTO FirstName VALUES ('Leandro')
INSERT INTO FirstName VALUES ('Fernanda')
INSERT INTO FirstName VALUES ('Nelson')
INSERT INTO FirstName VALUES ('Rita')
INSERT INTO FirstName VALUES ('Daniel')
INSERT INTO FirstName VALUES ('Carolina')
INSERT INTO FirstName VALUES ('Marcos')
INSERT INTO FirstName VALUES ('Tais')
INSERT INTO FirstName VALUES ('Bruno')
INSERT INTO FirstName VALUES ('Larissa')
INSERT INTO FirstName VALUES ('Andre')
INSERT INTO FirstName VALUES ('Lilian')
INSERT INTO FirstName VALUES ('Alexandre')
INSERT INTO FirstName VALUES ('Jussara')
INSERT INTO FirstName VALUES ('Rener')
INSERT INTO FirstName VALUES ('Renata')
INSERT INTO FirstName VALUES ('Mariana')
INSERT INTO FirstName VALUES ('Juliana')
INSERT INTO FirstName VALUES ('Fernando')
INSERT INTO FirstName VALUES ('Gabriel')
INSERT INTO FirstName VALUES ('Marco Antonio')
INSERT INTO FirstName VALUES ('Rosalia')
INSERT INTO FirstName VALUES ('Marisa')
INSERT INTO FirstName VALUES ('Maria Lina')
INSERT INTO FirstName VALUES ('Marilia')
INSERT INTO FirstName VALUES ('Gloria')
INSERT INTO FirstName VALUES ('Paulo')
INSERT INTO FirstName VALUES ('Luis')
INSERT INTO FirstName VALUES ('Emerson')
INSERT INTO FirstName VALUES ('Marcelo')
INSERT INTO FirstName VALUES ('Silvio')
INSERT INTO FirstName VALUES ('Wellington')
INSERT INTO FirstName VALUES ('Fabricio')
INSERT INTO FirstName VALUES ('Daniela')
INSERT INTO FirstName VALUES ('Jos� Ricardo')
INSERT INTO FirstName VALUES ('Antonio')
INSERT INTO FirstName VALUES ('Jo�o Paulo')
INSERT INTO FirstName VALUES ('Sarah')
INSERT INTO FirstName VALUES ('Julia')
INSERT INTO FirstName VALUES ('Luiza')
INSERT INTO FirstName VALUES ('M�rcia')
INSERT INTO FirstName VALUES ('Camila')
INSERT INTO FirstName VALUES ('Beatriz')
INSERT INTO FirstName VALUES ('Elis')
INSERT INTO FirstName VALUES ('Ana')
INSERT INTO FirstName VALUES ('Luciana')
INSERT INTO FirstName VALUES ('Mauricio')
INSERT INTO FirstName VALUES ('Kenia')
INSERT INTO FirstName VALUES ('Goreti')
INSERT INTO FirstName VALUES ('Barbara')
INSERT INTO FirstName VALUES ('Amanda')
INSERT INTO FirstName VALUES ('Ana Claudia')
INSERT INTO FirstName VALUES ('Anderson')
INSERT INTO FirstName VALUES ('Alvaro')
INSERT INTO FirstName VALUES ('Alessandro')
INSERT INTO FirstName VALUES ('Alex')
INSERT INTO FirstName VALUES ('Adriana')
INSERT INTO FirstName VALUES ('Alice')
INSERT INTO FirstName VALUES ('Alicia')
INSERT INTO FirstName VALUES ('Bruna')
INSERT INTO FirstName VALUES ('Boris')
INSERT INTO FirstName VALUES ('Bianca')
INSERT INTO FirstName VALUES ('Cesar')
INSERT INTO FirstName VALUES ('Carlos')
INSERT INTO FirstName VALUES ('Carla')
INSERT INTO FirstName VALUES ('Carmen')
INSERT INTO FirstName VALUES ('Diego')
INSERT INTO FirstName VALUES ('Diana')
INSERT INTO FirstName VALUES ('David')
INSERT INTO FirstName VALUES ('Douglas')
INSERT INTO FirstName VALUES ('Dilbert')
INSERT INTO FirstName VALUES ('Denise')
INSERT INTO FirstName VALUES ('Elaine')
INSERT INTO FirstName VALUES ('Eliane')
INSERT INTO FirstName VALUES ('Elias')
INSERT INTO FirstName VALUES ('Elder')
INSERT INTO FirstName VALUES ('Elber')
INSERT INTO FirstName VALUES ('Erasto')
INSERT INTO FirstName VALUES ('Erminio')
INSERT INTO FirstName VALUES ('Eduardo')
INSERT INTO FirstName VALUES ('Eduarda')
INSERT INTO FirstName VALUES ('Eulalia')
INSERT INTO FirstName VALUES ('Euclides')
INSERT INTO FirstName VALUES ('Fabiana')
INSERT INTO FirstName VALUES ('Fabio')
INSERT INTO FirstName VALUES ('Firmino')
INSERT INTO FirstName VALUES ('Felipe')
INSERT INTO FirstName VALUES ('Gustavo')
INSERT INTO FirstName VALUES ('Geraldo')
INSERT INTO FirstName VALUES ('Gilberto')
INSERT INTO FirstName VALUES ('Helen')
INSERT INTO FirstName VALUES ('Ieda')
INSERT INTO FirstName VALUES ('Iris')
INSERT INTO FirstName VALUES ('Igor')
INSERT INTO FirstName VALUES ('Jos�')
INSERT INTO FirstName VALUES ('Juca')
INSERT INTO FirstName VALUES ('Joilson')
INSERT INTO FirstName VALUES ('Janaina')
INSERT INTO FirstName VALUES ('Joana')
INSERT INTO FirstName VALUES ('Katia')
INSERT INTO FirstName VALUES ('Karina')
INSERT INTO FirstName VALUES ('Lucas')
INSERT INTO FirstName VALUES ('Liana')
INSERT INTO FirstName VALUES ('Luanna')
INSERT INTO FirstName VALUES ('Lais')
INSERT INTO FirstName VALUES ('Lourival')
INSERT INTO FirstName VALUES ('Milene')
INSERT INTO FirstName VALUES ('Monica')
INSERT INTO FirstName VALUES ('Noel')
INSERT INTO FirstName VALUES ('Nubia')
INSERT INTO FirstName VALUES ('Nereu')
INSERT INTO FirstName VALUES ('Orlando')
INSERT INTO FirstName VALUES ('Paula')
INSERT INTO FirstName VALUES ('Pedro')
INSERT INTO FirstName VALUES ('Quesia')
INSERT INTO FirstName VALUES ('Rafael')
INSERT INTO FirstName VALUES ('Renato')
INSERT INTO FirstName VALUES ('Reginaldo')
INSERT INTO FirstName VALUES ('Roberto')
INSERT INTO FirstName VALUES ('Andreia')
INSERT INTO FirstName VALUES ('Savio')
INSERT INTO FirstName VALUES ('Salvina')
INSERT INTO FirstName VALUES ('Sabrina')
INSERT INTO FirstName VALUES ('Samantha')
INSERT INTO FirstName VALUES ('Ludmila')
INSERT INTO FirstName VALUES ('Kadija')
INSERT INTO FirstName VALUES ('Saulo')
INSERT INTO FirstName VALUES ('Serafim')
INSERT INTO FirstName VALUES ('Silas')
INSERT INTO FirstName VALUES ('Cinthia')
INSERT INTO FirstName VALUES ('Sorato')
INSERT INTO FirstName VALUES ('Soraia')
INSERT INTO FirstName VALUES ('Tatiana')
INSERT INTO FirstName VALUES ('Telmo')
INSERT INTO FirstName VALUES ('Talita')
INSERT INTO FirstName VALUES ('Norton')
INSERT INTO FirstName VALUES ('Tie')
INSERT INTO FirstName VALUES ('Jessica')
INSERT INTO FirstName VALUES ('Vitor')
INSERT INTO FirstName VALUES ('Vanessa')
INSERT INTO FirstName VALUES ('Vladmir')
INSERT INTO FirstName VALUES ('Samir')
INSERT INTO FirstName VALUES ('Sandra')
INSERT INTO FirstName VALUES ('Fabiola')
INSERT INTO FirstName VALUES ('Flavia')
INSERT INTO FirstName VALUES ('Franco')
INSERT INTO FirstName VALUES ('Francielder')
INSERT INTO FirstName VALUES ('Aparecida')
INSERT INTO FirstName VALUES ('Wesley')
INSERT INTO FirstName VALUES ('Umberto')
INSERT INTO FirstName VALUES ('Camille')
INSERT INTO FirstName VALUES ('Claudia')
INSERT INTO FirstName VALUES ('Cristiane')
INSERT INTO FirstName VALUES ('Penelope')
INSERT INTO FirstName VALUES ('Caterine')
INSERT INTO FirstName VALUES ('Tulio')
INSERT INTO FirstName VALUES ('Gilmar')
INSERT INTO FirstName VALUES ('Eloi')
INSERT INTO FirstName VALUES ('Helio')
INSERT INTO FirstName VALUES ('Walter')
INSERT INTO FirstName VALUES ('Prista')
INSERT INTO FirstName VALUES ('Regis')
INSERT INTO FirstName VALUES ('Edward')
INSERT INTO FirstName VALUES ('Michele')
INSERT INTO FirstName VALUES ('Rosana')
INSERT INTO FirstName VALUES ('Ricardo')
INSERT INTO FirstName VALUES ('Denis')
INSERT INTO FirstName VALUES ('Vinicius')
INSERT INTO FirstName VALUES ('Valeria')
INSERT INTO FirstName VALUES ('Ana Paula')
INSERT INTO FirstName VALUES ('Aline')
INSERT INTO FirstName VALUES ('Analy')
INSERT INTO FirstName VALUES ('Fani')
INSERT INTO FirstName VALUES ('Mauro')
INSERT INTO FirstName VALUES ('Marta')
INSERT INTO FirstName VALUES ('Melissa')
INSERT INTO FirstName VALUES ('William')
INSERT INTO FirstName VALUES ('Wilson')
INSERT INTO FirstName VALUES ('Alan')
INSERT INTO FirstName VALUES ('Afonso')
INSERT INTO FirstName VALUES ('Alonso')
INSERT INTO FirstName VALUES ('Agnes')
INSERT INTO FirstName VALUES ('Tom')
INSERT INTO FirstName VALUES ('Thomas')
INSERT INTO FirstName VALUES ('Matheus')
INSERT INTO FirstName VALUES ('Miriam')
INSERT INTO FirstName VALUES ('Daisy')
INSERT INTO FirstName VALUES ('Dalila')
INSERT INTO FirstName VALUES ('Sansao')
INSERT INTO FirstName VALUES ('Thor')
INSERT INTO FirstName VALUES ('Adao')
INSERT INTO FirstName VALUES ('Zeus')
INSERT INTO FirstName VALUES ('Minerva')
INSERT INTO FirstName VALUES ('Afrodite')
INSERT INTO FirstName VALUES ('Erodes')
INSERT INTO FirstName VALUES ('Apolo')
INSERT INTO FirstName VALUES ('Anisio')
INSERT INTO FirstName VALUES ('Anastacia')
INSERT INTO FirstName VALUES ('Anita')
INSERT INTO FirstName VALUES ('Acacio')
INSERT INTO FirstName VALUES ('Adalto')
INSERT INTO FirstName VALUES ('Aecio')
INSERT INTO FirstName VALUES ('Airton')
INSERT INTO FirstName VALUES ('Ailson')
INSERT INTO FirstName VALUES ('Arlin')
INSERT INTO FirstName VALUES ('Alanis')
INSERT INTO FirstName VALUES ('Atila')
INSERT INTO FirstName VALUES ('Abadia')
INSERT INTO FirstName VALUES ('Aaron')
INSERT INTO FirstName VALUES ('Tess')
INSERT INTO FirstName VALUES ('Davi')
INSERT INTO FirstName VALUES ('Golias')
INSERT INTO FirstName VALUES ('Moises')
INSERT INTO FirstName VALUES ('Maome')
INSERT INTO FirstName VALUES ('Harry')
INSERT INTO FirstName VALUES ('Hermione')
INSERT INTO FirstName VALUES ('Snape')
INSERT INTO FirstName VALUES ('Dumbledore')
INSERT INTO FirstName VALUES ('Grazielle')
INSERT INTO FirstName VALUES ('Rony')
INSERT INTO FirstName VALUES ('Simas')
INSERT INTO FirstName VALUES ('Voldemort')
INSERT INTO FirstName VALUES ('Peter')
INSERT INTO FirstName VALUES ('Clark')
INSERT INTO FirstName VALUES ('Frodo')
INSERT INTO FirstName VALUES ('Sam')
INSERT INTO FirstName VALUES ('Hiro')
INSERT INTO FirstName VALUES ('Claire')
INSERT INTO FirstName VALUES ('Nathan')
INSERT INTO FirstName VALUES ('Natalia')
INSERT INTO FirstName VALUES ('Nataly')
INSERT INTO FirstName VALUES ('Tuco')
INSERT INTO FirstName VALUES ('Taisa')
INSERT INTO FirstName VALUES ('Tereza')
INSERT INTO FirstName VALUES ('Ticiane')
INSERT INTO FirstName VALUES ('Tania')
INSERT INTO FirstName VALUES ('Jack')
INSERT INTO FirstName VALUES ('Kate')
INSERT INTO FirstName VALUES ('Hugo')
INSERT INTO FirstName VALUES ('Jin')
INSERT INTO FirstName VALUES ('Marcy')
INSERT INTO FirstName VALUES ('Darcy')
INSERT INTO FirstName VALUES ('Michael')
INSERT INTO FirstName VALUES ('Jackson')
INSERT INTO FirstName VALUES ('Joshua')
INSERT INTO FirstName VALUES ('Katy')
INSERT INTO FirstName VALUES ('Kristy')
INSERT INTO FirstName VALUES ('Marli')
INSERT INTO FirstName VALUES ('Sean')
INSERT INTO FirstName VALUES ('Italo')
INSERT INTO FirstName VALUES ('Icaro')
INSERT INTO FirstName VALUES ('Uiara')
INSERT INTO FirstName VALUES ('Legolas')
INSERT INTO FirstName VALUES ('Gimli')
INSERT INTO FirstName VALUES ('Gandalf')
INSERT INTO FirstName VALUES ('Boromir')
INSERT INTO FirstName VALUES ('Pippin')
INSERT INTO FirstName VALUES ('Merry')
INSERT INTO FirstName VALUES ('Charles')
INSERT INTO FirstName VALUES ('Max')
INSERT INTO FirstName VALUES ('Suzy')
INSERT INTO FirstName VALUES ('Bernardo')
INSERT INTO FirstName VALUES ('Bernard')
INSERT INTO FirstName VALUES ('Brunisa')
INSERT INTO FirstName VALUES ('Celine')
INSERT INTO FirstName VALUES ('Cicero')
INSERT INTO FirstName VALUES ('Cirilo')
INSERT INTO FirstName VALUES ('Conan')
INSERT INTO FirstName VALUES ('Colin')
INSERT INTO FirstName VALUES ('Terry')
INSERT INTO FirstName VALUES ('Batistuta')
INSERT INTO FirstName VALUES ('Maradonna')
INSERT INTO FirstName VALUES ('Edson')
INSERT INTO FirstName VALUES ('Ronaldo')
INSERT INTO FirstName VALUES ('Robson')
INSERT INTO FirstName VALUES ('Rivaldo')
INSERT INTO FirstName VALUES ('Aloisio')
INSERT INTO FirstName VALUES ('Ian')
INSERT INTO FirstName VALUES ('Ivo')
INSERT INTO FirstName VALUES ('Merlin')
INSERT INTO FirstName VALUES ('Lancelot')
INSERT INTO FirstName VALUES ('Guinevere')
GO

INSERT INTO LastName VALUES ('Silva')
INSERT INTO LastName VALUES ('Souza')
INSERT INTO LastName VALUES ('Caixeta')
INSERT INTO LastName VALUES ('Moreira')
INSERT INTO LastName VALUES ('Carvalho')
INSERT INTO LastName VALUES ('Borges')
INSERT INTO LastName VALUES ('Nascimento')
INSERT INTO LastName VALUES ('Xavier')
INSERT INTO LastName VALUES ('Neto')
INSERT INTO LastName VALUES ('Junior')
INSERT INTO LastName VALUES ('Filho')
INSERT INTO LastName VALUES ('Rezende')
INSERT INTO LastName VALUES ('Costa')
INSERT INTO LastName VALUES ('Fernandez')
INSERT INTO LastName VALUES ('Pavarino')
INSERT INTO LastName VALUES ('Miranda')
INSERT INTO LastName VALUES ('Catae')
INSERT INTO LastName VALUES ('Lopes')
INSERT INTO LastName VALUES ('Palma')
INSERT INTO LastName VALUES ('Blanco')
INSERT INTO LastName VALUES ('Scarano')
INSERT INTO LastName VALUES ('Zenker')
INSERT INTO LastName VALUES ('Simonelli')
INSERT INTO LastName VALUES ('Terni')
INSERT INTO LastName VALUES ('Canto')
INSERT INTO LastName VALUES ('Almeida')
INSERT INTO LastName VALUES ('Gonzalez')
INSERT INTO LastName VALUES ('Azeredo')
INSERT INTO LastName VALUES ('Ayala')
INSERT INTO LastName VALUES ('Bonifaz')
INSERT INTO LastName VALUES ('Albero')
INSERT INTO LastName VALUES ('Canasteiro')
INSERT INTO LastName VALUES ('Soto')
INSERT INTO LastName VALUES ('Maldonado')
INSERT INTO LastName VALUES ('Cardoso')
INSERT INTO LastName VALUES ('Mello')
INSERT INTO LastName VALUES ('Naya')
INSERT INTO LastName VALUES ('Delgado')
INSERT INTO LastName VALUES ('Perez')
INSERT INTO LastName VALUES ('Smith')
INSERT INTO LastName VALUES ('Martins')
INSERT INTO LastName VALUES ('Machado')
INSERT INTO LastName VALUES ('Campos')
INSERT INTO LastName VALUES ('Alvez')
INSERT INTO LastName VALUES ('Vieira')
INSERT INTO LastName VALUES ('Leite')
INSERT INTO LastName VALUES ('Martinelli')
INSERT INTO LastName VALUES ('Uchoa')
INSERT INTO LastName VALUES ('Moura')
INSERT INTO LastName VALUES ('Galvao')
INSERT INTO LastName VALUES ('Lobos')
INSERT INTO LastName VALUES ('Matias')
INSERT INTO LastName VALUES ('Faria')
INSERT INTO LastName VALUES ('Batista')
INSERT INTO LastName VALUES ('Arantes')
INSERT INTO LastName VALUES ('Brito')
INSERT INTO LastName VALUES ('Carrolo')
INSERT INTO LastName VALUES ('Mira')
INSERT INTO LastName VALUES ('Coelho')
INSERT INTO LastName VALUES ('Cruz')
INSERT INTO LastName VALUES ('Domingo')
INSERT INTO LastName VALUES ('Ferreira')
INSERT INTO LastName VALUES ('Figueira')
INSERT INTO LastName VALUES ('Garcia')
INSERT INTO LastName VALUES ('Gil')
INSERT INTO LastName VALUES ('Grillo')
INSERT INTO LastName VALUES ('Lima')
INSERT INTO LastName VALUES ('Magalhaes')
INSERT INTO LastName VALUES ('Madrigal')
INSERT INTO LastName VALUES ('Neves')
INSERT INTO LastName VALUES ('Osorio')
INSERT INTO LastName VALUES ('Prado')
INSERT INTO LastName VALUES ('Lara')
INSERT INTO LastName VALUES ('Leon')
INSERT INTO LastName VALUES ('Visconti')
INSERT INTO LastName VALUES ('Bonaldi')
INSERT INTO LastName VALUES ('Capitani')
INSERT INTO LastName VALUES ('Lengle')
INSERT INTO LastName VALUES ('Dunn')
INSERT INTO LastName VALUES ('Earp')
INSERT INTO LastName VALUES ('Emam')
INSERT INTO LastName VALUES ('Lino')
INSERT INTO LastName VALUES ('Angel')
INSERT INTO LastName VALUES ('Roda')
INSERT INTO LastName VALUES ('Ortiz')
INSERT INTO LastName VALUES ('Torres')
INSERT INTO LastName VALUES ('Freitas')
INSERT INTO LastName VALUES ('Fuentes')
INSERT INTO LastName VALUES ('Ayon')
INSERT INTO LastName VALUES ('Bernardos')
INSERT INTO LastName VALUES ('Botelho')
INSERT INTO LastName VALUES ('Nardi')
INSERT INTO LastName VALUES ('Gebara')
INSERT INTO LastName VALUES ('Fartura')
INSERT INTO LastName VALUES ('Hollanda')
INSERT INTO LastName VALUES ('Reffatti')
INSERT INTO LastName VALUES ('Pantoja')
INSERT INTO LastName VALUES ('Zamora')
INSERT INTO LastName VALUES ('Zorzi')
INSERT INTO LastName VALUES ('Bullock')
INSERT INTO LastName VALUES ('Lavigne')
INSERT INTO LastName VALUES ('Morissete')
INSERT INTO LastName VALUES ('Hendrix')
INSERT INTO LastName VALUES ('Kidman')
INSERT INTO LastName VALUES ('Willians')
INSERT INTO LastName VALUES ('Gordon')
INSERT INTO LastName VALUES ('Jetson')
INSERT INTO LastName VALUES ('Flintstones')
INSERT INTO LastName VALUES ('Macbeth')
INSERT INTO LastName VALUES ('Pedroso')
INSERT INTO LastName VALUES ('Saxton')
INSERT INTO LastName VALUES ('Malcom')
INSERT INTO LastName VALUES ('Leit�o')
INSERT INTO LastName VALUES ('Hipolito')
INSERT INTO LastName VALUES ('Santiago')
INSERT INTO LastName VALUES ('Marins')
INSERT INTO LastName VALUES ('Allen')
INSERT INTO LastName VALUES ('Martinez')
INSERT INTO LastName VALUES ('A')
INSERT INTO LastName VALUES ('B')
INSERT INTO LastName VALUES ('C')
INSERT INTO LastName VALUES ('D')
INSERT INTO LastName VALUES ('E')
INSERT INTO LastName VALUES ('F')
INSERT INTO LastName VALUES ('G')
INSERT INTO LastName VALUES ('H')
INSERT INTO LastName VALUES ('I')
INSERT INTO LastName VALUES ('J')
INSERT INTO LastName VALUES ('K')
INSERT INTO LastName VALUES ('L')
INSERT INTO LastName VALUES ('M')
INSERT INTO LastName VALUES ('N')
INSERT INTO LastName VALUES ('O')
INSERT INTO LastName VALUES ('P')
INSERT INTO LastName VALUES ('Q')
INSERT INTO LastName VALUES ('R')
INSERT INTO LastName VALUES ('S')
INSERT INTO LastName VALUES ('T')
INSERT INTO LastName VALUES ('U')
INSERT INTO LastName VALUES ('V')
INSERT INTO LastName VALUES ('X')
INSERT INTO LastName VALUES ('Z')
INSERT INTO LastName VALUES ('Zimmerman')
INSERT INTO LastName VALUES ('Ulrich')
INSERT INTO LastName VALUES ('Von')
INSERT INTO LastName VALUES ('Lichentstein')
INSERT INTO LastName VALUES ('Henrique')
INSERT INTO LastName VALUES ('Varanda')
INSERT INTO LastName VALUES ('Henwood')
INSERT INTO LastName VALUES ('Thompson')
INSERT INTO LastName VALUES ('Affleck')
INSERT INTO LastName VALUES ('Rohan')
INSERT INTO LastName VALUES ('Potter')
INSERT INTO LastName VALUES ('Granger')
INSERT INTO LastName VALUES ('Macgonnagal')
INSERT INTO LastName VALUES ('Macarthy')
INSERT INTO LastName VALUES ('Macaffe')
INSERT INTO LastName VALUES ('Martin')
INSERT INTO LastName VALUES ('Alring')
INSERT INTO LastName VALUES ('Muggle')
INSERT INTO LastName VALUES ('Ramses')
INSERT INTO LastName VALUES ('Rested')
INSERT INTO LastName VALUES ('Nristy')
INSERT INTO LastName VALUES ('Atikins')
INSERT INTO LastName VALUES ('Blaine')
INSERT INTO LastName VALUES ('Simpsons')
INSERT INTO LastName VALUES ('Bauer')
INSERT INTO LastName VALUES ('Dust')
INSERT INTO LastName VALUES ('Saywer')
INSERT INTO LastName VALUES ('Ofner')
INSERT INTO LastName VALUES ('Focker')
INSERT INTO LastName VALUES ('Mysty')
INSERT INTO LastName VALUES ('Serena')
INSERT INTO LastName VALUES ('Ferderer')
INSERT INTO LastName VALUES ('Nadal')
INSERT INTO LastName VALUES ('Kuerten')
INSERT INTO LastName VALUES ('Melingeni')
INSERT INTO LastName VALUES ('Maurinho')
INSERT INTO LastName VALUES ('Jefferson')
INSERT INTO LastName VALUES ('Berlin')
INSERT INTO LastName VALUES ('Roma')
INSERT INTO LastName VALUES ('Bart')
INSERT INTO LastName VALUES ('AA')
INSERT INTO LastName VALUES ('AB')
INSERT INTO LastName VALUES ('AC')
INSERT INTO LastName VALUES ('AD')
INSERT INTO LastName VALUES ('AE')
INSERT INTO LastName VALUES ('AF')
INSERT INTO LastName VALUES ('AG')
INSERT INTO LastName VALUES ('AH')
INSERT INTO LastName VALUES ('AI')
INSERT INTO LastName VALUES ('AJ')
INSERT INTO LastName VALUES ('AK')
INSERT INTO LastName VALUES ('AL')
INSERT INTO LastName VALUES ('AM')
INSERT INTO LastName VALUES ('AN')
INSERT INTO LastName VALUES ('AO')
INSERT INTO LastName VALUES ('AP')
INSERT INTO LastName VALUES ('AQ')
INSERT INTO LastName VALUES ('AR')
INSERT INTO LastName VALUES ('AS')
INSERT INTO LastName VALUES ('AT')
INSERT INTO LastName VALUES ('AU')
INSERT INTO LastName VALUES ('AV')
INSERT INTO LastName VALUES ('AX')
INSERT INTO LastName VALUES ('AZ')
INSERT INTO LastName VALUES ('AY')
INSERT INTO LastName VALUES ('AW')
INSERT INTO LastName VALUES ('Acrin')
INSERT INTO LastName VALUES ('Muerin')
INSERT INTO LastName VALUES ('Ray')
go

SELECT * FROM FirstName
SELECT * FROM LastName

/*
	Tabela com 60346 registros
*/
/*
INSERT INTO SmallNames
SELECT NEWID() AS Id, F.Fname + ' ' + L1.LName AS SmallName
FROM FirstName AS F
CROSS JOIN LastName AS L1
*/

USE master
GO