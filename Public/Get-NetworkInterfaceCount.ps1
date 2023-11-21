<#
  .Synopsis
    The number of network interfaces attached.
  .Description
    The number of physical network interfaces attached.
  .Example
    Get-NetworkInterfaceCount
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-NetworkInterfaceCount {

  $check = "Network interface count"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  try {
    $physicalNetworkInterface = Get-NetAdapter -physical
    $physicalNetworkInterfaceCount = $physicalNetworkInterface.count

    Write-Log -Message "The output of ""Get-NetAdapter -physical"""
    Write-Log -Message $physicalNetworkInterface
    Write-Log -Message "The count of physical network interface is: $($physicalNetworkInterfaceCount)"

    if ($physicalNetworkInterfaceCount -le 2) {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No Action required. The number of physical network interfaces supported by all EC2 instances."
      Write-Log -Message $Action
    }
    else {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There are $($physicalNetworkInterfaceCount) physical network interface attached. Before migration, select the right EC2 instance - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI."
      Write-Log -Message $Action -LogLevel "WARN"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-NetAdapter."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}