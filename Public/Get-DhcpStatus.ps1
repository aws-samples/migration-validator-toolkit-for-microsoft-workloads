<#
  .Synopsis
    Check if DHCP service is enabled.
  .Description
    Check if DHCP service is enabled.
  .Example
    Get-DhcpStatus
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-DhcpStatus {

  $check = "DHCP service"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check if DHCP service is enabled or not."

  try {
    $service = Get-Service -Name "dhcp"

    Write-Log -Message "The output of ""Get-Service -Name ""dhcp"""""
    Write-Log -Message $service

    if ($service.Status -eq "Running") {
      $value = "[GREEN]"
      Write-Log -Message "The check ""$check"" output is $value"
      $Action = "No Action required. DHCP service is enabled."
      Write-Log -Message $Action
    }
    else {
      $value = "[YELLOW]"
      Write-Log -Message "The check ""$check"" output is $value" -LogLevel "WARN"
      $Action = "DHCP service is not enabled. Before migration, enable DHCP service or make sure the source IP address on this host matches the the ENI that is attached to the ec2 insatnce. Please check using ENI - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html."
      Write-Log -Message $Action -LogLevel "WARN"
      #DHCP service is not enabled. Make sure the source IP address matches the desitination - https://docs.aws.amazon.com/mgn/latest/ug/copy-private.html or enable DHCP before migration"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-DhcpStatus."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }

  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}