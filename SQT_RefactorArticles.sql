-- refactor the article reading time.
-- we don't need to calculate this every time.

-- Let's write a test
-- new class
-- use SQL Test to create new test and class
-- class Articles


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
EXEC tsqlt.AssertResultSetsHaveSameMetaData @expectedCommand = N'select * from Articles.Expected', -- nvarchar(max)
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

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Isolate function Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  - Test our function first
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 -- create test
 -- class: Articles
 -- Name: SetArticlesReadingEstimate_CheckCalculation

  --Assemble
  DECLARE @article VARCHAR(MAX)
	, @expresult INT
	, @actresult int
  SELECT @article = REPLICATE('alpha ', 1000)

  SELECT @expresult = 4

  -- act
  SELECT @actresult = dbo.calculateEstimateOfReadingTime(@article)
  SELECT @actresult 'act', @expresult 'exp', len(@article), @article 'art'

  -- assert
  EXEC tsqlt.AssertEquals @Expected = @expresult, -- sql_variant
    @Actual = @actresult, -- sql_variant
    @Message = N'' -- nvarchar(max)
  



--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          End Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- create a procedure to update the reading time for an article
CREATE PROCEDURE SetArticlesReadingEstimate
	@articleid AS int
AS
DECLARE @t TIME
 , @a VARCHAR(max)

SELECT
    @a = article
  FROM
    dbo.Articles A
  WHERE
    ArticlesID = @articleid;

SELECT
    @t = CONVERT(TIME, DATEADD(SECOND,
                               dbo.calculateEstimateOfReadingTime(@a),
                               0))

UPDATE
    dbo.Articles
  SET
    ReadingTimeEstimate = @t
  WHERE
    ArticlesID = @articleid

GO

-- quick developer check
SELECT TOP 10
    ReadingTimeEstimate
  , *
  FROM
    dbo.Articles A;

EXEC dbo.SetArticlesReadingEstimate @articleid = 1;
SELECT TOP 10
    ReadingTimeEstimate
  , *
  FROM
    dbo.Articles A;
 go


--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  - test our function
--------------------------------------------------------------------------
--------------------------------------------------------------------------

 -- create test
 -- class: Articles
  -- Name: SetArticlesReadingEstimate_CheckCalculation


 -- Assemble: 
 
  CREATE TABLE Articles.Expected (articlesid int, article VARCHAR(MAX), ReadingTimeEstimate time);

  EXEC tSQLt.FakeTable 'dbo.Articles';

  INSERT INTO dbo.Articles
    ( ArticlesID, Article, ReadingTimeEstimate)
    VALUES
      ( 10
      , REPLICATE('a', 325)
      , NULL
      )

  INSERT Articles.Expected
      ( articlesid, article, ReadingTimeEstimate )
    VALUES
      ( 10, -- articleid
        REPLICATE('a', 325), -- article
        '00:05:25'  -- readingtime
        )

  EXEC tSQLt.FakeFunction @FunctionName = N'dbo.calculateEstimateOfReadingTime', -- nvarchar(max)
            @FakeFunctionName = N'Articles.FakeReadingTime' -- nvarchar(max)

 

 -- Act:
   EXEC dbo.SetArticlesReadingEstimate @articleid = 10 -- int


 -- Assert:
  EXEC tsqlt.AssertEqualsTable @Expected = N'Articles.expected',
    @Actual = N'dbo.articles',
    @FailMsg = N'The reading estimate is incorrect.';
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          End Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- here's our function for the update test
CREATE FUNCTION Articles.FakeReadingTime ( @value varchar(MAX) )
RETURNS int
 AS
      BEGIN
        RETURN 325
      END


--


--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  - exceptions. Send in edge data
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--first check what happens
exec  SetArticlesReadingEstimate;


-- error


 -- create test
 -- class: Articles
 -- Name: check no articlesid sent
 -- same as update test, but no article

  -- Assemble
  CREATE TABLE Articles.Expected (articlesid int, article VARCHAR(MAX), ReadingTimeEstimate time);

  EXEC tSQLt.FakeTable 'dbo.Articles';

  INSERT INTO dbo.Articles
    ( ArticlesID, Article, ReadingTimeEstimate)
    VALUES
      ( 10
      , REPLICATE('a', 325)
      , NULL
      )

  INSERT Articles.Expected
      ( articlesid, article, ReadingTimeEstimate )
    VALUES
      ( 10, -- articleid
        REPLICATE('a', 325), -- article
        null  -- readingtime
        )

  EXEC tSQLt.FakeFunction @FunctionName = N'dbo.calculateEstimateOfReadingTime', -- nvarchar(max)
            @FakeFunctionName = N'Articles.FakeReadingTime' -- nvarchar(max)

 

 -- Act:
 -- no parameter
   EXEC dbo.SetArticlesReadingEstimate 


 -- Assert:
  EXEC tsqlt.AssertEqualsTable @Expected = N'Articles.expected',
    @Actual = N'dbo.articles',
    @FailMsg = N'The reading estimate is incorrect.';
  


  -- Fix test

  -- Assemble
  -- Act
  exec tSQLt.ExpectException;
  exec dbo.SetArticlesReadingEstimate;
  -- Assert
  
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          End Test  
--------------------------------------------------------------------------
--------------------------------------------------------------------------

-- refactor procedure:
-- include errorhandling and throw error

ALTER procedure SetArticlesReadingEstimate
	@articleid as int = null
/*
Comments:
05/22/2014 jsj - Refactored to specify parameter default and throw error if not supplied.
*/
as
DECLARE @t TIME
 , @a VARCHAR(max)


-- throw error if no parameter
if @articleid is null
  throw 50000, N'ArticlesID must be supplied.', 1; 

select
   @a = article
 FROM
    dbo.Articles A
 where
   ArticlesID = @articleid;

select
   @t = CONVERT(TIME, DATEADD(SECOND,
                               dbo.calculateEstimateOfReadingTime(@a),
                               0))

update
   dbo.Articles
 set
    ReadingTimeEstimate = @t
 where
    ArticlesID = @articleid;

GO

-- test
exec SetArticlesReadingEstimate;

-- fix test
  -- Assemble
  -- Act
  exec tSQLt.ExpectException
    @ExpectedMessage = 'ArticlesID must be supplied.';

  exec dbo.SetArticlesReadingEstimate;
  -- Assert




----------------------------------------------------------------------
----------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------
----------------------------------------------------------------------

-- group by object
-- we have a list of tables
select top 10
    TABLE_CATALOG
  , TABLE_SCHEMA
  , TABLE_NAME
  , TABLE_TYPE
  from
    INFORMATION_SCHEMA.TABLES T
  where TABLE_SCHEMA != 'tsqlt';


-- show SQLTest
exec tSQLt.NewTestClass @ClassName = N'RSSFeeds';
exec tSQLt.NewTestClass @ClassName = N'Contacts';
exec tSQLt.NewTestClass @ClassName = N'Blogs';
exec tSQLt.NewTestClass @ClassName = N'v_articles';
-- etc.



-- group by testing type
exec tSQLt.NewTestClass @ClassName = N'CITests';
exec tSQLt.NewTestClass @ClassName = N'AcceptanceTests';

-- execute by class
exec tSQLt.RunTestClass @TestClassName = N'Blogs' -- nvarchar(max)



-- version
 SELECT top 10
   *
  FROM tsqlt.Info() I