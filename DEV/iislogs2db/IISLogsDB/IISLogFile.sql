CREATE TABLE [dbo].[IISLogFile]
(
	[IISLogFileId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[LogFilename] [nvarchar](255) NOT NULL,
	[MachineName] [nvarchar](244) NOT NULL
	
)
