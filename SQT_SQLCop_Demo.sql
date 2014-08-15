-- Red Gate Software Demo
--
-- SQT - SQL Cop standards
-- http://sqlcop.lessthandot.com
--
-- This code is provided as is with no warranty implied.
-- Copyright 2014 Steve Jones
--

-- create a new proc
USE SimpleTalkDev;
GO

CREATE PROCEDURE sp_GetArticles
AS
    SELECT  *
    FROM    dbo.Articles

GO



-- run SQL Cop tests
-- use SQL Test or this
EXEC tSQLt.RunTestClass @TestClassName = N'SQLCop' -- nvarchar(max)




-- rename
EXEC sp_rename 'sp_GetArticles', 'uspGetArticles';

-- drop recreate
/*
DROP PROCEDURE sp_GetArticles
GO
CREATE PROCEDURE sp_GetArticles
AS
    SELECT  *
    FROM    dbo.Articles

GO
*/




-- retest
-- use SQL Test or this
EXEC tSQLt.RunTestClass @TestClassName = N'SQLCop' -- nvarchar(max)

