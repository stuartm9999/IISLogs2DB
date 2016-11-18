

CREATE TYPE [dbo].[TVPIISLog] AS TABLE
(
	[IISLogFileId] INT NOT NULL 
	,[RowNumber] [int] NULL
	,[date] [varchar](10)
	,[time] [varchar](10)
	,[datetime] datetime2(0)
	,[cip] [varchar](255) NULL
	,[csusername] [varchar](255) NULL
	,[ssitename] [varchar](255) NULL
	,[scomputername] [varchar](255) NULL
	,[sip] [varchar](255) NULL
	,[sport] [varchar](255) NULL
	,[csmethod] [varchar](255) NULL
	,[csuristem] [varchar](255) NULL
	,[csuriquery] [varchar](255) NULL
	,[scstatus] [int] NULL
	,[scsubstatus] [int] NULL
	,[scbytes] [int] NULL
	,[scwin32status] [int] NULL
	,[timetaken] [int] NULL
	,[csversion] [varchar](255) NULL
	,[cshost] [varchar](255) NULL
	,[csUserAgent] [varchar](255) NULL
	,[csCookie] [varchar](255) NULL
	,[csReferer] [varchar](255) NULL
	,[sc-substatus] [varchar](255) NULL
	
)