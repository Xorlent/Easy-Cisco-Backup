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
    $ConfigData1 = Get-Content $ConfigFile1 -Raw -ErrorAction SilentlyContinue
    $ConfigFile2 = $YesterdaysBackupFolder + '\' + $Switch + '.txt'
    $ConfigData2 = Get-Content $ConfigFile2 -Raw -ErrorAction SilentlyContinue
    if (-not(Test-Path -Path $ConfigFile2 -PathType Leaf) -or (-not(Test-Path -Path $ConfigFile2 -PathType Leaf)) -or ($ConfigData1.length -lt 1000) -or ($ConfigData2.length -lt 1000)){
        # One of the required backup files does not exist or is incomplete/empty, skip
    }
    else{
        # Purge blank lines,remove execution datestamp and other lines that might cause hash mismatch
        $CleanConfig1 = Get-Content $ConfigFile1 -Encoding UTF8 | Where-Object {$_ -notmatch "!Time: " -and $_ -notmatch "!Command: show running-config" -and $_ -notmatch "Building configuration..."}
        ($CleanConfig1 | Where-Object {-not [string]::IsNullOrWhiteSpace($_)}) | Out-File $ConfigFile1 -Encoding UTF8

        # Purge blank lines, remove execution datestamp and other lines that might cause hash mismatch
        $CleanConfig2 = Get-Content $ConfigFile2 -Encoding UTF8 | Where-Object {$_ -notmatch "!Time: " -and $_ -notmatch "!Command: show running-config" -and $_ -notmatch "Building configuration..."}
        ($CleanConfig2 | Where-Object {-not [string]::IsNullOrWhiteSpace($_)}) | Out-File $ConfigFile2 -Encoding UTF8

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
if(($SMTPServer -ne "smtp.hostname.here") -and $ChangeCount -gt 0){
    $ChangeSubject = 'Cisco Switch Change Log - ' + $Today
    Send-MailMessage -From "Cisco Changes $FromAddress" -To $ToAddress -Subject $ChangeSubject -Body $ChangeList -SmtpServer $SMTPServer -Port $SMTPPort
}
