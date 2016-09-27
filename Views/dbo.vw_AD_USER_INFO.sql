SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE  VIEW [dbo].[vw_AD_USER_INFO]
AS


SELECT * FROM OpenQuery(ADSI, '
select  givenName,
    sn,
    mail
from    ''LDAP://dc=lmc,dc=local''
where   objectCategory = ''Person''
        and
        objectClass = ''user''
')
GO
