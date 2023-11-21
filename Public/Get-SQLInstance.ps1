<#
  .Synopsis
    Retrive the Microsoft SQL edition and version.
  .Description
    This is a public function used to retrieve the list of all SQL edition and version number and compare if it's older than 2012 or not.
  .Example
    Get-SQLInstance -product $token
  .INPUTS
	$product = String
  .OUTPUTS
    New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"
#>
function Get-SQLInstance {
    [CmdletBinding()]
    param (
        [String]$product
    )

    $check = "MSSQL version"
    Write-Log -Message "___________________________________________________________________"
    Write-Log -Message "New check....."
    Write-Log -Message "$check"
    try {
        if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' -ErrorAction SilentlyContinue) {
            #$listinstances = New-Object -TypeName "System.Collections.ArrayList"
            $installedInstances = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
            foreach ($i in $installedInstances) {
                $instancefullname = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
                $productversion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instancefullname\Setup").Version
                $majorversion = switch -Regex ($productversion) {
                    '^8' { 'SQL2000' }
                    '^9' { 'SQL2005' }
                    '^10.0' { 'SQL2008' }
                    '^10.5' { 'SQL2008 R2' }
                    '^11' { 'SQL2012' }
                    '^12' { 'SQL2014' }
                    '^13' { 'SQL2016' }
                    '^14' { 'SQL2017' }
                    '^15' { 'SQL2019' }
                    '^16' { 'SQL2022' }
                    default { "Unknown" }
                }
                $instance = [PSCustomObject]@{
                    Instance             = $i
                    InstanceNameFullName = $instancefullname;
                    Edition              = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instancefullname\Setup").Edition;
                    ProductVersion       = $productversion;
                    MajorVersion         = $majorversion;
                }
                Write-Log -Message "SQL server information"
                Write-Log -Message $instance
                if ($majorversion -eq 'SQL2017' -Or $majorversion -eq 'SQL2019' -Or $majorversion -eq 'SQL2022') {
                    $value = "[GREEN]"
                    Write-Log -Message "The output of the ""$check"" check is $value"
                    $Action = "No Action required. The host is running $majorversion $($instance.Edition). It's an actively supported MSSQL version by Microsoft."
                    Write-Log -Message $Action
                }
                elseif ($majorversion -eq 'SQL2014') {
                    $value = "[YELLOW]"
                    Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "WARN"
                    $Action = "The host is running $majorversion $($instance.Edition). The support for MSSQL2014 ends on July 2024. Please consider to upgrade. For EOS options https://aws.amazon.com/windows/faq/#eos-m-qa"
                    Write-Log -Message $Action
                }
                else {
                    $value = "[RED]"
                    Write-Log -Message "The output of the ""$check"" check is $value" -LogLevel "ERROR"
                    $Action = "The host is running $majorversion $($instance.Edition). Please consider to upgrade. For EOS options https://aws.amazon.com/windows/faq/#eos-m-qa"
                    Write-Log -Message $Action -LogLevel "ERROR"
                }
                $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
            }
        }
        else {
            $value = "[GREEN]"
            Write-Log -Message "The output of the ""$check"" check is $value"
            $Action = "No Action required. SQL server can not be found."
            Write-Log -Message $Action

            $Output.Add((New-PSObjectResponse -Check "$check" -Status "$value" -Action "$Action"))
        }
    }
    catch {
        Write-Log -Message "Failed..." -LogLevel "ERROR"
        $Action = "An error occurred when running Get-SQLInstance."
        Write-Log -Message $Action -LogLevel "ERROR"
        Write-Log -Message "$($_)" -LogLevel "ERROR"
        $value = "[RED]"
        Write-Log -Message "The check ""$check"" output is $value" -LogLevel "ERROR"
    }
}