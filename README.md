# f5-automated-backup-iapp
F5 iApp for automated backups to the local device and to network locations.

## Usage
* You only need the `f5.automated_backup.v3.2.3.tmpl.tcl` file (or whatever the latest version is). Download this template and import it using the F5 BIG-IP GUI.
* The `f5.automated_backup.v3.2.3.scripts.sh` file is on a reference to better understand the scripts used in the `tmpl.tcl` file. In the `tmpl.tcl` file the scripts are converted to a single line by replacing tabs with \t and newlines with \n, which makes them very difficult to understand or troubleshoot.

## Intro
Building on the significant work of Thomas Schockaert (and several other DevCentralites) I enhanced many aspects I needed for my own purposes, updated many things I noticed requested on the forums, and added additional documentation and clarification. As you may see in several of my comments on the original posts, I iterated through several 2.2.x versions and am now releasing v3.0.0. Below is the breakdown!

Also, I have done quite a bit of testing (mostly on v13.1.0.1 lately) and I doubt I've caught everything, especially with all of the changes. Please post any questions or issues in the comments.

Cheers!

Daniel Tavernier (tabernarious)

## Related Posts
* Git Repository for f5-automated-backup-iapp (Daniel Tavernier/tabernarious)
    * https://github.com/tabernarious/f5-automated-backup-iapp
* F5 iApp Automated Backup (Daniel Tavernier/tabernarious)
    * https://devcentral.f5.com/s/articles/f5-iapp-automated-backup-1114
* F5 Automated Backups - The Right Way (Thomas Schockaert)
    * https://devcentral.f5.com/s/articles/f5-automated-backups-the-right-way
* Complete F5 Automated Backup Solution (Thomas Schockaert)
    * https://devcentral.f5.com/s/articles/complete-f5-automated-backup-solution
* Complete F5 Automated Backup Solution #2 (MAG 114141)
    * https://devcentral.f5.com/s/articles/complete-f5-automated-backup-solution-2-957
* Automated Backup Solution
    * https://devcentral.f5.com/questions/automated-backup-solution )
* Automated Backup Solution
    * https://devcentral.f5.com/s/feed/0D51T00006i7Y72SAE
* Generate Config Backup
    * https://devcentral.f5.com/codeshare?sid=285

## Original v1.x.x and v2.x.x Features Kept (copied from an original post)
* It allows you to choose between both UCS or SCF as backup-types. (whilst providing ample warnings about SCF not being a very good restore-option due to the incompleteness in some cases)
* It allows you to provide a passphrase for the UCS archives (the standard GUI also does this, so the iApp should too)
* It allows you to not include the private keys (same thing: standard GUI does it, so the iApp does it too)
* It allows you to set a Backup Schedule for every X minutes/hours/days/weeks/months or a custom selection of days in the week
* It allows you to set the exact time, minute of the hour, day of the week or day of the month when the backup should be performed (depending on the usefulness with regards to the schedule type)
* It allows you to transfer the backup files to external devices using 4 different protocols, next to providing local storage on the device itself
  * SCP (username/private key without password)
  * SFTP (username/private key without password)
  * FTP (username/password)
  * SMB (now using TMOS v12.x.x compatible 'mount -t cifs', with username/password)
* Local Storage (/var/local/ucs or /var/local/scf)
* It stores all passwords and private keys in a secure fashion: encrypted by the master key of the unit (f5mku), rendering it safe to store the backups, including the credentials off-box
* It has a configurable automatic pruning function for the Local Storage option, so the disk doesn't fill up (i.e. keep last X backup files)
* It allows you to configure the filename using the date/time wildcards from the tcl [clock] command, as well as providing a variable to include the hostname
* It requires only the WebGUI to establish the configuration you desire
* It allows you to disable the processes for automated backup, without you having to remove the Application Service or losing any previously entered settings
* For the external shellscripts it automatically generates, the credentials are stored in encrypted form (using the master key)
* It allows you to no longer be required to make modifications on the linux command line to get your automated backups running after an RMA or restore operation
* It cleans up after itself, which means there are no extraneous shellscripts or status files lingering around after the scripts execute

## New v3.0.0 Features
* Supports multiple instances! (Deploy multiple copies of the iApp to save backups to different places or perhaps to keep daily backups locally and send weekly backups to a network drive.)
* Fully ConfigSync compatible! (Encrypted values now in $script instead of local file.)
* Long passwords supported! (Using "-A" with openssl which reads/writes base64 encoded strings as a single line.)
* Added $script error checking for all remote backup types! (Using 'catch' to prevent tcl errors when $script aborts.)
* Backup files are cleaned up after any $script errors due to new error checking.
* Added logging! (Run logs sent to '/var/log/ltm' via logger command which is compatible with BIG-IP Remote Logging configuration (syslog). Run logs AND errors sent to '/var/tmp/scriptd.out'. Errors may include plain-text passwords which should not be in /var/log/ltm or syslog.)
* Added custom cipher option for SCP! (In case BIG-IP and the destination server are not cipher-compatible out of the box.)
* Added StrictHostKeyChecking=no option. (This is insecure and should only be used for testing--lots of warnings.)
* Combined SCP and SFTP because they are both using SCP to perform the remote copy. (Easier to maintain!)

# Known Issues, Request, and Other Notes
* F5 TMOS 11.4.1 - 11.5.3 have not been tested (they may work).
* Using a 4096 bit private key for SFTP/SCP results in error "Unable to decrypt text of length (4338) which exceeds the max of (4048)" which may be an iApp bug/limitation of fields designated as type "password". (github Issue #12)
    * Could add a second field to accept part of the key, then combine the values.
    * Could use something like this to pull the key from the F5 filestore (though this would result in the key being accessible via the GUI). This might even work with encrypted keys: grep "sys file ssl-key /Common/KEY-NAME.key" -A1 /config/bigip.conf |tail -1 |sed 's/    cache-path //'
* Reported issues with FTP (sending archive before finished or corrupting?) (github Issue #15)
* Reported issues with SMB from v12.x to Windows Server 2012 (github Issue #17)
* Add automatic pruning for FTP and SFTP/SCP.
    * Use "dir -t" or "nlist -t" commands to pull file list...