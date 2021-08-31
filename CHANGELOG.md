# CHANGELOG

## v3.2.4 (20210831)
* Added an option to set a custom local pruning interval. This used to be fixed at 60 seconds.
* Added an option to set a custom directory to save archives.
* Fixed SSH options for SCP.

## v3.2.3 (20210327)
* Fixed a bug (typo) when using SCP, which resulted in 'script did not successfully complete: (can't read "::destination_parameters__sftp_sshprivatekey": no such variable' etc. This was related to adding support for keys with "BEGIN OPENSSH PRIVATE KEY" headers.

## v3.2.2 (20210312)
* Added ability to set "ssh options" for SCP and SFTP (e.g. KexAlgorithm)
* Added support for keys with "BEGIN OPENSSH PRIVATE KEY" headers.

## v3.2.1 (20201210)
* Merged v3.1.11 and v3.2.0 for explicit SFTP support (separate from SCP).
* Tweaked the SCP and SFTP upload directory handling; detailed instructions are in the iApp.
* Tested on 13.1.3.4 and 14.1.3 and 16.0.1

## v3.1.11 (20201210)
* Better handling of UCS passphrases, and notes about characters to avoid.
    * I successfully tested this exact passphrase in the 13.1.3.4 CLI (surrounded with single quote) and GUI (as-is): `~!@#$%^*()aB1-_=+[{]}:./?
    * I successfully tested this exact passphrase in 14.1.3 (square-braces and curly-braces would not work): `~!@#$%^*()aB1-_=+:./?
    * Though there may be situations these could work, avoid these characters (separated by spaces): " ' & | ; < > \ [ ] { } ,
* Moved changelog and notes from the template to CHANGELOG.md and README.md.
* Replaced all tabs (\t) with four spaces.

## v3.1.10 (20201209)
* Added SMB Version and SMB Security options to support v14+ and newer versions of Microsoft Windows and Windows Server.
* Tested SMB/CIFS on 13.1.3.4 and 14.1.3 against Windows Server 2019 using "2.0" and "ntlmsspi"

## v3.2.0-fork (20190620)
Developed on a fork of v3.1.9 by damnski (darryl.wisneski@yale.edu)
* Add support for SFTP (separately from SCP) - use-case is AWS Transfers (SFTP) that only supports the SFTP protocol - tested on 14.1.0.1

