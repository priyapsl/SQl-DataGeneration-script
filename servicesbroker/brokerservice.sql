
--create database AdventureWorks
--Listing 1 - Enable Service Broker

USE AdventureWorks
GO

-- enable service broker
IF (SELECT is_broker_enabled
  FROM sys.databases
  WHERE database_id = DB_ID()) = 0
    ALTER DATABASE AdventureWorks
    SET ENABLE_BROKER

--Listing 2 - Message Types and Contracts

-- message types
CREATE MESSAGE TYPE
[//JerBear.com/AsycRequest]
VALIDATION = WELL_FORMED_XML
GO

CREATE MESSAGE TYPE
[//JerBear.com/AsycResponse]
VALIDATION = WELL_FORMED_XML
GO

-- contract
CREATE CONTRACT
[//JerBear.com/AsyncContract]
(
  [//JerBear.com/AsycRequest] 
  SENT BY INITIATOR,
  [//JerBear.com/AsycResponse]
  SENT BY TARGET
)
GO

--Listing 3 - Queues and Services

-- queues
CREATE QUEUE AsyncRequestQueue
WITH STATUS = ON
GO

CREATE QUEUE AsyncResponseQueue
WITH STATUS = ON
GO

-- services
CREATE SERVICE
[//JerBear.com/AsyncRequestService]
ON QUEUE AsyncResponseQueue
([//JerBear.com/AsyncContract])
GO

CREATE SERVICE
[//JerBear.com/AsyncResponseService]
ON QUEUE AsyncRequestQueue
([//JerBear.com/AsyncContract])
GO

--Listing 4 - Stored Procedures

-- submission procedure
CREATE PROCEDURE dbo.uspAsyncRequest
(
    @Delay CHAR(8)
)
AS
  DECLARE @MsgString NVARCHAR(MAX)
  SET @MsgString = NCHAR(0xFEFF)
               + ''
               + ''
               + @Delay
               + ''
               + '"'

  DECLARE @Handle UNIQUEIDENTIFIER

  BEGIN DIALOG CONVERSATION @Handle
  FROM SERVICE
  [//JerBear.com/AsyncRequestService]
  TO SERVICE
  '//JerBear.com/AsyncResponseService'
  ON CONTRACT
  [//JerBear.com/AsyncContract]
  WITH ENCRYPTION = OFF

  ;SEND ON CONVERSATION @Handle
  MESSAGE TYPE
  [//JerBear.com/AsycRequest]
  (@MsgString)
GO

-- processing procedure
CREATE PROCEDURE dbo.uspAsyncProcessing
AS
  DECLARE @MsgXML XML
  ,@Handle        UNIQUEIDENTIFIER
  ,@MsgType       NVARCHAR(256)
  ,@Delay         CHAR(8)

  ;RECEIVE TOP(1)
    @Handle = conversation_handle
    ,@MsgXML = message_body
    ,@MsgType = message_type_name
  FROM AsyncRequestQueue

  IF @@ROWCOUNT = 0 RETURN

  SELECT @Delay =
    @MsgXML.value('(//Delay)[1]',
                  'CHAR(8)')

  WAITFOR DELAY @Delay

  ;SEND ON CONVERSATION @Handle
  MESSAGE TYPE
  [//JerBear.com/AsycResponse]
  (@MsgXML)

  END CONVERSATION @Handle
GO

-- response procedure
CREATE PROCEDURE dbo.uspAsyncResponse
AS
  DECLARE @MsgXML   XML
          ,@Handle  UNIQUEIDENTIFIER
          ,@MsgType NVARCHAR(256)
          ,@Delay	  CHAR(8)

  ;RECEIVE TOP(1)
    @Handle = conversation_handle
    ,@MsgXML = message_body
    ,@MsgType = message_type_name
  FROM AsyncResponseQueue

  IF @@ROWCOUNT = 0 RETURN

  SELECT @Delay =
    @MsgXML.value('(//Delay)[1]',
                  'CHAR(8)')

  WAITFOR DELAY @Delay

  END CONVERSATION @Handle
GO

--Listing 5 - Enable Activation

-- enable activation
ALTER QUEUE AsyncRequestQueue
WITH STATUS = ON,
  ACTIVATION (STATUS = ON,
  PROCEDURE_NAME = dbo.uspAsyncProcessing,
  MAX_QUEUE_READERS = 1,
  EXECUTE AS SELF)
GO

ALTER QUEUE AsyncResponseQueue
WITH STATUS = ON,
  ACTIVATION (STATUS = ON,
  PROCEDURE_NAME = dbo.uspAsyncResponse,
  MAX_QUEUE_READERS = 1,
  EXECUTE AS SELF)
GO

--run following code to test data

USE AdventureWorks
GO
DECLARE @intFlag INT
SET @intFlag = 1
WHILE (@intFlag <=100)
BEGIN
exec dbo.uspAsyncRequest'100'
End





