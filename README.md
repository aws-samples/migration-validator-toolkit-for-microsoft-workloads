# Migration Validator Toolkit for microsoft workloads

The **Migration Validator Toolkit** PowerShell module is designed to perform multiple checks and validations for common Microsoft workload-related tasks in order to accelerate the discovery and migration of workloads to AWS. For example, customers might have an instance that has multiple disks attached or uses many IP addresses. In this case, the scripts will check and provide recommendations based on the findings to avoid any misconfiguration before, during, and after the migration.

## Sample Output

```powershell
PS C:\migration-validator-toolkit-for-microsoft-workloads> Import-Module .\MigrationValidatorToolkit.psm1;Invoke-MigrationValidatorToolkit
[2023-11-21T16:42:34.4780371-05:00] [INFO] Checking prerequisites before executing the Migration Validator Toolkit...
[2023-11-21T16:42:34.4907832-05:00] [INFO] Code is running as administrator...
[2023-11-21T16:42:34.4917831-05:00] [INFO] Server Version 10.0 is compatible with this module...
[2023-11-21T16:42:34.4927829-05:00] [INFO] The PowerShell Version 5 is compatible with this module - Executing script
[2023-11-21T16:42:34.5051938-05:00] [INFO] Logs directory exists - C:\migration-validator-toolkit-for-microsoft-workloads\logs\
[2023-11-21T16:42:34.6886577-05:00] [INFO] Logs available at C:\migration-validator-toolkit-for-microsoft-workloads\logs\SEA-1801485456_MigrationValidatorToolkit_2023-11-21T16-42-34.log
[2023-11-21T16:42:34.6921722-05:00] [INFO] Outputs available at C:\migration-validator-toolkit-for-microsoft-workloads\Outputs\SEA-1801485456_MigrationValidatorToolkit_2023-11-21T16-42-34.txt
[2023-11-21T16:42:34.6941588-05:00] [INFO] Running all the tests can take a few minutes...
    __  ____                  __  _                _    __      ___     __      __                ______            ____   _ __
   /  |/  (_)___ __________ _/ /_(_)___  ____     | |  / /___ _/ (_)___/ /___ _/ /_____  _____   /_  __/___  ____  / / /__(_) /_
  / /|_/ / / __  / ___/ __  /   / / __ \/ __ \    | | / / __  / / / __  / __  / __/ __ \/ ___/    / / / __ \/ __ \/ / //_/ / __/
 / /  / / / /_/ / /  / /_/ / /_/ / /_/ / / / /    | |/ / /_/ / / / /_/ / /_/ / /_/ /_/ / /       / / / /_/ / /_/ / / ,< / / /_
/_/  /_/_/\__, /_/   \__,_/\__/_/\____/_/ /_/     |___/\__,_/_/_/\__,_/\__,_/\__/\____/_/       /_/  \____/\____/_/_/|_/_/\__/
         /____/

Check                   Value    Action
-----                   -----    ------
Windows version         [GREEN]  No action required. The host is running Microsoft Windows 11 Enterprise. It''s supported to host in AWS and an actively supported OS by Microsoft.
Authentication method   [YELLOW] The host is part of a domain. After migration, if there is connectivity to a Domain Controller, use a domain/local user to RDP. If not, use a local user.
Root Disk Free Space    [GREEN]  No action required. There is 206.514 GB free space on C Drive.
Disk Count              [GREEN]  No action required. The number of disks supported by all EC2 instances.
Disk size               [GREEN]  No action required. The size of all disks are supported by all EC2 instances.
DHCP service            [GREEN]  No action required. DHCP service is enabled.
IP count\type           [YELLOW] There are 3 IP addresses on the host and 1 assigned manually. Make sure to select the right EC2 instance - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI. and
                                 the ENI that is attached to the ec2 instance match the IP address of the host - https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html.
Network interface count [GREEN]  No action required. The number of physical network interfaces supported by all EC2 instances.
Boot Mode               [YELLOW] The Boot Disk is Basic, and the Boot Mode is UEFI. We recommend selecting the UEFI Boot Mode option to keep the same settings as the source machine
                                 https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ami-boot.html
AD Domain Controller    [GREEN]  No action required. The active directory role can not be found.
File Server             [YELLOW] File server roles are not installed but there is 0.426 GB shared - Please check Migrating file servers
                                 https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-file-servers-workloads.html.
IIS                     [GREEN]  No action required. IIS server role can not be found.
MSSQL version           [GREEN]  No action required. SQL server can not be found.
```
### Prerequisites

* PowerShell 4.0
* Local administrator account
* Microsoft Windows Server 2012R2 and above

## Usage

### Target multi domain joined computers

#### Switches
- `s3BucketName`: Optional. The name of the S3bucket If you are hosting the module in S3. By default, the module will be downloaded from the GitHub repository.
- `s3KeyPrefix` : Optional. The name of the S3 prefix of the object If you are hosting the module in S3. By default, the module will be downloaded from the GitHub repository.

Use any computer within the domain using a domain user that has an administrator access to target computers. Download source code as ZIP file and extract. Run as administrator in PowerShell.

```powershell
Import-Module .\MigrationValidatorToolkit.psm1;Invoke-DomainComputers
Import-Module .\MigrationValidatorToolkit.psm1;Invoke-DomainComputers -s3BucketName "S3Bucket" -s3KeyPrefix "S3Prefix"
```

### Single use