## v3.1.9 (20181120)
* Fixed comment in SMB/CIFS script which was breaking everything due hash escape and a variable reference--I must not have actually tested after I added the comment :(

## v3.1.8 (20181115)
* Scripts for SMB/CIFS and FTP will again be deleted after each backup. (This was in place as of v3.1.6 but was turned off for debugging in v3.1.7 and was not put back.)

## v3.1.7 (20181115)
* Now supporting many special characters for passwords (without manually escaping with backslashes). (github Issue #3 and #16)
* SMB/CIFS does NOT support comma, single-quote, and double-quote. I successfully tested this exact password to Windows Server 2012: `~!@#$%^&*()aB1-_=+[{]}\|;:<.>/?
* FTP should support all characters (based on limited testing). I successfully tested this exact password to a Linux FTP server: `~!@#$%^&*()aB1-_=+[{]}\|;:,"<.>'/?

## v3.1.6 (20181114)
* Fixed lots of issues with SCF files for SFTP/SCP, FTP, and SMB/CIFS (mainly, tar files were not being copied and were not being cleaned up locally). (github Issue #18)
* Added logging clarification that when using SCF archives a .tar file is also generated and saved/uploaded.
* Added debug logging for the SMB/CIFS script.
* Now including on github an expanded form of the upload scripts for better understanding (see "f5.automated_backup.v3.1.6.scripts.sh" etc.).

## v3.1.5 (20181112)
* Updated KNOWN ISSUES section (below)
* Fixed SCF passphase issue (v11 "tmsh save sys config file NAME" works and applies no passphase ("no-passphase" flag does not exist); v12+ requires use of "no-passphrase" or "passphrase PHRASE"). (github Issue #18)
* Reordered filename_format list; default remains ${host}_%Y%m%d_%H%M%S
* Tested on 11.6.3.3, 12.1.3.7, and 13.1.1.2

## v3.1.4 (20180604)
* Fixed can't read "::destination_parameters__pruning_mode" errors using [info exists ...].
* Removed LTM from "Required Modules" list; now no modules are required.
* SMB/CIFS now directly mounts the target directory instead of the mount point. This allows administrators to deny access to intermediate directories.
* Set the pruning_keep_amount default to 3 (previously no default existed).

## v3.1.3 (20180511)
* Added pruning option to only delete Archives created by this iApp using a Unique Suffix.
* Muted ls errors on first-run of pruning script with Unique Suffix.
* Fixed SCF pruning (previously only built for ucs file extension); also cleans up scf.tar files.
* Fixed SCF generation with "no-passphrase" without which produces errors in 13.1.0.5 (not tested in any other versions).
* Added pruning option for SMB/CIFS.

## v3.1.2 (20180510)
* Allowed Destination to be an IP or hostname, and added clarifying notes.
* Added Source IP notes to help users understand and manipulate the source IP used by BIG-IP.
* Added path notes for SFTP/SCP and FTP.
* Fixed ssh-keygen example syntax and added note about optional ssh-copy-id command.
* Clarified SMB/CIFS special character escaping for password--not all non-alphanumeric characters need to be escaped.

## v3.1.1 (20180331)
* Removed TCL double substitution warnings
* Fixed duplication of UCS file extension when uploading to FTP

## v3.1.0 (20180201)
* Removed "app-service none" from iCall objects. The iCall objects are now created as part of the Application Service (iApp) and are properly cleaned up if the iApp is redeployed or deleted.
* Reasonably tested on 11.5.4 HF2 (SMB worked fine using "mount -t cifs") and altered requires-bigip-version-min to match.
* Fixing error regarding "script did not successfully complete: (can't read "::destination_parameters__protocol_enable": no such variable" by encompassing most of the "implementation" in a block that first checks $::backup_schedule__frequency_select for "Disable".
* Added default value to "filename format".
* Changed UCS default value for $backup_file_name_extension to ".ucs" and added $fname_noext.
* Removed old SFTP sections and references (now handled through SCP/SFTP).
* Adjusted logging: added "sleep 1" to ensure proper logging; added $backup_directory to log message.
* Adjusted some help messages.

## v3.0.0 (20180124)
* Eliminated ConfigSync issues and removed ConfigSync notes section. (Encrypted values now in $script instead of local file.)
* Passwords now have no length limits. (Using "-A" with openssl which reads/writes base64 encoded strings as a single line.)
* Added $script error checking for all remote backup types. (Using 'catch' to prevent tcl errors when $script aborts.)
* Backup files are cleaned up after $script error due to new error checking.
* Added logging. (Run logs sent to '/var/log/ltm' via logger command which is compatible with BIG-IP Remote Logging configuration (syslog). Run logs AND errors sent to '/var/tmp/scriptd.out'. Errors may include plain-text passwords which should not be in /var/log/ltm or syslog.)
* Added custom cipher option for SCP.
* Added StrictHostKeyChecking=no option.
* Combined SCP and SFTP because they are both using SCP to perform the remote copy.

## v2.2.5b4+ (20180118)
* Refining changes to SMB/CIFS and replicating to other remote copy types. (Developed by Daniel Tavernier/tabernarious)

## v2.2.5b4 (20180118)
* Moved encrypted values for SMB/CIFS to shell script which eliminates ConfigSync issues. Fixed long-password issue by using "-A" with openssl so that base64 encoded strings are written and read as a single line. (Developed by Daniel Tavernier/tabernarious)

## v2.2.5a (20180117)
* Added items to FUTURE list.

## v2.2.5 (20171228)
* Added notes about special characters in passwords. Added Deployment Information and ConfigSync sections. (Developed by Daniel Tavernier/tabernarious)

## v2.2.4a (20171215)
* Added items to FUTURE list.

## v2.2.4 (20171214)
From code posted by Roy van Dongen
* Added fix to force FTP to use binary upload.

## v2.2.3 (20171214)
* Set many fields to "required" and set reasonable default values to prevent loading/configuration errors. Expanded help regarding private keys.

## v2.2.2 (20171214)
* Added "/" to "mount -t cifs" command and clarified/expanded help for SMB (CIFS) Destination Parameters.

## v2.2.1 (20171214)
* Allowed multiple instances of iApp by leveraging $tmsh::app_name to create unique object names.

## v2.1.1 (20160916)
Developed/posted by MAG
* Retooled SMB upload from smbclient to "mount -t cifs" (v12.1+ compatibility).

## ~v2.0 (20140312)
Developed/posted by Thomas Schockaert
* Initially posted releases from what I gathered perusing DevCentral.
* v11.4.0-11.6.x? compatibility.
