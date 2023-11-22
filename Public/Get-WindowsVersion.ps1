<#
  .Synopsis
    Retrive the Windows version number.
  .Description
    This is a public function used to retrieve the Windows version number and compare if it's older than 2012R2 or not.
  .Example
    Get-WindowsVersion
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-WindowsVersion {

  $check = "Windows version"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  try {
    # Check the Windows edition based on the version number
    $version = ([System.Environment]::OSVersion.Version)
    $major = $version.Major
    $minor = $version.Minor
    $build = $version.Build
    $osName = (Get-CimInstance -class Win32_OperatingSystem).Caption
    Write-Log -Message "Windows version is $version"
    Write-Log -Message "Windows edition is $osName"
    Write-Log -Message "Windows version major is $major"
    Write-Log -Message "Windows version minor is $minor"
    Write-Log -Message "Windows version build is $build"

    # Check the Windows edition
    if (($major -eq "6" -and $minor -le "3") -or $major -lt "6") {
      $value = "[RED]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "ERROR"
      $Action = "The host is running $osName. It's supported to host in AWS but it's EOS. Please consider upgrading. Learn more about AWS EOS options https://aws.amazon.com/windows/faq/#eos-m-qa."
      Write-Log -Message $Action -LogLevel "ERROR"
    }
    else {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No action required. The host is running $osName. It's supported to host in AWS and an actively supported OS by Microsoft."
      Write-Log -Message $Action
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-WindowsVersion."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}