#### Switches
- `List`: Optional. The output will be generated using the [Format-List](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-list?view=powershell-7.3) method. By default, the module will use [Format-Table](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.3).
- `GridView` : Optional. The output will be generated using the [Out-GridView](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-gridview?view=powershell-7.3) method. By default, the module will use [Format-Table](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.3).
- `csv` : Optional. The output will be generated using the [ConvertTo-Csv](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-csv?view=powershell-7.3) method. By default, the module will use [Format-Table](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/format-table?view=powershell-7.3).


Download source code as ZIP file and extract. Run the one of the followings as administrator in PowerShell.

```powershell
Import-Module .\MigrationValidatorToolkit.psm1;Invoke-MigrationValidatorToolkit
Import-Module .\MigrationValidatorToolkit.psm1;Invoke-MigrationValidatorToolkit -List
Import-Module .\MigrationValidatorToolkit.psm1;Invoke-MigrationValidatorToolkit -GridView
Import-Module .\MigrationValidatorToolkit.psm1;Invoke-MigrationValidatorToolkit -csv
```

Or run the following sample code as an administrator in PowerShell to download the source code as ZIP file, extract and execute the toolkit.

```powershell
#MigrationValidatorToolkit
$uri = 'https://github.com/aws-samples/migration-validator-toolkit-for-microsoft-workloads/archive/refs/heads/main.zip'
$destination = (Get-Location).Path
if ((Test-Path -Path "$destination\MigrationValidatorToolkit.zip" -PathType Leaf) -or (Test-Path -Path "$destination\MigrationValidatorToolkit")) {
    write-host "File $destination\MigrationValidatorToolkit.zip or folder $destination\MigrationValidatorToolkit found, exiting"
}else {
    Write-host "Enable TLS 1.2 for this PowerShell session only."
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $webClient = New-Object System.Net.WebClient
    Write-host "Downloading MigrationValidatorToolkit.zip"
    $webClient.DownloadFile($uri, "$destination\MigrationValidatorToolkit.zip")
    Write-host "MigrationValidatorToolkit.zip download successfully"
    Add-Type -Assembly "system.io.compression.filesystem"
    [System.IO.Compression.ZipFile]::ExtractToDirectory("$destination\MigrationValidatorToolkit.zip","$destination\MigrationValidatorToolkit")
    Write-host "Extracting MigrationValidatorToolkit.zip complete successfully"
    Import-Module "$destination\MigrationValidatorToolkit\migration-validator-toolkit-for-microsoft-workloads-main\MigrationValidatorToolkit.psm1"; Invoke-MigrationValidatorToolkit
}
```

## Checks
| Check | Description | Function name | Input Parameter
| --- | --- | --- | --- |
| Windows version | Check whether the Windows Operating System is 2012 R2 or older. For 2012 R2 or older, consider upgrading. Review [AWS End of Support](https://aws.amazon.com/windows/faq/#eos-m-qa) options. |  Get-WindowsVersion | NA
| Authentication method | Check whether the host is part of a domain or not. This is a reminder that you would need a credential (domain or local) to RDP to the server after migration. | Get-AuthenticationMethod | ProductType
| Root Disk Free Space | Check if there is at least 2GB of free space on the root volume. The space will be used to install the EC2 drivers and other tools like [EC2Launch](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch-v2.html). | Get-RootDiskSpace | NA
| Disk Count | Count the number of disks used by the host. Check if the host is compliant with [instance volume limits](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/volume_limits.html). | Get-DiskCount | NA
| Disk size | Check if there is any disk larger than 64TiB. Check if the host within [EBS volume limits](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/volume_constraints.html). | Get-DiskSize | NA
| DHCP service | Check if DHCP service is enabled or not. | Get-DhcpStatus | NA
| IP count\type | Count the number of IP’s assigned to the host and indicate if the the IP is static or dynamic. If there are multiple IPs, the check will provide guidance on [IP addresses per network interface per instance type page](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI). | Get-IPv4Count | NA
| Network interface count | Count the number of physical interfaces used by the host. If there are multiple network interfaces, the check will point to [IP addresses per network interface per instance type page](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/using-eni.html#AvailableIpPerENI). | Get-NetworkInterfaceCount | NA
| Boot Mode | Check the boot mode of the source machine (Legacy BIOS or UEFI). Make sure you select the correct [boot mode](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ami-boot.html). | Get-BootMode | NA
| AD Domain Controller | Check if the [AD-Domain-Services](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview) role is installed and if the host is a Domain Controller. If it is, consider migration options for [Active Directory](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-active-directory-workloads.html).| Get-DomainControllerStatus | ProductType
| File Server  | Check if the File server role is installed, and indicate the total folder size for each shared folder. If it is, consider migration options for [file servers](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-file-servers-workloads.html). | Get-FileServerStatus | ProductType
| IIS | Check if Internet Information Services (IIS) role is installed. If it is, consider migration options for [.NET applications](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-microsoft-workloads-aws/migrating-net-workloads.html). | Get-IISStatus | ProductType
| MSSQL version | Check whether SQL is installed and it's version. For SQL 2014 or older, consider upgrading. Review [AWS End of Support](https://aws.amazon.com/windows/faq/#eos-m-qa) options. | Get-SQLInstance | ProductType

## Troubleshooting
| Log Location | Description |
| --- | --- |
| %MigrationValidatorToolkit%\logs | The log file will contain the outputs from each function and highlight any errors when it was executed. You can use this log to investigate any issues during the execution of each function. |

## Built With

PowerShell 4.0

## Authors

* Ali Alzand

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This project is licensed under the Apache-2.0 License.