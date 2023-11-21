<#
  .Synopsis
    Run the module on multiple hosts and create a CSV file
  .Description
    This is a public function to run the migration automation on multiple hosts at the same time and generate a CSV file for the output of all hosts.
    # Ref
    # https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-1/
    # https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-2/
    # https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-3/
  .Example
    Invoke-DomainComputers
  .INPUTS
	  NA
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
Function Invoke-DomainComputers {
    param (
        [String]$s3BucketName,
        [String]$s3KeyPrefix
    )

    $StartTime = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
    Write-host "Start date and time (yyyy-MM-ddTHH-mm-ss): $StartTime"

    $SourceDirectory = $PSScriptRoot
    $ParentDirectory = (get-item $SourceDirectory).parent.fullname
    $FileNamePrefix = "_MigrationValidatorToolkit_"
    $OutputsDirectory = ("$ParentDirectory\Outputs\" -replace ("util\\", ""))
    $OutputFileName = $OutputsDirectory + "DomainComputers" + $FileNamePrefix + $StartTime + ".csv"

    $serverlist = import-csv -path "$ParentDirectory\inputs\serverlist.csv" -Delimiter ','

    $jobs = New-Object System.Collections.ArrayList

    $serverlist | ForEach-Object {
        $PowerShell = [powershell]::Create()
        $PowerShell.RunspacePool = $RunspacePool

        # AddScript is to literally add a PowerShell script to invoke

        $computerName = $_.ComputerName

        [void]$PowerShell.AddScript({ Param($computerName, $s3BucketName, $s3KeyPrefix)
                $ThreadID = [appdomain]::GetCurrentThreadId()

                # Invoking a command against a remote computer $_

                $output = Invoke-Command -ComputerName $computerName -ScriptBlock { Param($s3BucketName, $s3KeyPrefix)
                    # Enable TLS 1.2 for this PowerShell session only.
                    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                    $uri = 'https://tyandaliblog.s3.amazonaws.com/msft-migration-toolkit-main.zip'
                    $destination = (Get-Location).Path
                    if ((Test-Path -Path "$destination\msft-migration-toolkit-main.zip" -PathType Leaf) -or (Test-Path -Path "$destination\msft-migration-toolkit-main")) {
                        Remove-Item -Path "$destination\msft-migration-toolkit-main.zip" -Recurse
                        Remove-Item -Path "$destination\msft-migration-toolkit-main" -Recurse
                        #write-host "File $destination\msft-migration-toolkit-main.zip or folder $destination\msft-migration-toolkit-main found, exiting"
                    }
                    if ($s3BucketName) {
                        Get-S3Object -BucketName $s3BucketName -KeyPrefix $s3KeyPrefix | Read-S3Object -Folder $destination | Out-Null
                    }
                    else {
                        $webClient = New-Object System.Net.WebClient
                        $webClient.DownloadFile($uri, "$destination\msft-migration-toolkit-main.zip")
                    }
                    #Write-host "Extracting msft-migration-toolkit-main.zip..."
                    Expand-Archive -Path "$destination\msft-migration-toolkit-main.zip" -DestinationPath "$destination\msft-migration-toolkit-main"
                    #Write-host "Extracting msft-migration-toolkit-main.zip complete successfully"
                    Import-Module "$destination\msft-migration-toolkit-main\msft-migration-toolkit-main\MigrationValidatorToolkit.psm1"; Invoke-MigrationValidatorToolkit -csv
                } -ArgumentList $s3BucketName, $s3KeyPrefix

                # Data returned as output can be available when you describe the PowerShell job
                # Ensure your script returns an output not info using Write-Host, for example
                Write-Output $output | Select-object -skip 1
            }).AddArgument($computerName).AddArgument($s3BucketName).AddArgument($s3KeyPrefix)

        # [void]$PowerShell.AddParameters($Parameters)
        $Handle = $PowerShell.BeginInvoke()
        $temp = [PSCustomObject]@{
            PowerShell      = $null
            Handle          = $null
            targetID        = $null
            startInvocation = $null
            endInvocation   = $null
        }
        $temp.PowerShell = $PowerShell
        $temp.Handle = $Handle
        $temp.targetID = $ComputerName
        $temp.startInvocation = Get-Date
        [void]$jobs.Add($temp)
    }

    # Use while loop to wait until all jobs complete
    $jobCount = $($jobs.count)
    $count = $jobCount
    $failedJobCount = 0
    $completedJobCount = 0
    $timedOutJobCount = 0
    $completedJobTargets = @()
    $failedJobTargets = @()
    $timedOutJobTargets = @()
    $return = $null
    while ($count -ne 0) {
        #$count = ($jobs | Where-Object { $_.Handle.iscompleted -ne 'Completed' }).Count
        Write-Progress `
            -Activity "Waiting for jobs to complete" `
            -PercentComplete ((($jobCount - $count) / $count) * 100) `
            -Status "$count job remaining out of $jobCount"
        $jobs | ForEach-Object {
            if ($_.endInvocation -eq $null -and $_.PowerShell.HadErrors -eq $False -and $_.Handle.IsCompleted -eq $True) {
                $return = $return + $_.PowerShell.EndInvoke($_.Handle)
                $_.endInvocation = Get-Date
                $Timer = $_.endInvocation - $_.startInvocation
                Write-Host "-------------------------"
                Write-Host "Target: $($_.targetID)"
                Write-Host "Start Time is:"$_.startInvocation
                Write-Host "End Time is:" $_.endInvocation
                Write-Host "Job complete successfully after $($Timer.Hours):$($Timer.Minutes):$($Timer.Seconds):$($Timer.Milliseconds) HH:MM:SS:mS" -BackgroundColor Dark[GREEN] -ForegroundColor White
                Write-Host "PowerShell.HadErrors: $($_.PowerShell.HadErrors), Handle.IsCompleted: $($_.Handle.IsCompleted), PowerShell.InvocationStateInfo.State: $($_.PowerShell.InvocationStateInfo.State)"
                $_.PowerShell.Dispose()
                $count = $count - 1
                $completedJobTargets = $completedJobTargets + $_.targetID
                $completedJobCount = $completedJobCount + 1
            }
            elseif ($_.endInvocation -eq $null -and $_.PowerShell.HadErrors -eq $True -and $_.Handle.IsCompleted -eq $True) {
                $_.endInvocation = Get-Date
                $Timer = $_.endInvocation - $_.startInvocation
                Write-Host "-------------------------"
                Write-Host "Target: $($_.targetID)"
                Write-Host "Start Time is:"$_.startInvocation
                Write-Host "End Time is:" $_.endInvocation
                Write-Host "Job failed after $($Timer.Hours):$($Timer.Minutes):$($Timer.Seconds):$($Timer.Milliseconds) HH:MM:SS:mS" -BackgroundColor Dark[RED] -ForegroundColor White
                Write-Host "PowerShell.HadErrors: $($_.PowerShell.HadErrors), Handle.IsCompleted: $($_.Handle.IsCompleted), PowerShell.InvocationStateInfo.State: $($_.PowerShell.InvocationStateInfo.State)"
                $_.PowerShell.Dispose()
                $count = $count - 1
                $failedJobTargets = $failedJobTargets + $_.targetID
                $failedJobCount = $failedJobCount + 1
            }
            elseif ($_.endInvocation -eq $null -and $_.Handle.IsCompleted -ne $True -and (((Get-Date) - $_.startInvocation).TotalSeconds -gt 600)) {
                $_.endInvocation = Get-Date
                $Timer = $_.endInvocation - $_.startInvocation
                Write-Host "-------------------------"
                Write-Host "Target: $($_.targetID)"
                Write-Host "Start Time is:"$_.startInvocation
                Write-Host "End Time is:" $_.endInvocation
                Write-Host "Job timed out after $($Timer.Hours):$($Timer.Minutes):$($Timer.Seconds):$($Timer.Milliseconds) HH:MM:SS:mS" -BackgroundColor Dark[RED] -ForegroundColor White
                Write-Host "PowerShell.HadErrors: $($_.PowerShell.HadErrors), Handle.IsCompleted: $($_.Handle.IsCompleted), PowerShell.InvocationStateInfo.State: $($_.PowerShell.InvocationStateInfo.State)"
                $_.PowerShell.Dispose()
                $count = $count - 1
                $timedOutJobTargets = $timedOutJobTargets + $_.targetID
                $timedOutJobCount = $timedOutJobCount + 1
            }
        }
    }

    Write-Host "There was $jobCount targets. $completedJobCount completed successfully. $failedJobCount failed. $timedOutJobCount timed out" -BackgroundColor Blue -ForegroundColor White
    if ($completedJobTargets.count -gt 0) {
        Write-Host "-------------------------"
        Write-Host "Job completed on the following targets" -BackgroundColor Dark[GREEN] -ForegroundColor White
        Write-Output $completedJobTargets
    }
    if ($failedJobTargets.count -gt 0) {
        Write-Host "-------------------------"
        Write-Host "Job failed on the following targets" -BackgroundColor Dark[RED] -ForegroundColor White
        Write-Output $failedJobTargets
    }
    if ($timedOutJobTargets.count -gt 0) {
        Write-Host "-------------------------"
        Write-Host "Job failed on the following targets" -BackgroundColor Dark[RED] -ForegroundColor White
        Write-Output $timedOutJobTargets
    }

    # Clearing the jobs to avoid memory leak
    $jobs.clear()

    $OutputsDirectory = ("$ParentDirectory\Outputs\" -replace ("util\\", ""))
    $OutputFileName = $OutputsDirectory + "DomainComputers" + $FileNamePrefix + $StartTime + ".csv"

    $Header = "ComputerName,Check,Value,Action"
    Set-Content $OutputFileName -Value $Header
    Add-Content -Path $OutputFileName -Value $return
    Write-Host "Output file: $OutputFileName" -BackgroundColor Blue -ForegroundColor White

    $EndTime = Get-Date -Format "yyyy-MM-ddTHH-mm-ss"
    Write-host "End date and time (yyyy-MM-ddTHH-mm-ss): $EndTime"
}