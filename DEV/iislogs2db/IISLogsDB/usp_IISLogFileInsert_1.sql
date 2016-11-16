CREATE PROCEDURE [dbo].[usp_IISLogFileInsert]
	@LogFilename [nvarchar](255) ,
	@MachineName [nvarchar](244) 
AS
SET XACT_ABORT ON
BEGIN TRANSACTION
	INSERT INTO [dbo].[IISLogFile]
	VALUES(@LogFilename, @MachineName)
COMMIT TRANSACTION
SELECT SCOPE_IDENTITY()
GO
GRANT EXEC ON [dbo].[usp_IISLogFileInsert] TO AddIISLogRole
GO
