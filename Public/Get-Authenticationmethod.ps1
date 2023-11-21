<#
  .Synopsis
    Check if the host is a domain joined or not.
  .Description
    Check if server is part of a domain or not.
  .Example
    Get-AuthenticationMethod #-Token $token
  .INPUTS
	  $product = String
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-AuthenticationMethod {
  [CmdletBinding()]
  param (
    [String]$product
  )

  $check = "Authentication method"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check if the host is part of a domain or not."

  try {
    if ($product -ne "2" -and (Get-CimInstance -ClassName win32_computersystem).partofdomain -eq $true) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      Write-Log -Message "The host is part of a domain" -LogLevel "WARN"
      $Action = "The host is part of a domain. After migration, if there is connectivity to a Domain Controller, use a domain/local user to RDP. If not, use a local user."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    else {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "The host is not part of a domain. After migration, use a local user to RDP."
      Write-Log -Message $Action -LogLevel "WARN"
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-AuthenticationMethod."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }

  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}