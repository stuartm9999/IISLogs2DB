param (
	[Parameter(Mandatory=$true)][string]$path,
	[Parameter(Mandatory=$true)][String]$connString
)

function Main() {
       # get a list of files in the log directory
       get-childitem -Path $path -recurse -filter "*.log" | foreach-object {
              # rename the file so nothing else picks it up - rename to a .par
              [string]$NewFile =  [io.path]::ChangeExtension($_.FullName, "par")
              Move-Item -Path $_.FullName -Destination  $NewFile 
              try
              {
                     ParseFile($NewFile)
                     echo removing $NewFile
                     # should have all worked by this stage
                     Remove-Item $NewFile 
              }
              catch
              {      
                     Write-Error ("Failed to parse file" + $_.FullName + $_)              
                     [string]$ErrFile =  [io.path]::ChangeExtension($NewFile, "err")
                     Move-Item -Path $NewFile -Destination  $ErrFile                      
              }
              finally
              {

              }
              
       }
}

<#
Create a row for the Log File on the IISLogFile table.
We use a constraint on the database to stop us parsing the same file on the same 
computer twice leading to duplicate rows.
In the event of an error then you need to delete all the log entries then the file then
parse again.
#>
function CreateLogFileID([String]$fileName, [String]$computerName){
	[Nullable[int]] $IISFileNameID = $null
	$conn = new-object System.Data.SqlClient.SqlConnection $connString
	try {
		$conn.Open()
		[System.Data.SQLClient.SQLCommand]$Command =  $Command = New-Object System.Data.SQLClient.SQLCommand
		[String]$sproc = "[dbo].[usp_IISLogFileInsert]"
		$Command.Connection = $conn
		$command.CommandType = [System.Data.CommandType]::StoredProcedure
		$Command.CommandText = $sproc
		$Command.Parameters.Add("@LogFilename",[System.Data.SqlDbType]::NVarChar).Value = $fileName
		$Command.Parameters.Add("@MachineName",[System.Data.SqlDbType]::NVarChar).Value = $computerName
		$ret = $Command.ExecuteScalar()
		if($ret -ne [System.DBNull]::Value){
				$IISFileNameID = $ret
		}
	}
	finally{
              $conn.Close()
    }
	return $IISFileNameID
}


<#
This function calls the stored procedure with the data table passed through.
TODO - consider passing the connection too as probably more efficient.
#>
function saveLog([System.Data.DataTable]$IISLog) {
#Connection and Query Info
$query='[dbo].[usp_IISLogInsert]' 
 

#Connect

$conn = new-object System.Data.SqlClient.SqlConnection $connString
try {
$conn.Open()

#Create Sqlcommand type and params
$cmd = new-object System.Data.SqlClient.SqlCommand
$cmd.Connection = $conn
$cmd.CommandType = [System.Data.CommandType]"StoredProcedure"
$cmd.CommandText= $query
$null = $cmd.Parameters.Add("@TVP", [System.Data.SqlDbType]::Structured)
$cmd.Parameters["@TVP"].Value = $IISLog
$cmd.ExecuteNonQuery()
}
       finally{
              $conn.Close()
       }

       
}

# The columns in the TVP
$TVPColumns = @(
"IISLogFileId"  
	,"RowNumber" 
	,"date"
	,"time"
	,"datetime"
	,"cip" 
	,"csusername" 
	,"ssitename" 
	,"scomputername" 
	,"sip" 
	,"sport" 
	,"csmethod" 
	,"csuristem"
	,"csuriquery"
	,"scstatus" 
	,"scsubstatus" 
	,"scbytes" 
	,"scwin32status" 
	,"timetaken" 
	,"csversion" 
	,"cshost" 
	,"csUserAgent" 
	,"csCookie" 
	,"csReferrer" 
	,"sc-substatus" 
	)

function ParseFile([string]$File) {
       echo processing $File
	# create the logfile entry in the database.
	[Nullable[int]]$LogFileId = CreateLogFileId($File, $env:computername)
       $IISLog = New-Object System.Data.DataTable "IISLog"    
       # Get-Content gets the file, pipe to Where-Object and skip the first 3 lines.
       $reader = [System.IO.File]::OpenText($File)
try {
       [int]$x = 0
       # first three lines are header info and ignored
        $line = $reader.ReadLine()
              $line = $reader.ReadLine()
        $line = $reader.ReadLine()
        
              # the columns in the file
              $line = $reader.ReadLine()
              $line
              # Replace unwanted text in the line containing the columns.
              $Columns = (($line.TrimEnd()) -replace "#Fields: ", "" -replace "-","" -replace "\(","" -replace "\)","").Split(" ")
              $Columns
              
              # Count available Columns, used later
              $Count = $Columns.Length
       
              # Loop through each TVPColumn, 
			#create a new column through Data.DataColumn and add it to the DataTable
              foreach ($Column in $TVPColumns) {
                     $NewColumn = New-Object System.Data.DataColumn $Column, ([string])
                     $IISLog.Columns.Add($NewColumn)
              }
              
              # now the rest of the file
              while($null -ne ($line = $reader.ReadLine())) {
              
        
              $x++
              $Row = $line.TrimEnd().Split(" ")
              $AddRow = $IISLog.newrow()
			  #put in the id and the row number
			  $AddRow."IISLogFileId" = $LogFileId
			  $AddRow."RowNumber" = $x
			  [String]$dtime # the date time 
              for($i=0;$i -lt $Count; $i++) {
                     $ColumnName = $Columns[$i]
                     $AddRow.$ColumnName = $Row[$i]
				  if("date" -eq $ColumnName){
					  $dtime = $Row[$i] + " "
				  }
				  if("time" -eq $ColumnName){
					  $dtime += $Row[$i]
				  }
              }
			  $AddRow."datetime" = $dtime
              $IISLog.Rows.Add($AddRow)
              if(0 -eq $x % 1000) {
                     
                     saveLog($IISLog)
                     echo clearing data table
                     $IISLog.Clear()
              }
       
    }
       saveLog($IISLog)
       
}
finally {
    $reader.Close()
}
       
       
       
}
       

Main


