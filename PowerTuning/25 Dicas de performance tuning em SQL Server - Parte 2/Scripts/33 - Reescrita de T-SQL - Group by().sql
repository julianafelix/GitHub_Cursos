/*
  Fabiano Neves Amorim
  http://blogfabiano.com
  mailto:fabianonevesamorim@hotmail.com
*/

-- Restaurar DB para testes
USE [master]
RESTORE DATABASE [FabianoDica33] 
FROM  DISK = N'D:\Fabiano\Trabalho\FabricioLima\Cursos\25 Dicas de performance tuning em SQL Server - Parte 2\Scripts\33 - Reescrita de T-SQL - Group by() - FabianoDica33.bak' 
WITH  FILE = 1,  NOUNLOAD,  STATS = 5, REPLACE
GO

USE [FabianoDica33]
GO

-- Cold cache
CHECKPOINT; DBCC FREEPROCCACHE(); DBCC DROPCLEANBUFFERS; SET STATISTICS IO ON;
GO
-- Para cada linha de CONTA_RECEBER, calcula o SUM de CONTA_RECEBER_LANCAMENTO
SELECT CONTA_RECEBER.EMPRE_CODIGO, CONTA_RECEBER.CTREC_NUMERO, Tab1.LANCAM_VLRREAL
  FROM CONTA_RECEBER
 OUTER APPLY (SELECT SUM(LANCAM_VLRREAL) LANCAM_VLRREAL
                FROM CONTA_RECEBER_LANCAMENTO
               WHERE CONTA_RECEBER_LANCAMENTO.EMPRE_CODIGO = CONTA_RECEBER.EMPRE_CODIGO
                 AND CONTA_RECEBER_LANCAMENTO.CTREC_NUMERO = CONTA_RECEBER.CTREC_NUMERO) AS Tab1
WHERE (CONTA_RECEBER.CTREC_DTCOMPENSACAO BETWEEN '2018-01-01 00:00:00' AND '2018-01-31 00:00:00')
GO
SET STATISTICS IO OFF;
GO
-- Cold cache
CHECKPOINT; DBCC FREEPROCCACHE(); DBCC DROPCLEANBUFFERS; SET STATISTICS IO ON;
GO

-- Se eu trocar o OUTER APPLY por CROSS APPLY, o resultado vai ser o mesmo?
SELECT CONTA_RECEBER.EMPRE_CODIGO, CONTA_RECEBER.CTREC_NUMERO, Tab1.LANCAM_VLRREAL
  FROM CONTA_RECEBER
 CROSS APPLY (SELECT SUM(LANCAM_VLRREAL) LANCAM_VLRREAL
                FROM CONTA_RECEBER_LANCAMENTO
               WHERE CONTA_RECEBER_LANCAMENTO.EMPRE_CODIGO = CONTA_RECEBER.EMPRE_CODIGO
                 AND CONTA_RECEBER_LANCAMENTO.CTREC_NUMERO = CONTA_RECEBER.CTREC_NUMERO) AS Tab1
WHERE (CONTA_RECEBER.CTREC_DTCOMPENSACAO BETWEEN '2018-01-01 00:00:00' AND '2018-01-31 00:00:00')
GO


-- Por que o resultado � o mesmo? 
-- O SUM na CONTA_RECEBER_LANCAMENTO sempre vai retornar uma linha, se o valor n�o existir, o retorno ser� NULL.
-- Sendo assim, o CROSS APPLY, sempre encontra uma linha nesse "lado do join"

-- Linha em conta_receber
SELECT EMPRE_CODIGO, CTREC_NUMERO 
  FROM CONTA_RECEBER
 WHERE EMPRE_CODIGO = 1 
   AND CTREC_NUMERO = 813677
GO

-- N�o existe em CONTA_RECEBER_LANCAMENTO
SELECT * 
  FROM CONTA_RECEBER_LANCAMENTO
 WHERE EMPRE_CODIGO = 1 
   AND CTREC_NUMERO = 813677
GO

