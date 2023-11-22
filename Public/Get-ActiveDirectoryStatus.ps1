<#
  .Synopsis
    Check if the host is a domain controller or not.
  .Description
    Check if Active Directory Domain Services feature is installed and the host is promoted to domain controller.
  .Example
    Get-ActiveDirectoryStatus -product $token
  .INPUTS
	  $product = String
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-ActiveDirectoryStatus {
  [CmdletBinding()]
  param (
    [String]$product
  )

  $check = "AD Domain Controller"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  if ($product -gt "1") {
    Write-Log -Message "Check if the AD-Domain-Services role is installed and if the host is a Domain Controller."

    try {
      $adFeature = Get-WindowsFeature -Name "AD-Domain-Services"

      Write-Log -Message "The output of Get-WindowsFeature for AD-Domain-Services role is: "
      Write-Log -Message $adFeature

      if ($adFeature.InstallState -eq "Installed" -and $product -eq "2") {
        $value = "[YELLOW]"
        Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
        $Action = "The host is AD Domain Controller. Please check Migrating Active Directory - https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-active-directory-workloads.html."
        Write-Log -Message $Action -LogLevel "WARN"
      }
      elseif ($adFeature.InstallState -eq "Installed" -and $product -eq "3") {
        $value = "[GREEN]"
        Write-Log -Message "The output of the ""$check"" check is $value"
        $Action = "No action required. The active directory role is installed but the host is not a Domain Controller."
        Write-Log -Message $Action
      }
      else {
        $value = "[GREEN]"
        Write-Log -Message "The output of the ""$check"" check is $value"
        $Action = "No action required. The active directory role can not be found."
        Write-Log -Message $Action
      }
    }
    catch {
      Write-Log -Message "Failed..." -LogLevel "ERROR"
      $Action = "An error occurred when running Get-ActiveDirectoryStatus."
      Write-Log -Message $Action -LogLevel "ERROR"
      Write-Log -Message "$($_)" -LogLevel "ERROR"
      $value = "[RED]"
      Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
    }
  }
  else {
    $value = "[GREEN]"
    Write-Log -Message "The output of the ""$check"" check is $value"
    $Action = "No action required. The active directory role can not be found."
    Write-Log -Message $Action
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}