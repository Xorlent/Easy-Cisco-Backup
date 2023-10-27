$WorkingDir = 'C:\Scripts\Cisco\Backups'
$SwitchList = 'C:\Scripts\Cisco\switches.txt'
$PlinkExe = 'C:\Scripts\Cisco\plink.exe'
$Today = (Get-Date).ToString("yy-MM-dd")
$TodaysBackupFolder = $WorkingDir + '\' + $Today
$SaveHostKey = 'C:\Scripts\Cisco\savehostkey.cmd'

# Set to $true if you want email reports of failed backups (configure this in VerifyCiscoBackups.ps1)
$VerifyResults = $false
# Set to $true if you want config change email reports and a ChangeLog.txt file dropped in each day's backup folder (configure this in BackupChangeReport.ps1)
$ChangeLog = $false

# These will be saved as plaintext username and password!
# 1. Ensure this is an account with minimal, read-only switch access
# 2. Ensure folder permissions restrict access to this file
$AuthUser = 'backupuser'
$AuthPass = 'backuppassword'

# If the backup directory ($WorkingDir) does not exist, create it
if (-not(Test-Path -Path $WorkingDir -PathType Container)){New-Item -Path $WorkingDir -ItemType Directory}

# Create today's backup sub-folder
if (-not(Test-Path -Path $TodaysBackupFolder -PathType Container)){New-Item -Path $TodaysBackupFolder -ItemType Directory}

# Open the switches.txt file
$SwitchFile = Get-Content $SwitchList

# Process each line (IP) in the switches.txt file 
foreach($Switch in $SwitchFile){
    # Ensure the SSH host key has been saved/trusted
    & $SaveHostKey $Switch *> $null
    $ConfigFile = $TodaysBackupFolder + '\' + $Switch + '.txt'
    $PlinkArgs = '-ssh -batch -l ' + $AuthUser + ' -pw ' + $AuthPass + ' ' + $Switch + ' show run'
    Write-Host "Saving $Switch to $ConfigFile"
    # Execute the backup command, saving a date stamped configuration backup file
    Start-Process -FilePath $PlinkExe -WorkingDirectory $WorkingDir -ArgumentList $PlinkArgs -PassThru -Wait -RedirectStandardOutput $ConfigFile
}
if($VerifyResults){& .\VerifyCiscoBackups.ps1}
if($ChangeLog){& .\BackupChangeReport.ps1}
