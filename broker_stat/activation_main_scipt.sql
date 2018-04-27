create database SSBSLearning



GO

USE SSBSLearning;
GO
CREATE TABLE Sales(     
 SaleID INT IDENTITY(1,1),     
 SaleDate SMALLDATETIME,     
 SaleAmount MONEY,     
 ItemsSold INT);
GO

CREATE MESSAGE TYPE [RecordSale] 
VALIDATION = NONE;
CREATE CONTRACT [SalesContract] 
(      
[RecordSale] SENT BY INITIATOR); 
GO

CREATE QUEUE [SalesQueue];
CREATE SERVICE [SalesService] 
ON QUEUE [SalesQueue]
([SalesContract]);
GO

CREATE PROCEDURE usp_RecordSaleMessage
AS 
BEGIN
SET NOCOUNT ON;            
DECLARE @Handle UNIQUEIDENTIFIER;            
DECLARE @MessageType SYSNAME;            
DECLARE @Message XML            
DECLARE @SaleDate DATETIME             
DECLARE @SaleAmount MONEY           
DECLARE @ItemsSold INT;
                 
 RECEIVE TOP (1)                  
 @Handle = conversation_handle,                  
@MessageType = message_type_name,                   
@Message = message_body            
FROM [SalesQueue];                                        
IF(@Handle IS NOT NULL AND @Message IS NOT NULL)            
BEGIN                  
SELECT @SaleDate = CAST(CAST(@Message.query('/Params/SaleDate/text()') AS NVARCHAR(MAX)) AS DATETIME)                  
SELECT @SaleAmount = CAST(CAST(@Message.query('/Params/SaleAmount/text()') AS NVARCHAR(MAX)) AS MONEY)                  
SELECT @ItemsSold = CAST(CAST(@Message.query('/Params/ItemsSold/text()') AS NVARCHAR(MAX)) AS INT)
INSERT INTO Sales(SaleDate ,SaleAmount ,ItemsSold )   VALUES(@SaleDate,@SaleAmount,@ItemsSold);          
  END
END
GO

CREATE QUEUE [RecordSalesQueue];
CREATE SERVICE [RecordSalesService] 
ON QUEUE [RecordSalesQueue];
GO

ALTER QUEUE [SalesQueue] 
WITH ACTIVATION (      
STATUS = ON,      
MAX_QUEUE_READERS = 1,     
 PROCEDURE_NAME = usp_RecordSaleMessage,      
EXECUTE AS OWNER);
GO




CREATE PROCEDURE usp_SendSalesInfo
(      
		@SaleDate SMALLDATETIME,      
		@SaleAmount MONEY,       
		@ItemsSold INT
)
AS
BEGIN
      DECLARE @MessageBody XML      
	  CREATE TABLE #ProcParams     
	 (            
		SaleDate SMALLDATETIME,            
		SaleAmount MONEY,            
		ItemsSold INT      )      
		INSERT INTO #ProcParams(SaleDate,SaleAmount, ItemsSold)      
		VALUES(@SaleDate, @SaleAmount, @ItemsSold)
		SELECT @MessageBody = (SELECT * FROM #ProcParams FOR XML PATH ('Params'), TYPE);
		DECLARE @Handle UNIQUEIDENTIFIER;
		BEGIN DIALOG CONVERSATION @Handle      
		FROM SERVICE [RecordSalesService]     
		 TO SERVICE 'SalesService'      
		ON CONTRACT [SalesContract]     
		 WITH ENCRYPTION = OFF;
      SEND ON CONVERSATION @Handle       
		MESSAGE TYPE [RecordSale](@MessageBody);
END
use SSBSLearning
GO
DECLARE @MyCounter int;
SET @MyCounter = 0;
while (@MyCounter < 10000)
begin
	EXECUTE usp_SendSalesInfo '1/9/2005',30,90
	SET @MyCounter = @MyCounter + 1;
end
