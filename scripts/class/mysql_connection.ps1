#####################################################################################################
#####################################################################################################

## Verbindung zur mySQL-Datenbank herstellen

#####################################################################################################
#####################################################################################################

function connect {

write-host ""
write-host "Verbindung zur Datenbank wird aufgebaut:"

## MYSQL Connection
## This requires mysql connector net

## All variables will need changing to suit your environment
$server= "localhost"
$username= "root"
$password= ""
$database= "smart"	#############################################################################

## The path will need to match the mysql connector you downloaded
[void][system.reflection.Assembly]::LoadFrom("C:\Program Files\MySQL\bin\MySQL.Data.dll")

function global:Set-SqlConnection ( $server = $(Read-Host "SQL Server Name"), $username = $(Read-Host "Username"), $password = $(Read-Host "Password"), $database = $(Read-Host "Default Database") ) {
	$SqlConnection.ConnectionString = "server=$server;user id=$username;password=$password;database=$database;pooling=false;Allow Zero Datetime=True;"
}

function global:Get-SqlDataTable( $Query = $(if (-not ($Query -gt $null)) {Read-Host "Query to run"}) ) {
	if (-not ($SqlConnection.State -like "Open")) { $SqlConnection.Open() }
	$SqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand $Query, $SqlConnection
	$SqlAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
	$SqlAdapter.SelectCommand = $SqlCmd
	$DataSet = New-Object System.Data.DataSet
	$SqlAdapter.Fill($DataSet) | Out-Null
	$SqlConnection.Close()
	return $DataSet.Tables[0]
}

Set-Variable SqlConnection (New-Object MySql.Data.MySqlClient.MySqlConnection) -Scope Global -Option AllScope -Description "Personal variable for Sql Query functions"
Set-SqlConnection $server $username $password $database

$mysqltest = Get-SqlDataTable 'SHOW STATUS'

## echo $mysqltest

#####################################################################################################
#####################################################################################################

## Select und ForEach Beispiel

#####################################################################################################
#####################################################################################################

## $global:Query = 'SELECT `field1`, `field2`, `field3` FROM table'
## $mysqlresults = Get-SqlDataTable $Query

## ForEach ($result in $mysqlresults){
##	echo $($result.field1)
##	echo $($result.field2)
##	echo $($result.field3)
## }

#####################################################################################################
#####################################################################################################

write-host "Verbindung aufgebaut!"

}
