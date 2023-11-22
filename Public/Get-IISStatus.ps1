<#
  .Synopsis
    Check if IIS server installed or not.
  .Description
    Check if File server Role is installed and the host.
  .Example
    Check if IIS server installed or not.
  .INPUTS
	  $product = String
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-IISStatus {
  [CmdletBinding()]
  param (
    [String]$product
  )

  $check = "IIS"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check if IIS roles is installed or not."
  try {
    if ($product -gt "1") {
      $IISRole = Get-WindowsFeature -Name "Web-Server"
      $WebServerRole = Get-WindowsFeature -Name "Web-WebServer"

      Write-Log -Message "The output of Get-WindowsFeature for Web Server (IIS) role is: $IISRole"
      Write-Log -Message $IISRole
      Write-Log -Message "The output of Get-WindowsFeature for Web Server role is: $WebServerRole"
      Write-Log -Message $WebServerRole
    }

    if ($IISRole.InstallState -eq "Installed" -or $WebServerRole.InstallState -eq "Installed") {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "IIS Server role is installed. If there is a webserver hosted on the host, please review Migrating .net app - https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-net-workloads.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }

    else {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No action required. IIS server role can not be found."
      Write-Log -Message $Action
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-WindowsFeature."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}