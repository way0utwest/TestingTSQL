/*
SQT - build test classes

Copyright 2014, Steve Jones and Red Gate Software

This code is provided as is for demonstration purposes. It may not be suitable for
your environment. Please test this on your own systems. This code may not be republished 
or redistributed by anyone without permission.
You are free to use this code inside of your own organization.


Description:
This script will refactor the database to help with the article reading time. we don't need to calculate this every time.
This will also add a test class and test for the Simple Talk demo application.
*/

-- check Articles table
select
    c.name
  from
    sys.columns C
  inner join sys.objects O
  on
    O.object_id = C.object_id
  where
    o.name = 'Articles';

-- we need to add [ReadingTime] to Articles










-- Let's write a test
-- First, create a new class
-- use SQL Test to create new test and class or run this code:
-- Class: Articles
exec tsqlt.NewTestClass @ClassName = N'Articles';


--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Check Meta Data Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------


--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 -- create test using stub or SQL Test
 -- class: Articles
 -- Name: Articles_Check_metadata

  --Assemble
 CREATE TABLE Articles.Expected
  (
	[ArticlesID] [INT] IDENTITY(1,1) NOT NULL,
	[AuthorID] [INT] NULL,
	[Title] [CHAR](142) NULL,
	[Description] [VARCHAR](MAX) NULL,
	[Article] [VARCHAR](MAX) NULL,
	[PublishDate] [DATETIME] NULL,
	[ModifiedDate] [DATETIME] NULL,
	[URL] [CHAR](200) NULL,
	[Comments] [INT] NULL
  );
  
  --Act
  
  --Assert
EXEC tsqlt.AssertResultSetsHaveSameMetaData @expectedCommand = N'select * from Articles.Expected', -- nvarchar(max)
  @actualCommand = N'select * from articles' -- nvarchar(max)
  

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          End Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- Start refactoring
-- alter table to store times.
/*
alter TABLE dbo.Articles
ADD ReadingTimeEstimate TIME;
*/



-- we need to fix our test first

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Alter Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 -- create test
 -- class: Articles
 -- Name: Articles_Check_metadata

  --Assemble
 CREATE TABLE Articles.Expected
  (
	[ArticlesID] [INT] IDENTITY(1,1) NOT NULL,
	[AuthorID] [INT] NULL,
	[Title] [CHAR](142) NULL,
	[Description] [VARCHAR](MAX) NULL,
	[Article] [VARCHAR](MAX) NULL,
	[PublishDate] [DATETIME] NULL,
	[ModifiedDate] [DATETIME] NULL,
	[URL] [CHAR](200) NULL,
	[Comments] [INT] NULL,
	[ReadingTimeEstimate] [TIME](7) NULL
  );
  
  --Act
  
  --Assert
EXEC tsqlt.AssertResultSetsHaveSameMetaData
  @expectedCommand = N'select * from Articles.Expected', -- nvarchar(max)
  @actualCommand = N'select * from articles' -- nvarchar(max)
  

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          End Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- run test
exec tsqlt.Run @TestName = N'Articles.[test Articles_Check_metadata]';

-- refactor table
alter table dbo.Articles
add ReadingTimeEstimate time;

-- retest
exec tsqlt.RunAll;


--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- END       Check Meta Data Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------

