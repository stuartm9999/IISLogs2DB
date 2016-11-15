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

       # the log table
       


function saveLog([System.Data.DataTable]$IISLog) {
#Connection and Query Info
$query='usp_insertList' 
 

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

#Create and fill dataset
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)
$null = $da.fill($ds)
              }
       finally{
              $conn.Close()
       }

       
}

function ParseFile([string]$File) {
       echo processing $File
       $IISLog = New-Object System.Data.DataTable "IISLog"    
       # Get-Content gets the file, pipe to Where-Object and skip the first 3 lines.
       $reader = [System.IO.File]::OpenText($File)
try {
       [int]$x = 0
       # first three lines are header info and ignored
        $line = $reader.ReadLine()
              $line = $reader.ReadLine()
        $line = $reader.ReadLine()
        
              # the columns
              $line = $reader.ReadLine()
              $line
              # Replace unwanted text in the line containing the columns.
              $Columns = (($line.TrimEnd()) -replace "#Fields: ", "" -replace "-","" -replace "\(","" -replace "\)","").Split(" ")
              $Columns
              
              # Count available Columns, used later
              $Count = $Columns.Length
       
              # Loop through each Column, create a new column through Data.DataColumn and add it to the DataTable
              foreach ($Column in $Columns) {
                     $NewColumn = New-Object System.Data.DataColumn $Column, ([string])
                     $IISLog.Columns.Add($NewColumn)
              }
              
              # now the rest of the file
              while($null -ne ($line = $reader.ReadLine())) {
              
        
              $x++
              $Row = $line.TrimEnd().Split(" ")
              $AddRow = $IISLog.newrow()
              for($i=0;$i -lt $Count; $i++) {
                     $ColumnName = $Columns[$i]
                     $AddRow.$ColumnName = $Row[$i]
              }
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


