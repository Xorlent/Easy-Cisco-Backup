REM No need to change any parameters here.
REM The command below is not used for anything more than to tell plink.exe to store the SSH key.
echo y | C:\Scripts\Cisco\plink.exe -ssh swbackup@%1 "exit"
