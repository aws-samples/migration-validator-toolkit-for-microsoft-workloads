<#
  .Synopsis
    Count the number of IPv4.
  .Description
    Cound the number of IPv4 on the host. The function will count IPv4 IPv4 that are preferred "https://learn.microsoft.com/en-us/powershell/module/nettcpip/set-netipaddress?view=windowsserver2022-ps#-addressstate".
    The function will skip APIPA or loopback address.
  .Example
    Get-IPCount
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-IPv4Count {
  $check = "IP count\type"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Count the number of IPv4 used by the host and whether if they are static IPv4 or not."

  try {
    $ipv4 = Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred
    Write-Log -Message "The output of ""Get-NetIPAddress -AddressFamily IPv4 -AddressState Preferred"" is"
    Write-Log -Message $ipv4
    $dhcpIpCount = 0
    $manualIpCount = 0

    foreach ($ip in $ipv4) {
      if ($ip.AddressFamily -eq "IPv4" -and $ip.PrefixOrigin -eq "Dhcp" -and $ip.AddressState -eq "Preferred") {
        $dhcpIpCount += 1
        Write-Log -Message "DHCP IP $($ip.IPAddress)"
      }
      elseif ($ip.AddressFamily -eq "IPv4" -and $ip.PrefixOrigin -eq "Manual" -and $ip.AddressState -eq "Preferred") {
        $manualIpCount += 1
        Write-Log -Message "Manual IP $($ip.IPAddress)"
      }
    }

    Write-Log "There are $dhcpIpCount DHCP IPv4 addresses."
    Write-Log "There are $manualIpCount manual IPv4 addresses."
    $totalIpCount = $dhcpIpCount + $manualIpCount


    if ($totalIpCount -le 2 -and $manualIpCount -eq 0) {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No Action required. There are less than 2 IPv4 addresses, assigned by DHCP. All EC2 instances support that."
      Write-Log -Message $Action
    }
    elseif ($totalIpCount -le 2 -and $manualIpCount -ne 0) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There is $totalIpCount IPv4 address on the host, $manualIpCount assigned manually. Make sure the ENI that is attached to the EC2 insatnce matchs the IP address of the host - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    elseif ($totalIpCount -gt 2 -and $manualIpCount -eq 0) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There are $totalIpCount IP addresses on the host. Make sure to select the right EC2 instance - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    elseif ($totalIpCount -gt 2 -and $dhcpIpCount -eq 0) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There are $totalIpCount IP addresses on the host assigned manually. Make sure to select the right EC2 instance - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI. and the ENI that is attached to the ec2 insatnce matchs the IP address of the host - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    else {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "There are $totalIpCount IP addresses on the host and $manualIpCount assigned manually. Make sure to select the right EC2 instance - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI. and the ENI that is attached to the ec2 insatnce matchs the IP address of the host - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-NetIPAddress."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}