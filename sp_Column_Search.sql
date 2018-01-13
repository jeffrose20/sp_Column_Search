--[dbo].[sp_Column_Search] 'error', 1

ALTER PROCEDURE [dbo].[sp_Column_Search]
(
	@ColumnString NVARCHAR(128),
	@GlobalSearch BIT = 0				--Value of 1 and this query will search all DBs on the server
)
AS

DECLARE @SQL VARCHAR(MAX) = ''
DECLARE @SearchString VARCHAR(MAX) = 
--? used as a dummy character to be replaced before execution
'
?

SELECT
	DB_NAME() AS DB_Name,
	AO.Name AS Object_Name,
	AC.*
FROM
	sys.all_objects AS AO
	INNER JOIN
		sys.all_columns AS AC
			ON AC.Object_ID = AO.Object_ID
WHERE
	AC.Name LIKE ''%' + @ColumnString + '%''
'

--If we are doing a global search, add in a dynamic 'USE [DatabaseName]' Statement
IF @GlobalSearch = 1
	BEGIN
		SELECT @SQL = @SQL + 
			REPLACE(@SearchString, '?', 'USE ' + name)
		FROM
			sys.databases

		EXEC(@SQL)
	END
ELSE	
	BEGIN
		SET @SQL = REPLACE(@SearchString, '?', '')
		EXEC(@SQL)
	END