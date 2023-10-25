$WorkingDir = 'C:\Scripts\Cisco\Backups'
$SwitchList = 'C:\Scripts\Cisco\switches.txt'
$Today = (Get-Date).ToString("yy-MM-dd")
$TodaysBackupFolder = $WorkingDir + '\' + $Today

# Update this value for your private SMTP relay
$SMTPServer = 'your.smtp.server.name'
$MailTo = '<youremail@here.com>'

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
        Write-Host "GOOD $ConfigFile" -ForegroundColor Green
    }
    else{
        Write-Host "BAD $ConfigFile" -ForegroundColor Red
        $FailList = $FailList + "BAD $ConfigFile" + "`r`n"
        $FailCount++
    }
}

# If one or more backup file looks bad or is missing, generate an email digest with the errors
if($FailCount -gt 0){
    Send-MailMessage -From 'Cisco Backups <NOREPLY@noreply.email>' -To $MailTo -Subject 'Cisco Switch Backup Failures' -Body $FailList -SmtpServer $SMTPServer
}
