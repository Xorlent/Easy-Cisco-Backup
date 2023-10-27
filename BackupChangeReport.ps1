$WorkingDir = 'C:\Scripts\Cisco\Backups'
$SwitchList = 'C:\Scripts\Cisco\switches.txt'

# Update this value for your private SMTP relay
$SMTPServer = 'your.smtp.server.name'
$MailTo = '<youremail@here.com>'

$Today = (Get-Date).ToString("yy-MM-dd")
$Yesterday = (Get-Date).AddDays(-1).ToString("yy-MM-dd")
$TodaysBackupFolder = $WorkingDir + '\' + $Today
$YesterdaysBackupFolder = $WorkingDir + '\' + $Yesterday

# Verify existence of today's backup sub-folder
if (-not(Test-Path -Path $TodaysBackupFolder -PathType Container)){
    Write-Output "Backup has not yet been performed today.  Exiting."
    exit
}

# Verify existence of yesterday's backup sub-folder
if (-not(Test-Path -Path $YesterdaysBackupFolder -PathType Container)){
    Write-Output "Backup was not performed yesterday.  Exiting."
    exit
}

$SwitchFile = Get-Content $SwitchList
$ChangeCount = 0
$ChangeList = ""

foreach($Switch in $SwitchFile){
    $ConfigFile1 = $TodaysBackupFolder + '\' + $Switch + '.txt'
    $ConfigFile2 = $YesterdaysBackupFolder + '\' + $Switch + '.txt'
    if (-not(Test-Path -Path $ConfigFile2 -PathType Leaf)){
        # File does not exist for yesterday's backup, skip
    }
    else{
        # Purge blank lines and remove Nexus OS command execution datestamp
        $CleanConfig1 = Get-Content $ConfigFile1 | ? { $_ }
        $CleanConfig1 | Out-File $ConfigFile1

        foreach($configLine1 in $CleanConfig1){
            if($configLine1.contains("!Time: ")){
                $CleanConfig1 -replace $configLine1, '' | Out-File $ConfigFile1
            }
        }

        # Purge blank lines and remove Nexus OS command execution datestamp
        $CleanConfig2 = Get-Content $ConfigFile2 | ? { $_ }
        $CleanConfig2 | Out-File $ConfigFile2

        foreach($configLine2 in $CleanConfig2){
            if($configLine2.contains("!Time: ")){
                $CleanConfig2 -replace $configLine2, '' | Out-File $ConfigFile2
            }
        }

        # Now generate file hash and compare yesterday's backup with today
        $CurrentHash = Get-FileHash $ConfigFile1 -Algorithm SHA256 | Select-Object -ExpandProperty Hash
        $LastHash = Get-FileHash $ConfigFile2 -Algorithm SHA256 | Select-Object -ExpandProperty Hash

        # If the hashes do not match, create a log entry
        if($CurrentHash -eq $LastHash){
            Write-Host "NO CHANGE: $ConfigFile1" -ForegroundColor Green
        }
        else{
            Write-Host "CHANGED: $ConfigFile1" -ForegroundColor Red
            $ChangeList = $ChangeList + "CHANGED: $ConfigFile1" + "`r`n"
            $ChangeCount++
        }
    }
}
#Write the change results to a text file in today's backup folder
$ChangeFile = $TodaysBackupFolder + '\ChangeLog.txt'
$ChangeList | Out-File $ChangeFile

# If one or more configurations changed since yesterday's backup, generate an email digest with the list
if($ChangeCount -gt 0){
    $ChangeSubject = 'Cisco Switch Change Log - ' + $Today
    Send-MailMessage -From 'Cisco Changes <NOREPLY@noreply.email>' -To $MailTo -Subject $ChangeSubject -Body $ChangeList -SmtpServer $SMTPServer
}