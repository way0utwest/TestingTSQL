-- SQT_Build_MetaDataCheck
--
-- Description:
-- This script will look at all the tables in your database and then generate the tsqlt
-- code to test for metadata for all tables. This is useful in refactoring to catch changes
-- to the schema that might impact other systems.

declare MyCurs cursor 
 for
  select
      t.TABLE_NAME
    , c.COLUMN_NAME 
	, c.data_type + ' '
	 +	case when c.DATA_TYPE in ('nvarchar', 'varchar', 'char', 'nchar')
		 then case when c.character_maximum_length = '-1'
		              then '(Max),' 
				else '(' + rtrim( cast(c.CHARACTER_MAXIMUM_LENGTH as char)) + '),'
		      end
		 else ', '
	end 
--	, DATA_TYPE, DATETIME_PRECISION, CHARACTER_MAXIMUM_LENGTH
    from
      INFORMATION_SCHEMA.TABLES t
    inner join INFORMATION_SCHEMA.COLUMNS C
    on
      C.TABLE_CATALOG = T.TABLE_CATALOG
      and C.TABLE_NAME = T.TABLE_NAME
      and C.TABLE_SCHEMA = T.TABLE_SCHEMA
 where t.TABLE_SCHEMA <> 'tsqlt'
 and t.TABLE_TYPE = 'BASE TABLE'
    order by
      C.TABLE_SCHEMA
    , C.TABLE_NAME
    , ORDINAL_POSITION

open mycurs

declare @table varchar(200)
, @col varchar(1000)
, @length varchar(200)
, @oldtable varchar(200)
, @cmd varchar(max)
, @lf varchar(2)


select @lf = char(13) + char(10);
select @oldtable = ' '
select @cmd = '';

fetch next from mycurs into @table, @col, @length


-- select @cmd = 'create table ' + @table + '.Expected ( '+ @lf

while @@FETCH_STATUS = 0
 begin 
  if @oldtable <> @table 
   begin
   
    -- new test
	select @cmd = @cmd + 'create procedure [' + @table + '].[test ' + @table + '_CheckMetaData]'
	select @cmd = @cmd + @lf + 'as ' + @lf + 'BEGIN '
	select @cmd = @cmd + @lf + @lf + '  --Assemble ' 

    -- remove last char (space or semicolon), then add new table create
	select @cmd = @cmd + @lf + 'create table ' + @table +  '.Expected ' + @lf + ' ('
	select @oldtable = @table
--	select 'New table ', @table
   end

  -- build next column
  select @cmd = @cmd + @lf + '  [' + @col + '] ' + @length 

  fetch next from mycurs into @table, @col, @length
  if @oldtable <> @table 
   begin
    -- remove last comma
    select @cmd = substring( @cmd, 1, len(@cmd) - 1) + @lf + ' );'

    -- Close procedure
	-- add the Act portion
	select @cmd = @cmd + @lf + @lf + '  -- Act'

	-- add the Assert portion
	select @cmd = @cmd + @lf + @lf + '  -- Assert'
	select @cmd = @cmd + @lf + '  exec tsqlt.AssertResultSetsHaveSameMetaData '
	select @cmd = @cmd + @lf + '     @expectedCommand = N''select * from ' + @table + '.Expected'','
	select @cmd = @cmd + @lf + '     @actualCommand = N''select * from ' + @table + ''','

	-- close procedure
	select @cmd = @cmd + @lf + @lf + ' end' + @lf + 'return ' + @lf

	-- GO
	select @cmd = @cmd + @lf + 'GO' + @lf

   end
 end

-- remove last comma and two format characters
select @cmd = substring( @cmd, 1, len(@cmd) - 1) + ');' + char(13) + char(10);

select @cmd

deallocate mycurs



