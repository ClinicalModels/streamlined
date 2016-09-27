SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[update_data_active_directory]
AS

SET NOCOUNT ON
/* AD is limited to send 1000 records in one batch. to work around this limit we loop through the alphabet. */

DECLARE @cmdstr varchar(255)

DECLARE @nAsciiValue smallint

DECLARE @sChar char(1)

SELECT @nAsciiValue = 65

WHILE @nAsciiValue < 91

BEGIN

SELECT @sChar= CHAR(@nAsciiValue)

EXEC master..xp_sprintf @cmdstr OUTPUT, 'SELECT mail, sn, givenName

FROM OPENQUERY( ADSI, ''SELECT givenName, sn, mail

FROM ''''LDAP://DC=lmc, DC=local''''WHERE objectCategory = ''''Person'''' AND SAMAccountName = ''''%s*'''''' )', @sChar

INSERT ADUsers EXEC( @cmdstr )

SELECT @nAsciiValue = @nAsciiValue + 1

END
GO
