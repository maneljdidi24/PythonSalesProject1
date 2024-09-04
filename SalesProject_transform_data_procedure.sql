USE [SALES]  -- Use the SALES database
GO

/****** Object:  StoredProcedure [dbo].[sp_NomePlat]    Script Date: 30/11/2022 09:38:30 ******/
SET ANSI_NULLS ON  -- Set ANSI_NULLS to ON, standard for handling NULL values
GO
SET QUOTED_IDENTIFIER OFF  -- Set QUOTED_IDENTIFIER to OFF, allows for non-standard quoting of identifiers
GO

-- Declare variables for use in the stored procedure
DECLARE @Base AS VARCHAR(20)
DECLARE @site AS VARCHAR(2)
DECLARE @StrSQL AS VARCHAR(MAX)
DECLARE @D AS DATE
DECLARE @comptage INTEGER
DECLARE @plant AS VARCHAR(35)
SET @plant = '%'  

-- Initialize @date variable if needed
-- SET @date = DATEADD(MINUTE, -3, CAST(GETDATE() AS DATETIME))
-- SET @D = DATEADD(MINUTE, -3, CAST(GETDATE() AS DATETIME))

IF @base = 'information_schema' 
    SET @site = 'SALES'


DECLARE @Compose AS VARCHAR(35)
DECLARE @dat AS VARCHAR(35)
DECLARE @Nom_Table AS VARCHAR(35)
DECLARE @dateinv AS DATE

-- Temporary tables to store intermediate results
DECLARE @MyTableType AS TABLE(t VARCHAR(50), d DATE)  
DECLARE @MyTableDat AS TABLE(t VARCHAR(50), d DATE)  

-- Execute the Get_Items and ITEM_GROUPE_MATCHING stored procedures
EXEC Get_Items
EXEC ITEM_GROUPE_MATCHING

-- Declare a cursor to dynamically get the list of staging sales tables
DECLARE Cursor_Fil CURSOR FOR
    SELECT DISTINCT table_name AS t
    FROM information_schema.TABLES 
    WHERE TABLE_CATALOG = 'Sales'  
      AND TABLE_NAME LIKE 'Global_Sales_%'   

-- Open the cursor to browse through the tables
OPEN Cursor_Fil; 

-- Fetch the first table name into @Compose
FETCH NEXT FROM Cursor_Fil INTO @Compose

-- Loop through each table name
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Insert the table name into the @MyTableType table
    INSERT INTO @MyTableType(t)
    SELECT DISTINCT @Compose
    
    -- Insert the table data into @MyTableDat
    INSERT INTO @MyTableDat
    EXEC ('SELECT ''' + @Compose + ''', MAX(Inv_Date) AS d 
           FROM ' + @Compose + ' 
           WHERE confirmed = 0  
           GROUP BY MONTH(Inv_Date), YEAR(Inv_Date)')

    -- Select distinct table name and date into variables
    SELECT DISTINCT @Nom_Table = t, @dateinv = d 
    FROM @MyTableDat 

    -- Declare a cursor to iterate over dates
    DECLARE Cursor_dat CURSOR FOR
        SELECT d FROM @MyTableDat
                
    -- Open the date cursor
    OPEN Cursor_dat

    -- Fetch the first date into @dat
    FETCH NEXT FROM Cursor_dat INTO @dat
    
    -- Loop through each date
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT 'date=' + @dat  -- Print the current date for debugging
        
        -- Execute the sp_data stored procedure for each date
        IF @Nom_Table = @Compose
            EXEC sp_data @Nom_Table, @dat, @plant
         
        -- Fetch the next date
        FETCH NEXT FROM Cursor_dat INTO @dat
    END

    -- Close and deallocate the date cursor
    CLOSE Cursor_dat;
    DEALLOCATE Cursor_dat

    -- Fetch the next table name
    FETCH NEXT FROM Cursor_Fil INTO @Compose
END    

-- Close and deallocate the table name cursor
CLOSE Cursor_Fil;
DEALLOCATE Cursor_Fil
