$ConfigFile = '.\CiscoBackup-Config.xml'
$ConfigParams = [xml](get-content $ConfigFile)

# Initialize configuration variables from config xml file
$WorkingDir = $ConfigParams.configuration.backups.folder.value
$SwitchList = $ConfigParams.configuration.backups.switchlist.value
$SMTPServer = $ConfigParams.configuration.smtp.fqdn.value
$SMTPPort = $ConfigParams.configuration.smtp.port.value
$FromAddress = $ConfigParams.configuration.smtp.fromemail.value
$ToAddress = $ConfigParams.configuration.smtp.toemail.value

$Today = (Get-Date).ToString("yy-MM-dd")
$TodaysBackupFolder = $WorkingDir + '\' + $Today

# Verify existence of today's backup sub-folder
if (-not(Test-Path -Path $TodaysBackupFolder -PathType Container)){
    Write-Output "Backup has not yet been performed today.  Exiting."
    exit
}

# Open the config file with the list of switch IPs
$SwitchFile = Get-Content $SwitchList
$FailCount = 0
$FailList = ""

# Check each backup file to ensure it looks complete.
foreach($Switch in $SwitchFile){
    $ConfigFile = $TodaysBackupFolder + '\' + $Switch + '.txt'
    $BackupData = Get-Content $ConfigFile -Raw -ErrorAction SilentlyContinue
    if($BackupData.Length -gt 1000 -and $BackupData.Contains("end")){
        Write-Host "GOOD: $ConfigFile" -ForegroundColor Green
    }
    else{
        Write-Host "BAD: $ConfigFile" -ForegroundColor Red
        $FailList = $FailList + "BAD: $ConfigFile" + "`r`n"
        $FailCount++
    }
}
#Write the failure results to a text file in today's backup folder
$FailFile = $TodaysBackupFolder + '\Failures.txt'
$FailList | Out-File $FailFile

# If one or more backup file looks bad or is missing, generate an email digest with the errors
if(($SMTPServer -ne "smtp.hostname.here") -and $FailCount -gt 0){
    Send-MailMessage -From "Cisco Backups $FromAddress" -To $ToAddress -Subject 'Cisco Switch Backup Failures' -Body $FailList -SmtpServer $SMTPServer -Port $SMTPPort
}
