--------------------------------------------------------------------------
--------------------------------------------------------------------------
--          Exception Demo
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- test for edge conditions
-- first check what happens
exec  SetArticlesReadingEstimate;


-- error




 -- create test
 -- class: Articles
 -- Name: SetArticlesReadingEstimate_NoParameter
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
-- Ignore a lack of a parameter
ALTER procedure SetArticlesReadingEstimate
	@articleid as int = null
/*
Comments:
05/22/2014 jsj - Refactored to specify parameter default and throw error if not supplied.
*/
as
DECLARE @t TIME
 , @a VARCHAR(max)


if @articleid is not null
  begin
    select
        @articleid = articlesid
      from
        ( select top ( 1 )
              articlesid
            from
              articles
        ) a;

    select
        @a = article
      from
        dbo.Articles A
      where
        ArticlesID = @articleid;

    select
        @t = convert(time, dateadd(second,
                                   dbo.calculateEstimateOfReadingTime(@a), 0))

    update
        dbo.Articles
      set
        ReadingTimeEstimate = @t
      where
        ArticlesID = @articleid;
  end

GO


-- run test
-- fails





-- we need to throw an exception for no parameter
-- refactor
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




