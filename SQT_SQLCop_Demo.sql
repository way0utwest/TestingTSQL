/* Red Gate Software Demo

SQT - SQL Cop standards
http://sqlcop.lessthandot.com

This code will create a procedure that violates a SQLCop test. It will then refactor the procedure
to pass the test.

Requires the tsqlt framework.

Copyright 2014, Steve Jones and Red Gate Software

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.

*/

-- create a new proc
USE SimpleTalkDev_Steve;
GO

CREATE PROCEDURE sp_GetArticles
AS
    SELECT  *
    FROM    dbo.Articles

GO



-- run SQL Cop tests
-- use SQL Test or this
EXEC tSQLt.RunTestClass @TestClassName = N'SQLCop' -- nvarchar(max)




-- Failed a SQL Cop test





-- rename
EXEC sp_rename 'sp_GetArticles', 'uspGetArticles';

-- drop recreate
/*
DROP PROCEDURE sp_GetArticles
GO
CREATE PROCEDURE uspGetArticles
AS
    SELECT  *
    FROM    dbo.Articles

GO
*/




-- retest
-- use SQL Test or this
EXEC tSQLt.Run
 @TestName = N'SQLCop.test Procedures Named SP_' -- nvarchar(max)
;
