<#
  .Synopsis
    Check the number of disks attached.
  .Description
    Check the number of disks attached.
  .Example
    Get-DiskCount
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-DiskCount {

  $check = "Disk Count"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check the number of disks attached to the host."

  try {
    $fileSystems = Get-PSDrive -PSProvider FileSystem
    $rootDriverName = (Get-PSDrive -PSProvider FileSystem |  Where-Object { $_.DisplayRoot -notlike "\\*" }).Name
    $diskCount = $rootDriverName.count

    Write-Log -Message "The output of ""Get-PSDrive -PSProvider FileSystem"""
    Write-Log -Message $fileSystems

    Write-Log -Message "The count of disks is: $($diskCount)"

    if ($diskCount -lt 18) {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No action required. The number of disks supported by all EC2 instances."
      Write-Log -Message $Action
    }
    else {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There are $($diskCount) disks attached. Before migration, select the right EC2 instance - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/volume_limits.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-DiskCount."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}