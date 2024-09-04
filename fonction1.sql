USE [SALES]
GO
/****** Object:  StoredProcedure [dbo].[sp_NomePlat]    Script Date: 30/11/2022 09:38:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


declare @Base as varchar(20)
declare @site as varchar(2)
declare @StrSQL as varchar(MAX)
DECLARE @D as date
declare @comptage integer


declare @plant as varchar(35)
SET @plant='%'
--set @date= DATEADD(MINUTE, -3, cast(GETDATE() as datetime))
--set @D= DATEADD(MINUTE, -3, cast(GETDATE() as datetime))
if @base='information_schema' set @site='SALES'
--print @d
--set @StrSQL="

DECLARE @Compose as varchar(35)
DECLARE @dat as varchar(35)
DECLARE @Nom_Table AS varchar(35)
declare @dateinv as date
--declare @plant as date
declare @MyTableType as table(t varchar(50),d date)  
declare @MyTableDat as table(t varchar(50),d date)  

exec Get_Items

exec ITEM_GROUPE_MATCHING

DECLARE Cursor_Fil cursor for
  --to dynamically have the list of staging sales tables 
	(SELECT  distinct table_name  as t
	 FROM information_schema.TABLES 
                   WHERE TABLE_CATALOG = 'Sales'  and  TABLE_NAME  like  'Global_Sales_%'   ) 
	
--	to browse tables 
	OPEN Cursor_Fil; 
	FETCH NEXT FROM Cursor_Fil 
	INTO @Compose
	
	WHILE @@FETCH_STATUS = 0
	
		BEGIN
			Insert into @MyTableType(t)
			SELECT distinct @Compose
			
			Insert into @MyTableDat
			
			execute ('select  '''+ @Compose +''' ,max(Inv_Date)as d  from '+ @Compose +' WHERE confirmed=0  group by month(inv_date),year(inv_date)')
			
			SELECT  distinct @Nom_Table=t,@dateinv=d from @MyTableDat 
			   
			   DECLARE Cursor_dat cursor for
			
				select d from @MyTableDat				
				
				OPEN Cursor_dat
				FETCH NEXT FROM Cursor_dat
				INTO @dat	
				
					while @@FETCH_STATUS = 0
						begin
							print 'date='+ @dat
							
							if  @Nom_Table=@Compose
							exec sp_data @Nom_Table,@dat,@plant
								 
							FETCH NEXT FROM Cursor_dat 
							INTO @dat
						end 

					CLOSE Cursor_dat;
					DEALLOCATE Cursor_dat

		FETCH NEXT FROM Cursor_Fil 
		INTO @Compose
			
		END	

	CLOSE cursor_Fil;
	DEALLOCATE cursor_Fil


----select * from @MyTableType
--print @compose

--select * from @MyTableDat


--"



--execute (@StrSQL)








