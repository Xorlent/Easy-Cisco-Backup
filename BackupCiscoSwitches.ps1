$WorkingDir = 'C:\Scripts\Cisco\Backups'
$SwitchList = 'C:\Scripts\Cisco\switches.txt'
$PlinkExe = 'C:\Scripts\Cisco\plink.exe'
$Today = (Get-Date).ToString("yy-MM-dd") + '.txt'
$SaveHostKey = 'C:\Scripts\Cisco\savehostkey.cmd'

$AuthUser = 'backupuser'
$AuthPass = 'backuppassword'

$SwitchFile = Get-Content $SwitchList

foreach($Switch in $SwitchFile){
    & $SaveHostKey $Switch *> $null
    $ConfigFile = $WorkingDir + '\' + $Switch + '_' + $Today
    $PlinkArgs = '-ssh -batch -l ' + $AuthUser + ' -pw ' + $AuthPass + ' ' + $Switch + ' show run'
    Write-Host "Saving $Switch to $ConfigFile"
    Start-Process -FilePath $PlinkExe -WorkingDirectory $WorkingDir -ArgumentList $PlinkArgs -PassThru -Wait -RedirectStandardOutput $ConfigFile
}