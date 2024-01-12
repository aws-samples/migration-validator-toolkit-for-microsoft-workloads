<#
.SYNOPSIS
    Run multiple checks for common MSFT workload related tasks to help migrating to AWS.
.DESCRIPTION
    This is tha main function to go through all checks related to MSFT workload to help migrating to AWS. Each check will be on a separate function. For more information visit - https://github.com/TBD
.EXAMPLE
	PS C:\> Invoke-MigrationValidatorToolkit
  	PS C:\> Invoke-MigrationValidatorToolkit -GridView
	PS C:\> Invoke-MigrationValidatorToolkit -List
.INPUTS
	GridView = Switch to have the output as gridview.
	GridView = Switch to have the output as table.
.OUTPUTS

#>
function Invoke-MigrationValidatorToolkit {
	param (
		[Switch]$GridView,
		[Switch]$List,
		[Switch]$csv
	)

	#Set the default file path and logs location, all errors should function as STOP errors for logging purposes
	begin {
		if (-not $csv) {
			Write-Log "Checking prerequisites before executing the Migration Validator Toolkit..." -ConsoleOutput
		}
		$psmajorversion = $PsVersionTable.PSVersion.Major
		$osmajorversion = ([System.Environment]::OSVersion.Version).Major
		$osminorversion = ([System.Environment]::OSVersion.Version).Minor
		$admincheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

		# Check if the current user has administrator privileges.
		if ($admincheck -eq $False) {
			Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again. Please check the ReadMe for the prerequisite requirements."
			Break
		}
		else {
			if (-not $csv) {
				Write-Log -Message "Code is running as administrator..." -ConsoleOutput
			}
		}
		# Check if OS version is 6.3(2012R2) or above
		if ($osmajorversion -lt 6) {
			Write-Warning "Server Version is NOT compatible with this module. Please check the ReadMe for the prerequisite requirements."
			Break
		}
		elseif ($osmajorversion -eq 6 -and $osminorversion -lt 3) {
			Write-Warning "Server Version is NOT compatible with this module. Please check the ReadMe for the prerequisite requirements."
			Break
		}
		else {
			if (-not $csv) {
				Write-Log "Server Version $osmajorversion.$osminorversion is compatible with this module..." -ConsoleOutput
			}
		}

		# Check if PS major version is 3 or above
		if ($psmajorversion -lt 4) {
			Write-Warning "The PowerShell Version $psmajorversion is NOT comptabile with this module. Please check the ReadMe for the prerequisite requirements."
			Break
		}
		else {
			if (-not $csv) {
		 	Write-Log -Message "The PowerShell Version $psmajorversion is compatible with this module - Executing script" -ConsoleOutput
			}
		}

		#Prefix for the file names
		$FileNamePrefix = "_MigrationValidatorToolkit_"
		#Name the log and Outputs files based on the timestamp
		$TimeStamp = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
		#The directory of this function
		$SourceDirectory = $PSScriptRoot
		#The parent directory of the module
		$ParentDirectory = (get-item $SourceDirectory).parent.fullname
		#Logs directory
		$LogsDirectory = ("$ParentDirectory\logs\" -replace ("util\\", ""))
		#Create logs directory if it does not exist
		if (-not (Test-Path $LogsDirectory)) {
			if (-not $csv) {
				Write-Log -Message "Creating logs directory - $LogsDirectory" -ConsoleOutput
			}
			New-item -Path $LogsDirectory -ItemType Directory | Out-Null
		}
		else {
			if (-not $csv) {
				Write-Log -Message "Logs directory exists - $LogsDirectory" -ConsoleOutput
			}
		}
		$computerHostName = Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty Name
		#Logs file name
		$LogsDestination = $LogsDirectory + $computerHostName + $FileNamePrefix + $TimeStamp + ".log"
		Write-Log -Message "Starting..."
		Write-Log -Message "The timestamp is the local system time"
		Write-Log -Message "Start time"
		$startTime = Get-Date
		Write-Log -Message $startTime
		Write-Log -Message "Computer host name: $computerHostName"
		#Outputs directory
		$OutputsDirectory = ("$ParentDirectory\Outputs\" -replace ("util\\", ""))
		#Create the Outputs directory if it does not exist
		if (-not (Test-Path $OutputsDirectory)) {
			Write-Log -Message "Creating Outputs directory - $OutputsDirectory"
			New-item -Path $OutputsDirectory -ItemType Directory | Out-Null
		}
		else {
			Write-Log -Message "Outputs directory exists - $OutputsDirectory"
		}
		$tempDirectory = ("$ParentDirectory\temp\" -replace ("util\\", ""))
		if (-not (Test-Path $tempDirectory)) {
			Write-Log -Message "Creating temp directory - $tempDirectory"
			New-item -Path $tempDirectory -ItemType Directory | Out-Null
		}
		else {
			Write-Log -Message "temp directory exists - $tempDirectory"
		}
		#Outputs file name
		$OutputsDestination = $OutputsDirectory + $computerHostName + $FileNamePrefix + $TimeStamp + ".txt"
		$csvDestination = $OutputsDirectory + $computerHostName + $FileNamePrefix + $TimeStamp + ".csv"

		#Set the output object
		$Output = New-Object -TypeName "System.Collections.ArrayList"
	}

	process {
		if (-not $csv) {
			Write-Log -Message "Logs available at $LogsDestination" -All
			Write-Log -Message "Outputs available at $OutputsDestination" -All
			Write-Log -Message "Running all the tests can take a few minutes..." -ConsoleOutput
			Write-Output @"
    __  ____                  __  _                _    __      ___     __      __                ______            ____   _ __
   /  |/  (_)___ __________ _/ /_(_)___  ____     | |  / /___ _/ (_)___/ /___ _/ /_____  _____   /_  __/___  ____  / / /__(_) /_
  / /|_/ / / __  / ___/ __  /   / / __ \/ __ \    | | / / __  / / / __  / __  / __/ __ \/ ___/    / / / __ \/ __ \/ / //_/ / __/
 / /  / / / /_/ / /  / /_/ / /_/ / /_/ / / / /    | |/ / /_/ / / / /_/ / /_/ / /_/ /_/ / /       / / / /_/ / /_/ / / ,< / / /_
/_/  /_/_/\__, /_/   \__,_/\__/_/\____/_/ /_/     |___/\__,_/_/_/\__,_/\__,_/\__/\____/_/       /_/  \____/\____/_/_/|_/_/\__/
         /____/
"@
		}

		Write-Log -Message "Checking the host product type, (1)Work Station(2)Domain Controller(3)Server"
		$productType = (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType
		Write-Log -Message "The host product type is $productType"

		# Calling each check in order
		Get-WindowsVersion | Out-Null
		Get-AuthenticationMethod | Out-Null
		Get-BootDiskSpace | Out-Null
		Get-DiskCount | Out-Null
		Get-DiskSize | Out-Null
		Get-DhcpStatus | Out-Null
		Get-IPv4Count | Out-Null
		Get-NetworkInterfaceCount | Out-Null
		Get-BootMode | Out-Null
		Get-ActiveDirectoryStatus -product $productType | Out-Null
		Get-FileServerStatus -product $productType | Out-Null
		Get-IISStatus -product $productType | Out-Null
		Get-SQLInstance -product $productType | Out-Null

		$Output | ForEach-Object { [PSCustomObject]$_ | Add-Member -Name "ComputerName" -Type NoteProperty -Value "$computerHostName" }

		if ($List) {
			$Output | ForEach-Object { [PSCustomObject]$_ } | Format-List
		}
		elseif ($GridView) {
			$Output | ForEach-Object { [PSCustomObject]$_ } | Select-Object -Property Check, Value, Action | Out-GridView -Title 'Migration Validator Toolkit'
		}
		elseif ($csv) {
			$Output | Select-Object -Property ComputerName, Check, Value, Action | ConvertTo-Csv -NoTypeInformation
		}
		else {
			$Output | ForEach-Object { [PSCustomObject]$_ } | Select-Object -Property Check, Value, Action | Format-Table -Wrap
		}
		$Output | ForEach-Object { [PSCustomObject]$_ } | Format-List | Out-File -FilePath $OutputsDestination
		$Output | Select-Object -Property ComputerName, Check, Value, Action | Export-Csv -Path $csvDestination -NoTypeInformation
	}
	end {
		Write-Log -Message "Deleting the temp directory - $tempDirectory"
		Remove-Item -Path "$ParentDirectory\temp" -Recurse
		Write-Log -Message "End time"
		$endTime = Get-Date
		Write-Log -Message $endTime
		Write-Log -Message "The END!!!"
	}
}