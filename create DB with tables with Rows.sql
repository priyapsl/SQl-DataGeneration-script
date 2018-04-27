DECLARE @dbName VARCHAR(8000)
DECLARE @dbNameChange VARCHAR(8000)
DECLARE @dbCount INT
DECLARE @i INT



-- modify the @dbName at below also
-- modify the @dbCount at below also
SET @i = 0; 

--Set the database name you want to keep 
SET	@dbName = 'myDBNAME' 

-- No of databases you want to create, change the value n as per your desired number of databases
SET @dbCount = n


-- Create the databases  
WHILE @i < @dbCount
	BEGIN 
			
		SET @dbNameChange ='CREATE DATABASE '+ @dbName + Cast(@i as nvarchar(5));
		EXEC (@dbNamechange);
		set @i = @i + 1;
	end

GO


-- Create Tables under created databases

DECLARE @dbName VARCHAR(8000)
DECLARE @dbNameChange VARCHAR(8000)
DECLARE @dbCount INT
DECLARE @tableName VARCHAR(8000)
DECLARE @tableNameChange VARCHAR(8000)
DECLARE @tableCount INT
DECLARE @rowCount INT
DECLARE @i INT
DECLARE @j INT
DECLARE @k int
DECLARE @insertRow VARCHAR(8000)
 

SET @i = 0;
SET @j = 0;
set @k = 0;

--Set the database name under which tables will be created
SET	@dbName = 'myDBNAME' 

-- no. of databases under which tables will be created
SET @dbCount = n

-- Give the tablename you want to create
SET @tableName = 'myTableNAME'  

--total no of tables in each database, change the value f m as per your desired number of table count 
SET @tableCount = m

-- total no of rows in each table; change the value of P as per your desired number of rows on each table 
SET @rowCount = P




WHILE @i < @dbCount
	BEGIN 
			

		WHILE (@j < @tableCount)
			BEGIN
								
				SET  @tableNameChange = 'USE '+@dbName+ CAST (@i as nvarchar(5))+ ';' 
				+'CREATE TABLE ' + @tableName + CAST (@j as nvarchar(5)) + ' (id int,id2 int)';
				EXEC (@tableNameChange);
				
				WHILE (@k < @rowCount)
					BEGIN
					set @insertRow = 'USE '+@dbName + CAST (@i as nvarchar(5))+';'
					+ 'INSERT INTO '+ @tableName +  CAST (@j as nvarchar(5)) + ' (id,id2)' +  ' VALUES (1,2);'
					EXEC (@insertRow);
					
					SET @k = @k + 1;
					END
					
					set @k = 0;
				
				SET @j =@j + 1;
			
			
			END
			
			set @j = 0;
		
	
		SET @i = @i + 1
	END
		
