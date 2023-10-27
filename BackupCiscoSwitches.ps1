$ConfigFile = '.\CiscoBackup-Config.xml'
$ConfigParams = [xml](get-content $ConfigFile)

# Initialize configuration variables from config xml file
$WorkingDir = $ConfigParams.configuration.backups.folder.value
$SwitchList = $ConfigParams.configuration.backups.switchlist.value
$PlinkExe = $ConfigParams.configuration.backups.plink.value
$SaveHostKey = $ConfigParams.configuration.backups.savehostkeycmd.value
$AuthUser = $ConfigParams.configuration.auth.user.value
$AuthPass = $ConfigParams.configuration.auth.password.value
$VerifyResults = $ConfigParams.configuration.logging.verifyresults.value
$ChangeLog = $ConfigParams.configuration.logging.changelog.value

$Today = (Get-Date).ToString("yy-MM-dd")
$TodaysBackupFolder = $WorkingDir + '\' + $Today

# If the backup directory ($WorkingDir) does not exist, create it
if (-not(Test-Path -Path $WorkingDir -PathType Container)){New-Item -Path $WorkingDir -ItemType Directory}

# Create today's backup sub-folder
if (-not(Test-Path -Path $TodaysBackupFolder -PathType Container)){New-Item -Path $TodaysBackupFolder -ItemType Directory}

# Open the switches.txt file
$SwitchFile = Get-Content $SwitchList

# Process each line (IP) in the switches.txt file 
foreach($Switch in $SwitchFile){
    # Ensure the SSH host key has been saved/trusted
    & $SaveHostKey $PlinkExe $Switch *> $null
    $ConfigFile = $TodaysBackupFolder + '\' + $Switch + '.txt'
    $PlinkArgs = '-ssh -batch -l ' + $AuthUser + ' -pw ' + $AuthPass + ' ' + $Switch + ' show run'
    Write-Host "Saving $Switch to $ConfigFile"
    # Execute the backup command, saving a date stamped configuration backup file
    Start-Process -FilePath $PlinkExe -WorkingDirectory $WorkingDir -ArgumentList $PlinkArgs -PassThru -Wait -RedirectStandardOutput $ConfigFile
}
if($VerifyResults -eq "true"){& .\VerifyCiscoBackups.ps1}
if($ChangeLog -eq "true"){& .\BackupChangeReport.ps1}