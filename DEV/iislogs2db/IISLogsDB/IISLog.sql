CREATE TABLE [dbo].[IISLog]
(
	 [ID] bigint not null IDENTITY(1,1)
	,[IISLogFileId] INT NOT NULL REFERENCES IISLogFile(IISLogFileId)
	,[RowNumber] [int] NULL
	,[datetime] datetime2(0)
	,[sIp] [varchar](255) NULL
	,[csMethod] [varchar](255) NULL
	,[csUriStem] [varchar](255) NULL
	,[csUriQuery] [varchar](255) NULL
	,[sPort] [int] NULL
	,[csUsername] [varchar](255) NULL
	,[cIp] [varchar](255) NULL
	,[csUserAgent] [varchar](255) NULL
	,[scStatus] [int] NULL
	,[scSubstatus] [int] NULL
	,[scWin32Status] [int] NULL
	,[timeTaken] [int] NULL
)
