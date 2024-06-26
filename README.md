# Easy-Cisco-Backup
The simplest bulk Cisco IOS backup/configuration change management tool, with failure and config change email notifications!

### Background
In search of a simple way to schedule regular backups of Cisco switch configurations, I found many solutions built with PowerShell add-on modules, but I wanted something simple and more portable.  Beyond a Windows machine with PowerShell, this tool needs only one thing: plink.exe, a free, standalone executable utility by the creator of PuTTY.  No installs, no paid PowerShell modules, no TFTP server to set up and secure.

### Prerequisites
  - SSH support only.  If you have Telnet enabled on your switches, please address that.

### Installation
  - Download the latest Easy-Cisco-Backup release.
  - Right-click the downloaded ZIP, select Properties, click Unblock" and Ok.
  - Extract the ZIP to a secure folder of your choice.  I recommend C:\Scripts\Cisco\ -- the default configuration file entries are set to this path.
    - Only admins and the service account you plan to use if scheduling switch backups should have access to this location.
  - Read and understand the PuTTY/plink.exe license and usage restrictions, found here [https://www.chiark.greenend.org.uk/~sgtatham/putty/](https://www.chiark.greenend.org.uk/~sgtatham/putty/)

### Usage
  - Edit switches.txt so it includes the management IP of each switch to back up, one per line.
  - Edit CiscoBackup-Config.xml
    - Set file paths as appropriate
    - Set authentication credentials for a switch user with "show run" permissions
    - Configure SMTP server and from/to email address settings if email notifications are desired
  - Open a PowerShell window.
  - Run BackupCiscoSwitches.ps1
    - Note, this script is intended to be run **once per day**
    - Create a daily scheduled task to run this script for hassle-free config backup/change management
  - Thank Simon Tatham!

> [!IMPORTANT]
> For the sake of convenience, the script will auto-trust/save the SSH key presented by the connected device.  
  > This could allow for a device to assume the IP of a switch and steal authentication credentials.
  > If you would rather not have the tool auto-trust SSH keys, just comment out the line below the following comment within BackupCiscoSwitches.ps1:  
    ```# Ensure the SSH host key has been saved/trusted```
