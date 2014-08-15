-- refactor the article reading time.
-- we don't need to calculate this every time.

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
-- new class
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
ALTER TABLE dbo.Articles
 ADD ReadingTimeEstimate TIME;


- retest
exec tsqlt.RunAll;


-- we need to fix our test.
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 -- create test
 -- class: Articles
 -- Name: check table meta data

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
	[ReadingTimeEstimate] [TIME](7) NULL,

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
	[ReadingTimeEstimate] [TIME](7) NULL,

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



--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- END       Check Meta Data Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------

