<#
  .Synopsis
    Check the size of each disk.
  .Description
    Check the size of each disk.
  .Example
    Get-DiskSize
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-DiskSize {

  $check = "Disk size"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check the size of each disk attached."

  try {
    $logicalDisks = Get-WmiObject Win32_LogicalDisk
    $numberofOversizedDisks = ($logicalDisks | Where-Object { $_.Size -gt 65536GB }).Number.Count

    Write-Log -Message "The output of ""Get-WmiObject Win32_LogicalDisk"""
    Write-Log -Message $logicalDisks

    Write-Log -Message "The count of oversize disks is: $($numberofOversizedDisks)"

    if ($numberofOversizedDisks -eq 0) {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No Action required. The size of all disks are supported by all EC2 instances."
      Write-Log -Message $Action
    }
    else {
      $value = "[RED]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There are $($numberofOversizedDisks) disks over 64 TiB. Before migration. Please resize the EBS volume before migration - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/volume_constraints.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-DiskSize."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}