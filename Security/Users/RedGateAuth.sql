IF NOT EXISTS (SELECT * FROM master.dbo.syslogins WHERE loginname = N'RedGateAuth')
CREATE LOGIN [RedGateAuth] WITH PASSWORD = 'p@ssw0rd'
GO
CREATE USER [RedGateAuth] FOR LOGIN [RedGateAuth]
GO