-- Mas e se eu "agrupar" por LANCAM_VLRREAL?
-- Qual � o resultado? 
SELECT SUM(LANCAM_VLRREAL) 
  FROM CONTA_RECEBER_LANCAMENTO
 WHERE EMPRE_CODIGO = 1 
   AND CTREC_NUMERO = 813677
GO


-- Ent�o posso trocar por CROSS APPLY? 
-- Pode, mas cuidado... pq o plano muda...

-- Pegando um per�odo maior pra fazer um teste melhor

-- Cold cache
CHECKPOINT; DBCC FREEPROCCACHE(); DBCC DROPCLEANBUFFERS; SET STATISTICS IO ON;
GO
-- Hash join?
SELECT CONTA_RECEBER.EMPRE_CODIGO, CONTA_RECEBER.CTREC_NUMERO, Tab1.LANCAM_VLRREAL
  FROM CONTA_RECEBER
 CROSS APPLY (SELECT SUM(LANCAM_VLRREAL) LANCAM_VLRREAL
                FROM CONTA_RECEBER_LANCAMENTO
               WHERE CONTA_RECEBER_LANCAMENTO.EMPRE_CODIGO = CONTA_RECEBER.EMPRE_CODIGO
                 AND CONTA_RECEBER_LANCAMENTO.CTREC_NUMERO = CONTA_RECEBER.CTREC_NUMERO) AS Tab1
WHERE (CONTA_RECEBER.CTREC_DTCOMPENSACAO BETWEEN '2015-01-01 00:00:00' AND '2018-12-31 00:00:00')
GO

-- Cold cache
CHECKPOINT; DBCC FREEPROCCACHE(); DBCC DROPCLEANBUFFERS; SET STATISTICS IO ON;
GO
-- For�ando o loop join
SELECT CONTA_RECEBER.EMPRE_CODIGO, CONTA_RECEBER.CTREC_NUMERO, Tab1.LANCAM_VLRREAL
  FROM CONTA_RECEBER
 CROSS APPLY (SELECT SUM(LANCAM_VLRREAL) LANCAM_VLRREAL
                FROM CONTA_RECEBER_LANCAMENTO
               WHERE CONTA_RECEBER_LANCAMENTO.EMPRE_CODIGO = CONTA_RECEBER.EMPRE_CODIGO
                 AND CONTA_RECEBER_LANCAMENTO.CTREC_NUMERO = CONTA_RECEBER.CTREC_NUMERO) AS Tab1
WHERE (CONTA_RECEBER.CTREC_DTCOMPENSACAO BETWEEN '2015-01-01 00:00:00' AND '2018-12-31 00:00:00')
OPTION(LOOP JOIN)
GO

-- Cold cache
CHECKPOINT; DBCC FREEPROCCACHE(); DBCC DROPCLEANBUFFERS; SET STATISTICS IO ON;
GO
-- For�ando o merge join
SELECT CONTA_RECEBER.EMPRE_CODIGO, CONTA_RECEBER.CTREC_NUMERO, Tab1.LANCAM_VLRREAL
  FROM CONTA_RECEBER
 CROSS APPLY (SELECT SUM(LANCAM_VLRREAL) LANCAM_VLRREAL
                FROM CONTA_RECEBER_LANCAMENTO
               WHERE CONTA_RECEBER_LANCAMENTO.EMPRE_CODIGO = CONTA_RECEBER.EMPRE_CODIGO
                 AND CONTA_RECEBER_LANCAMENTO.CTREC_NUMERO = CONTA_RECEBER.CTREC_NUMERO) AS Tab1
WHERE (CONTA_RECEBER.CTREC_DTCOMPENSACAO BETWEEN '2015-01-01 00:00:00' AND '2018-12-31 00:00:00')
OPTION(MERGE JOIN)
GO

-- E qual � mais melhor? O Loop, o Hash ou o Merge? 
-- N�o sei... testa...


-- Nota: Logicas reads n�o foi t�o ruim n�? ... 
-- Uma coisa ler do disco, custos altos, outra coisa � fazer a leitura l�gica... 
-- QO n�o leva em considera��o a quantidade de linhas em uma p�gina... 
-- Qto mais linhas, maior a chance de o SQL reaproveitar um i/o fisico e fazer uma
-- leitura l�gica...
