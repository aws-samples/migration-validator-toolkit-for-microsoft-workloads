<#
  .Synopsis
    Check if the host is a File server or not.
  .Description
    Check if File server Role is installed and the host and whether there is any shared files.
  .Example
    Get-FileServerStatus -product $token
  .INPUTS
	  $product = String
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Get-FileServerStatus {
  [CmdletBinding()]
  param (
    [String]$product
  )

  $check = "File Server"
  Write-Log -Message "___________________________________________________________________"
  Write-Log -Message "New check....."
  Write-Log -Message "$check"

  Write-Log -Message "Check if File server roles is installed and if there is any shared folder with total size of share."

  if ($product -gt "1") {
    try {
      $FSRole = Get-WindowsFeature -Name "FS-FileServer"
      $DFSNameRole = Get-WindowsFeature -Name "FS-DFS-Namespace"
      $DFSReplicationRole = Get-WindowsFeature -Name "FS-DFS-Replication"
    }
    catch {
      Write-Log -Message "Failed..." -LogLevel "ERROR"
      $Action = "An error occurred when running Get-WindowsFeature."
      Write-Log -Message $Action -LogLevel "ERROR"
      Write-Log -Message "$($_)" -LogLevel "ERROR"
      $value = "[RED]"
      Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
    }
    Write-Log -Message "The output of Get-WindowsFeature for FS-FileServer role is: "
    Write-Log -Message $FSRole
    Write-Log -Message "The output of Get-WindowsFeature for FS-DFS-Namespace role is: "
    Write-Log -Message $DFSNameRole
    Write-Log -Message "The output of Get-WindowsFeature for FS-DFS-Replication role is: "
    Write-Log -Message $DFSReplicationRole
  }

  #$driver = (Get-PSDrive -PSProvider FileSystem |  Where-Object { $_.DisplayRoot -notlike "\\*" }).Name
  try {
    $smbShares = Get-SmbShare | Where-Object { $_.Description -notmatch "Remote Admin" -and $_.Description -notmatch "Default share" -and $_.Description -notmatch "Remote IPC" }

    Write-Log "The output for the share folders: "
    if ($null -ne $smbShares) {
      Write-Log $smbShares
      Write-Log "There are $($smbShares.Path.Count) of shared folders"
      foreach ($Share in $smbShares) {
        $folderPath = $Share.Path
        Write-Log "Retriving the information for $folderPath"
        $items = Get-ChildItem $folderPath -Recurse -File
        $size = [math]::Round(((($items | Measure-Object -Property Length -Sum).Sum) / 1073741824), 3)
        $count = ($items | Measure-Object).Count
        $totalSize = $totalSize + $size
        Write-Log "The Folder $folderPath has '$count' Files with size '$size' GB."
      }
      Write-Log "The total size of shared folders is '$totalSize' GB."
    }
    else {
      Write-Log "Null"
      Write-Log "There are not any shared folders"
    }

    if (($FSRole.InstallState -eq "Installed" -or $DFSNameRole.InstallState -eq "Installed" -or $DFSReplicationRole.InstallState -eq "Installed") -and $null -ne $totalSize) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "File server roles installed and there is $totalSize GB shared. Please check Migrating file servers - https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-file-servers-workloads.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    elseif (($FSRole.InstallState -eq "Installed" -or $DFSNameRole.InstallState -eq "Installed" -or $DFSReplicationRole.InstallState -eq "Installed") -and $null -ne $smbShares) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "File server roles installed but there is not shared files or folders. Please check Migrating file servers - https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-file-servers-workloads.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    elseif ($null -ne $totalSize) {
      $value = "[YELLOW]"
      Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
      $Action = "File server roles are not installed but there is $totalSize GB shared - Please check Migrating file servers https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-file-servers-workloads.html."
      Write-Log -Message $Action -LogLevel "WARN"
    }
    else {
      $value = "[GREEN]"
      Write-Log -Message "The output of the ""$check"" check is $value"
      $Action = "No action required. File server roles or shared folders can not be found."
      Write-Log -Message $Action
    }
  }
  catch {
    Write-Log -Message "Failed..." -LogLevel "ERROR"
    $Action = "An error occurred when running Get-SmbShare."
    Write-Log -Message $Action -LogLevel "ERROR"
    Write-Log -Message "$($_)" -LogLevel "ERROR"
    $value = "[RED]"
    Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
  }
  $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
}