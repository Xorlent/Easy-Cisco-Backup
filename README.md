# Easy-Cisco-Backup
The simplest bulk Cisco IOS backup/change management tool  

### Background
In search of a simple way to schedule regular backups of Cisco switch configurations, I found many solutions built with PowerShell add-on modules, but I wanted something simple and more portable.  Beyond a Windows machine with PowerShell, this tool needs only one thing: plink.exe, a free, standalone executable utility by the creator of PuTTY.  No paid PowerShell modules, no TFTP server to set up and secure.

### Prerequisites
  - SSH only.  If you have Telnet enabled on your switches, please address that.

### Installation
  - Download the latest Easy-Cisco-Backup release.
  - Right-click the downloaded ZIP, select Properties, click Unblock" and Ok.
  - Extract the ZIP to a secure folder of your choice.  I recommend C:\Scripts\Cisco\ -- the script is configured to use this path.
    - Only admins and the service account you plan to use if scheduling switch backups should have access to this location.
  - Grab the latest plink.exe utility here: [https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html](https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe)
  - Right-click plink.exe, select Properties, click Unblock" and Ok.
  - Move plink.exe to the location where you extracted Easy-Cisco-Backup.

### Usage
  - Edit switches.txt so it includes the management IP of each switch to back up, one per line.
  - Edit BackupCiscoSwitches.ps1
    - Adjust the file paths as appropriate at the top of the file.
    - Set $Authuser and $Authpass to the credentials for a switch user with "show run" permissions.
  - Open a PowerShell window.
  - Run BackupCiscoSwitches.ps1
  - Thank Simon Tatham!
