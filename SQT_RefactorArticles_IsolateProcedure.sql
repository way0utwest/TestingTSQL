--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Isolate Sproc Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- We want to write a stored procedure to update our reading time
-- Isolate this from our function.

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  - Test our function first
--------------------------------------------------------------------------
--------------------------------------------------------------------------
 -- create test
 -- class: Articles
 -- Name: calculateEstimateOfReadingTime_CheckCalculation

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
  EXEC tsqlt.AssertEquals
    @Expected = @expresult, -- sql_variant
    @Actual = @actresult, -- sql_variant
    @Message = N'Incorrect calculation of reading time' -- nvarchar(max)
  



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
go
select TOP 10
    ReadingTimeEstimate
  , *
  FROM
    dbo.Articles A;
 go


--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Start Test  - test our procedure
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
--          End Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------

