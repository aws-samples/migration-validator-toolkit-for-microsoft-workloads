<#
  .Synopsis
    Check the free disk space on the root volume.
  .Description
    Check the free disk space on the root volume. Required 2GB of disk space.
  .Example
    Get-RootDiskSpace
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>

Function Get-RootDiskSpace {
  $check = "Root Disk Free Space"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check if there is at least 2GB of free space on the root volume."

  try {
    $fileSystems = Get-PSDrive -PSProvider FileSystem
    $rootDriverName = (Get-PSDrive -PSProvider FileSystem |  Where-Object { $_.DisplayRoot -notlike "\\*" }).Name
    $rootDriverSize = (Get-PSDrive -PSProvider FileSystem |  Where-Object { $_.DisplayRoot -notlike "\\*" }).Free
    $rootDriverSizeGB = $rootDriverSize[0] / 1073741824
    $rootDriverFree = [math]::Round($rootDriverSizeGB, 3)

    Write-Log -Message "The output of ""Get-PSDrive -PSProvider FileSystem"""
    Write-Log -Message $fileSystems
    Write-Log -Message "Size of the free disk on the root drive $($rootDriverName[0]) is: $rootDriverFree"

    if ($rootDriverFree -gt 2) {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No action required. There is $rootDriverFree GB free space on $($rootDriverName[0]) Drive."
      Write-Log -Message $Action
    }
    else {
      $value = "[RED]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "ERROR"
      $Action = "System does not have enough free space on $ Drive. Amount of space available: $rootDriverFree GB. Required 2GB of free disk space for the migration."
      Write-Log -Message $Action -LogLevel "ERROR"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-RootDiskSpace."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}