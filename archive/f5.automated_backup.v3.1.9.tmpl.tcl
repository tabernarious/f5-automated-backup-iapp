# iApp VERSIONS (From what I gathered perusing DevCentral)
# ~v2.0  - 20140312 - Initially posted releases (v11.4.0-11.6.x? compatibility). (Developed/posted by Thomas Schockaert)
# v2.1.1 - 20160916 - Retooled SMB upload from smbclient to "mount -t cifs" (v12.1+ compatibility). (Developed/posted by MAG)
# v2.2.1 - 20171214 - Allowed multiple instances of iApp by leveraging $tmsh::app_name to create unique object names. (Developed by Daniel Tavernier/tabernarious)
# v2.2.2 - 20171214 - Added "/" to "mount -t cifs" command and clarified/expanded help for SMB (CIFS) Destination Parameters. (Developed by Daniel Tavernier/tabernarious)
# v2.2.3 - 20171214 - Set many fields to "required" and set reasonable default values to prevent loading/configuration errors. Expanded help regarding private keys. (Developed by Daniel Tavernier/tabernarious)
# v2.2.4 - 20171214 - Added fix to force FTP to use binary upload. (Copied code posted by Roy van Dongen, posted by Daniel Tavernier/tabernarious)
# v2.2.4a - 20171215 - Added items to FUTURE list.
# v2.2.5 - 20171228 - Added notes about special characters in passwords. Added Deployment Information and ConfigSync sections. (Developed by Daniel Tavernier/tabernarious)
# v2.2.5a - 20180117 - Added items to FUTURE list.
# v2.2.5b4 - 20180118 - Moved encrypted values for SMB/CIFS to shell script which eliminates ConfigSync issues. Fixed long-password issue by using "-A" with openssl so that base64 encoded strings are written and read as a single line. (Developed by Daniel Tavernier/tabernarious)
# v2.2.5b4+ - 20180118 - Refining changes to SMB/CIFS and replicating to other remote copy types. (Developed by Daniel Tavernier/tabernarious)
# v3.0.0 - 20180124 - (Developed by Daniel Tavernier/tabernarious)
#                   - Eliminated ConfigSync issues and removed ConfigSync notes section. (Encrypted values now in $script instead of local file.)
#                   - Passwords now have no length limits. (Using "-A" with openssl which reads/writes base64 encoded strings as a single line.)
#                   - Added $script error checking for all remote backup types. (Using 'catch' to prevent tcl errors when $script aborts.)
#                   - Backup files are cleaned up after $script error due to new error checking.
#                   - Added logging. (Run logs sent to '/var/log/ltm' via logger command which is compatible with BIG-IP Remote Logging configuration (syslog). Run logs AND errors sent to '/var/tmp/scriptd.out'. Errors may include plain-text passwords which should not be in /var/log/ltm or syslog.)
#                   - Added custom cipher option for SCP.
#                   - Added StrictHostKeyChecking=no option.
#                   - Combined SCP and SFTP because they are both using SCP to perform the remote copy.
# v3.1.0 - 20180201 - (Developed by Daniel Tavernier/tabernarious)
#                   - Removed "app-service none" from iCall objects. The iCall objects are now created as part of the Application Service (iApp) and are properly cleaned up if the iApp is redeployed or deleted.
#                   - Reasonably tested on 11.5.4 HF2 (SMB worked fine using "mount -t cifs") and altered requires-bigip-version-min to match.
#                   - Fixing error regarding "script did not successfully complete: (can't read "::destination_parameters__protocol_enable": no such variable" by encompassing most of the "implementation" in a block that first checks $::backup_schedule__frequency_select for "Disable".
#                   - Added default value to "filename format".
#                   - Changed UCS default value for $backup_file_name_extension to ".ucs" and added $fname_noext.
#                   - Removed old SFTP sections and references (now handled through SCP/SFTP).
#                   - Adjusted logging: added "sleep 1" to ensure proper logging; added $backup_directory to log message.
#                   - Adjusted some help messages.
# v3.1.1 - 20180331 - Removed TCL double substitution warnings
#                   - Fixed duplication of UCS file extension when uploading to FTP
# v3.1.2 - 20180510 - Allowed Destination to be an IP or hostname, and added clarifying notes.
#                   - Added Source IP notes to help users understand and manipulate the source IP used by BIG-IP.
#                   - Added path notes for SFTP/SCP and FTP.
#                   - Fixed ssh-keygen example syntax and added note about optional ssh-copy-id command.
#                   - Clarified SMB/CIFS special character escaping for password--not all non-alphanumeric characters need to be escaped.
# v3.1.3 - 20180511 - Added pruning option to only delete Archives created by this iApp using a Unique Suffix.
#                   - Muted ls errors on first-run of pruning script with Unique Suffix.
#                   - Fixed SCF pruning (previously only built for ucs file extension); also cleans up scf.tar files.
#                   - Fixed SCF generation with "no-passphrase" without which produces errors in 13.1.0.5 (not tested in any other versions).
#                   - Added pruning option for SMB/CIFS.
# v3.1.4 - 20180604 - Fixed can't read "::destination_parameters__pruning_mode" errors using [info exists ...].
#                   - Removed LTM from "Required Modules" list; now no modules are required.
#                   - SMB/CIFS now directly mounts the target directory instead of the mount point. This allows administrators to deny access to intermediate directories.
#                   - Set the pruning_keep_amount default to 3 (previously no default existed).
# v3.1.5 - 20181112 - Updated KNOWN ISSUES section (below)
#                   - Fixed SCF passphase issue (v11 "tmsh save sys config file NAME" works and applies no passphase ("no-passphase" flag does not exist); v12+ requires use of "no-passphrase" or "passphrase PHRASE"). (github Issue #18)
#                   - Reordered filename_format list; default remains ${host}_%Y%m%d_%H%M%S
#                   - Tested on 11.6.3.3, 12.1.3.7, and 13.1.1.2
# v3.1.6 - 20181114 - Fixed lots of issues with SCF files for SFTP/SCP, FTP, and SMB/CIFS (mainly, tar files were not being copied and were not being cleaned up locally). (github Issue #18)
#                   - Added logging clarification that when using SCF archives a .tar file is also generated and saved/uploaded.
#                   - Added debug logging for the SMB/CIFS script.
#                   - Now including on github an expanded form of the upload scripts for better understanding (see "f5.automated_backup.v3.1.6.scripts.sh" etc.).
# v3.1.7 - 20181115 - Now supporting many special characters for passwords (without manually escaping with backslashes). (github Issue #3 and #16)
#                   -- SMB/CIFS does NOT support comma, single-quote, and double-quote. I successfully tested this exact password to Windows Server 2012: `~!@#$%^&*()aB1-_=+[{]}\|;:<.>/?
#                   -- FTP should support all characters (based on limited testing). I successfully tested this exact password to a Linux FTP server: `~!@#$%^&*()aB1-_=+[{]}\|;:,"<.>'/?
# v3.1.8 - 20181115 - Scripts for SMB/CIFS and FTP will again be deleted after each backup. (This was in place as of v3.1.6 but was turned off for debugging in v3.1.7 and was not put back.)
# v3.1.9 - 20181120 - Fixed comment in SMB/CIFS script which was breaking everything due hash escape and a variable reference--I must not have actually tested after I added the comment :(

# KNOWN ISSUES and REQUESTS
# - F5 TMOS 11.4.1 - 11.5.3 have not been (they may work).
# - Using a 4096 bit private key for SFTP/SCP results in error "Unable to decrypt text of length (4338) which exceeds the max of (4048)" which may be an iApp bug/limitation of fields designated as type "password". (github Issue #12)
# -- Could add a second field to accept part of the key, then combine the values.
# -- Could use something like this to pull the key from the F5 filestore (though this would result in the key being accessible via the GUI). This might even work with encrypted keys: grep "sys file ssl-key /Common/KEY-NAME.key" -A1 /config/bigip.conf |tail -1 |sed 's/    cache-path //'
# - Reported issues with FTP (sending archive before finished or corrupting?) (github Issue #15)
# - Reported issues with SMB from v12.x to Windows Server 2012 (github Issue #17)
# - Add automatic pruning for FTP and SFTP/SCP.
# -- Use "dir -t" or "nlist -t" commands to pull file list...

#REFERENCES
# Git Repository for f5-automated-backup-iapp ( https://github.com/tabernarious/f5-automated-backup-iapp )
# F5 iApp Automated Backup ( https://devcentral.f5.com/codeshare/f5-iapp-automated-backup-1114 )
# F5 Automated Backups - The Right Way ( https://devcentral.f5.com/articles/f5-automated-backups-the-right-way )
# PASTEBIN f5.automated_backup_v2.0 ( https://pastebin.com/YbDj3eMN )
# Complete F5 Automated Backup Solution ( https://devcentral.f5.com/codeshare/complete-f5-automated-backup-solution?lc=1 )
# Complete F5 Automated Backup Solution #2 ( https://devcentral.f5.com/codeshare/complete-f5-automated-backup-solution-2-957 )
# Automated Backup Solution ( https://devcentral.f5.com/questions/automated-backup-solution )
# Generate Config Backup ( https://devcentral.f5.com/codeshare?sid=285 )
# PASTEBIN f5.automated_backup_v3.0.0 ( https://pastebin.com/TENAivwW )

cli admin-partitions {
    update-partition Common
}
sys application template /Common/f5.automated_backup.v3.1.9 {
    actions {
        definition {
            html-help {
            }
            implementation {
                package require iapp 1.0.0
	        	iapp::template start

	        	tmsh::cd ..

				## Backup type handler
				set backup_type $::backup_type__backup_type_select
				set create_backup_command_append_pass ""
				set create_backup_command_append_keys ""
				if { $backup_type eq "UCS (User Configuration Set)" } {
					set create_backup_command "tmsh::save /sys ucs"
					set backup_directory /var/local/ucs
					# Backup passphrase usage
					if { $::backup_type__backup_passphrase_select eq "Yes" } {
						set backup_passphrase $::backup_type__backup_passphrase
						set create_backup_command_append_pass "passphrase $backup_passphrase"
					}
					# Backup private key inclusion
					if { $::backup_type__backup_includeprivatekeys eq "No" } {
						set create_backup_command_append_keys "no-private-key"
					}
					set backup_file_name ""
					set backup_file_name_extension_with_dot ".ucs"
					set backup_file_name_extension_no_dot "ucs"
				}
				elseif { $backup_type eq "SCF (Single Configuration File)" } {
					set create_backup_command "tmsh::save /sys config file"
					set backup_directory /var/local/scf
					set backup_file_name_extension_with_dot ".scf"
					set backup_file_name_extension_no_dot "scf"
                    # Backup passphrase usage
                    if { $::backup_type__backup_passphrase_select eq "Yes" } {
                        set backup_passphrase $::backup_type__backup_passphrase
                        set create_backup_command_append_pass "passphrase $backup_passphrase"
                    }
                    else {
                        # Add the "no-passphrase" option which was added in v12 and is required if not using "passphrase"
                        set tmos_version [lindex [split [tmsh::version] "."] 0]
                        if { $tmos_version > 11 } {
                            set create_backup_command_append_pass "no-passphrase"
                        }
					}

				}

		        set freq $::backup_schedule__frequency_select

                if { $freq != "Disable" } {
                    # Ensure a default $filename_format is set
                    if { $::destination_parameters__filename_format eq "" } {
                        set filename_format {${host}_%Y%m%d_%H%M%S}
                    }
                    else {
                        set filename_format [lindex [split $::destination_parameters__filename_format " "] 0]
                    }

                    # Add $pruning_suffix if needed
                    if { [info exists ::destination_parameters__pruning_mode] && ($::destination_parameters__pruning_mode eq "Only Prune iApp-Generated Archives") } {
                        set pruning_suffix $::destination_parameters__pruning_suffix
                        append filename_format "_" ${pruning_suffix}
                    }

                    if { $::destination_parameters__protocol_enable eq "Remotely via SCP/SFTP" } {
                        # Get the F5 Master key
                        set f5masterkey [exec f5mku -K]
                        # Store the target server information securely, encrypted with the unit key
                        set encryptedusername [exec echo "$::destination_parameters__scp_remote_username" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedserver [exec echo "$::destination_parameters__scp_remote_server" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encrypteddirectory [exec echo "$::destination_parameters__scp_remote_directory" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        # Clean the private key data before cleanup
                        set cleaned_privatekey [exec echo "$::destination_parameters__scp_sshprivatekey" | sed -e "s/BEGIN RSA PRIVATE KEY/BEGIN;RSA;PRIVATE;KEY/g" -e "s/END RSA PRIVATE KEY/END;RSA;PRIVATE;KEY/g" -e "s/ /\\\n/g" -e "s/;/ /g"]
                        # Encrypt the private key data before dumping to a file
                        set encrypted_privatekey [exec echo "$cleaned_privatekey" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        # Set optional cipher for SCP (e.g. aes256-gcm@openssh.com)
                        if { "$::destination_parameters__scp_cipher" equals "" } {
                            set scp_cipher ""
                        } else {
                            set scp_cipher "-c $::destination_parameters__scp_cipher"
                        }
                        # Set optional "StrictHostKeyChecking=no"
                        if { "$::destination_parameters__scp_stricthostkeychecking" equals "Yes" } {
                            set scp_stricthostkeychecking "-o StrictHostKeyChecking=yes"
                        } else {
                            set scp_stricthostkeychecking "-o StrictHostKeyChecking=no"
                        }
                        # Create the iCall action
                        set script {
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: STARTED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: STARTED"
                            # Get the hostname of the device we're running on
                            set host [tmsh::get_field_value [lindex [tmsh::get_config sys global-settings] 0] hostname]
                            # Get the current date and time in a specific format
                            set cdate [clock format [clock seconds] -format "FORMAT"]
                            # Form the filename for the backup
                            set fname_noext "${cdate}"
                            set fname "${cdate}BACKUPFILENAMEEXTENSION_WITHDOT"
                            set fname_log $fname
                            if { "BACKUPFILENAMEEXTENSION_NODOT" eq "scf" } {
                                append fname_log " (and .tar)"
                            }
                            # Run the 'create backup' command
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING"
                            # Delay 1 second to allow proper logging to /var/tmp/scriptd.out
                            exec sleep 1
                            BACKUPCOMMAND $fname BACKUPAPPEND_PASS BACKUPAPPEND_KEYS
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)"
                            # Set the script filename
                            set scriptfile "/var/tmp/f5.automated_backup__TMSHAPPNAME_scp.sh"
                            # Clean, recreate, and run a custom bash script that will perform the SCP upload
                            exec rm -f $scriptfile
                            exec echo "yes"
                            exec echo -e "scp_function()\n{\n\tf5masterkey=\$(f5mku -K)\n\tusername=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\tserver=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\tdirectory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\techo \"ENCRYPTEDPRIVATEKEY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey} > /var/tmp/TMSHAPPNAME_scp.key\n\n\tchmod 600 /var/tmp/TMSHAPPNAME_scp.key\n\tscp -i /var/tmp/TMSHAPPNAME_scp.key SCPCIPHER SCPSTRICTHOSTKEYCHECKING BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* \${username}@\${server}:\${directory} 2>> /var/tmp/scriptd.out\n\tscp_result=\$?\n\trm -f /var/tmp/TMSHAPPNAME_scp.key\n\treturn \$scp_result\n}\n\nscp_function" > $scriptfile
                            exec chmod +x $scriptfile
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SCP) STARTING" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SCP) STARTING"
                            if { [catch {exec $scriptfile}] } {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SCP) FAILED (check for errors above)" >> /var/tmp/scriptd.out
                                exec logger -p local0.crit "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SCP) FAILED (see /var/tmp/scriptd.out for errors)"
                            } else {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SCP) SUCCEEDED" >> /var/tmp/scriptd.out
                                exec logger -p local0.notice "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SCP) SUCCEEDED"
                            }
                            # Clean up local files
                            exec rm -f $scriptfile
                            exec rm -f /var/tmp/TMSHAPPNAME_scp.key
                            # Calling /bin/sh is required due to wildcard which is required to clean up SCF (and .tar)
                            exec /bin/sh -c "rm -f BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*"
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: FINISHED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: FINISHED"
                        }
                        # Swap many variables into $script; due to the curly braces used to initially set $script, any referenced variables will *not* be expanded simply by deploying the iApp.
                        set script [string map [list FORMAT $filename_format BACKUPFILENAMEEXTENSION_WITHDOT $backup_file_name_extension_with_dot BACKUPFILENAMEEXTENSION_NODOT $backup_file_name_extension_no_dot BACKUPDIRECTORY $backup_directory BACKUPCOMMAND $create_backup_command BACKUPAPPEND_PASS $create_backup_command_append_pass BACKUPAPPEND_KEYS $create_backup_command_append_keys TMSHAPPNAME $tmsh::app_name ENCRYPTEDUSERNAME $encryptedusername ENCRYPTEDSERVER $encryptedserver ENCRYPTEDDIRECTORY $encrypteddirectory ENCRYPTEDPRIVATEKEY $encrypted_privatekey SCPCIPHER $scp_cipher SCPSTRICTHOSTKEYCHECKING $scp_stricthostkeychecking] $script]
                    }
                    elseif { $::destination_parameters__protocol_enable eq "Remotely via FTP" } {
                        # Get the F5 Master key
                        set f5masterkey [exec f5mku -K]
                        # Store the target server information securely, encrypted with the unit key
                        set encryptedusername [exec echo "$::destination_parameters__ftp_remote_username" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedpassword [exec echo "$::destination_parameters__ftp_remote_password" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedserver [exec echo "$::destination_parameters__ftp_remote_server" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encrypteddirectory [exec echo "$::destination_parameters__ftp_remote_directory" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        # Create the iCall action
                        set script {
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: STARTED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: STARTED"
                            # Get the hostname of the device we're running on
                            set host [tmsh::get_field_value [lindex [tmsh::get_config sys global-settings] 0] hostname]
                            # Get the current date and time in a specific format
                            set cdate [clock format [clock seconds] -format "FORMAT"]
                            # Form the filename for the backup
                            set fname_noext "${cdate}"
                            set fname "${cdate}BACKUPFILENAMEEXTENSION_WITHDOT"
                            set fname_log $fname
                            if { "BACKUPFILENAMEEXTENSION_NODOT" eq "scf" } {
                                append fname_log " (and .tar)"
                            }
                            # Run the 'create backup' command
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING"
                            # Delay 1 second to allow proper logging to /var/tmp/scriptd.out
                            exec sleep 1
                            BACKUPCOMMAND $fname BACKUPAPPEND_PASS BACKUPAPPEND_KEYS
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)"
                            # Set the config file
                            set configfile "/config/f5.automated_backup__TMSHAPPNAME_ftp.conf"
                            # Set the script filename
                            set scriptfile "/var/tmp/f5.automated_backup__TMSHAPPNAME_ftp.sh"
                            # Clean, recreate, run and reclean a custom bash script that will perform the FTP upload
                            exec rm -f $scriptfile
                            # Updated command v2.2.4 to force binary transfer.
                            exec echo -e "ftp_function()\n{\n\tf5masterkey=\$(f5mku -K)\n\tusername=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\tpassword=\$(echo \"ENCRYPTEDPASSWORD\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\t# Escape every character for safe submission of special characters in the password\n\tpassword_escaped=\$(echo \${password} | sed \'s/./\\\\\\&/g\')\n\tserver=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\tdirectory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\n\n\tif \[ \"BACKUPFILENAMEEXTENSION_NODOT\" == \"scf\" \]\n\tthen\n\t\tftp_return=\$(ftp -n \${server} << END_FTP\nquote USER \${username}\nquote PASS \${password_escaped}\nbinary\nput BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT \${directory}/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT\nput BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT.tar \${directory}/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT.tar\nquit\nEND_FTP\n)\n\telse\n\t\tftp_return=\$(ftp -n \${server} << END_FTP\nquote USER \${username}\nquote PASS \${password_escaped}\nbinary\nput BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT \${directory}/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT\nquit\nEND_FTP\n)\n\tfi\n\n\tif \[ \"\$ftp_return\" == \"\" \]\n\tthen\n\t\treturn 0\n\telse\n\t\techo \"\$ftp_return\" >> /var/tmp/scriptd.out\n\t\treturn 1\n\tfi\n}\n\nftp_function\n" > $scriptfile
                            exec chmod +x $scriptfile
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (FTP) STARTING" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (FTP) STARTING"
                            if { [catch {exec $scriptfile}] } {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (FTP) FAILED (check for errors above)" >> /var/tmp/scriptd.out
                                exec logger -p local0.crit "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (FTP) FAILED (see /var/tmp/scriptd.out for errors)"
                            } else {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (FTP) SUCCEEDED" >> /var/tmp/scriptd.out
                                exec logger -p local0.notice "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (FTP) SUCCEEDED"
                            }
                            # Clean up local files
                            exec rm -f $scriptfile
                            # Calling /bin/sh is required due to wildcard which is required to clean up SCF (and .tar)
                            exec /bin/sh -c "rm -f BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*"
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: FINISHED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: FINISHED"
                        }
                        # Swap many variables into $script; due to the curly braces used to initially set $script, any referenced variables will *not* be expanded simply by deploying the iApp.
                        set script [string map [list FORMAT $filename_format BACKUPFILENAMEEXTENSION_WITHDOT $backup_file_name_extension_with_dot BACKUPFILENAMEEXTENSION_NODOT $backup_file_name_extension_no_dot BACKUPDIRECTORY $backup_directory BACKUPCOMMAND $create_backup_command BACKUPAPPEND_PASS $create_backup_command_append_pass BACKUPAPPEND_KEYS $create_backup_command_append_keys TMSHAPPNAME $tmsh::app_name ENCRYPTEDUSERNAME $encryptedusername ENCRYPTEDPASSWORD $encryptedpassword ENCRYPTEDSERVER $encryptedserver ENCRYPTEDDIRECTORY $encrypteddirectory] $script]
                    }
                    elseif { $::destination_parameters__protocol_enable eq "Remotely via SMB/CIFS" } {
                        # Get the F5 Master key
                        set f5masterkey [exec f5mku -K]
                        # Store the target server information securely, encrypted with the unit key
                        set encryptedusername [exec echo "$::destination_parameters__smb_remote_username" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedpassword [exec echo "$::destination_parameters__smb_remote_password" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedmsdomain [exec echo "$::destination_parameters__smb_remote_domain" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedserver [exec echo "$::destination_parameters__smb_remote_server" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedmsshare [exec echo "$::destination_parameters__smb_remote_path" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedmssubdir [exec echo "$::destination_parameters__smb_remote_directory" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        set encryptedmountp [exec echo "$::destination_parameters__smb_local_mountdir" | openssl aes-256-ecb -salt -a -A -k ${f5masterkey}]
                        # Set up for pruning, if enabled
                        # Set default pruning variables
                        set pruning_suffix ""
                        set prune_conserve ""
                        set pruning_mode "Disabled"
                        if { $::destination_parameters__pruning_mode ne "Disabled" } {
                            set pruning_mode $::destination_parameters__pruning_mode
                            set prune_conserve $::destination_parameters__pruning_keep_amount
                            if { $::destination_parameters__pruning_mode eq "Only Prune iApp-Generated Archives" } {
                                # Set $pruning_suffix so that pruning script only lists (and prunes) Archives with the suffix
                                append pruning_suffix "_" $::destination_parameters__pruning_suffix
                            }
                        }
                        # Create the iCall action
                        set script {
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: STARTED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: STARTED"
                            # Get the hostname of the device we're running on
                            set host [tmsh::get_field_value [lindex [tmsh::get_config sys global-settings] 0] hostname]
                            # Get the current date and time in a specific format
                            set cdate [clock format [clock seconds] -format "FORMAT"]
                            # Form the filename for the backup
                            set fname_noext "${cdate}"
                            set fname "${cdate}BACKUPFILENAMEEXTENSION_WITHDOT"
                            set fname_log $fname
                            if { "BACKUPFILENAMEEXTENSION_NODOT" eq "scf" } {
                                append fname_log " (and .tar)"
                            }
                            # Run the 'create backup' command
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING"
                            # Delay 1 second to allow proper logging to /var/tmp/scriptd.out
                            exec sleep 1
                            BACKUPCOMMAND $fname BACKUPAPPEND_PASS BACKUPAPPEND_KEYS
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)"
                            # Set the script filename
                            set scriptfile "/var/tmp/f5.automated_backup__TMSHAPPNAME_smb.sh"
                            # Clean, recreate, run and reclean a custom bash script that will perform the SMB upload
                            exec rm -f $scriptfile
                            exec echo -e "\#\!/bin/sh\nf5masterkey=\$(f5mku -K)\nusername=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\npassword=\$(echo \"ENCRYPTEDPASSWORD\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\nmsdomain=\$(echo \"ENCRYPTEDMSDOMAIN\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\nserver=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\nmsshare=\$(echo \"ENCRYPTEDMSSHARE\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\nmssubdir=\$(echo \"ENCRYPTEDMSSUBDIR\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\nmountp=\$(echo \"ENCRYPTEDMOUNTP\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})\ncd BACKUPDIRECTORY\nif \[ \! -d \${mountp} \]\nthen\n\tmkdir -p \${mountp}\n\tif \[ \$? -ne 0 \]\n\tthen\n\t\trm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*\n\t\texit 1\n\tfi\nfi\n\# The password must be surrounded by two single-quotes to successfully handle special characters. Still does not support comma, single-quote, and double-quote.\nmount -t cifs //\${server}/\${msshare}\${mssubdir} \${mountp} -o user=\${username}%\'\'\${password}\'\',domain=\${msdomain} 2>> /var/tmp/scriptd.out\nif \[ \$? -ne 0 \]\n\tthen\n\techo \"DEBUG: Failed to mount //\${server}/\${msshare}\${mssubdir}\ to \${mountp}\" >> /var/tmp/scriptd.out\n\trm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*\n\texit 1\nelse\n\techo \"DEBUG: Successfully mounted //\${server}/\${msshare}\${mssubdir}\ to \${mountp}\" >> /var/tmp/scriptd.out\nfi\n\nlatestFileOnSMB=\$(ls -t \${mountp}/\*.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null| head -n 1 2>/dev/null)\necho \"DEBUG: Latest BACKUPFILENAMEEXTENSION_NODOT file found on SMB mount: \$latestFileOnSMB\" >> /var/tmp/scriptd.out\n\nif \[ \"X\"\${latestFileOnSMB} \!= \"X\" \]\n\tthen\n\tsum1=\$(md5sum ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT | awk '{print \$1}')\n\tsum2=\$(md5sum \${latestFileOnSMB} | awk \'{print \$1}\')\n\tif \[ \${sum1} == \${sum2} \]\n\tthen\n\t\techo \"ERROR: File ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT already exists in //\${server}/\${msshare}\${mssubdir}\" >> /var/tmp/scriptd.out\n\t\tumount \${mountp}\n\t\trm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*\n\t\texit 1\n\telse\n\t\techo \"DEBUG: File ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT does not already exist in //\${server}/\${msshare}\${mssubdir} (continuing...)\" >> /var/tmp/scriptd.out\n\tfi\nelse\n\techo \"DEBUG: Destination SMB mount contains no BACKUPFILENAMEEXTENSION_NODOT files (continuing...)\" >> /var/tmp/scriptd.out\nfi\ncp ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* \${mountp}\nrm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*\n\nif \[ \"PRUNINGMODE\" \!= \"Disabled\" \]; then\n\n\tfiles_tokeep=\$(ls -t \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null | head -n CONSERVE\)\n\tfor current_archive_file in `ls \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null` ; do\n\t\tcurrent_archive_file_basename=`basename \$current_archive_file`\n\t\tcheck_file=\$(echo \$files_tokeep | grep -w \$current_archive_file_basename)\n\t\tif \[ \"\$check_file\" == \"\" \] ; then\n\t\t\trm -f \$current_archive_file\n\t\tfi\n\tdone\n\tif \[ \"BACKUPFILENAMEEXTENSION_NODOT\" == \"scf\" \] ; then\n\t\ttar_files_tokeep=\$(ls -t \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null | head -n CONSERVE\)\n\t\tfor current_archive_tar_file in `ls \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null` ; do\n\t\t\tcurrent_archive_tar_file_basename=`basename \$current_archive_tar_file`\n\t\t\tcheck_file=\$(echo \$tar_files_tokeep | grep -w \$current_archive_tar_file_basename)\n\t\t\tif \[ \"\$check_file\" == \"\" \] ; then\n\t\t\t\trm -f \$current_archive_tar_file\n\t\t\tfi\n\t\tdone\n\tfi\nfi\n\numount \${mountp}\n\nexit 0\n" > $scriptfile
                            exec chmod +x $scriptfile
                            if { "PRUNINGMODE" ne "Disabled" } {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY and PRUNING (SMB/CIFS) STARTING" >> /var/tmp/scriptd.out
                                exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY and PRUNING (SMB/CIFS) STARTING"
                            } else {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SMB/CIFS) STARTING" >> /var/tmp/scriptd.out
                                exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SMB/CIFS) STARTING"
                            }
                            if { [catch {exec $scriptfile}] } {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SMB/CIFS) FAILED (check for errors above)" >> /var/tmp/scriptd.out
                                exec logger -p local0.crit "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SMB/CIFS) FAILED (see /var/tmp/scriptd.out for errors)"
                            } else {
                                exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SMB/CIFS) SUCCEEDED" >> /var/tmp/scriptd.out
                                exec logger -p local0.notice "f5.automated_backup iApp TMSHAPPNAME: $fname_log REMOTE COPY (SMB/CIFS) SUCCEEDED"
                            }
                            # Clean up local files
                            exec rm -f $scriptfile
                            # Calling /bin/sh is required due to wildcard which is required to clean up SCF (and .tar)
                            exec /bin/sh -c "rm -f BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*"
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: FINISHED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: FINISHED"
                        }
                        # Swap many variables into $script; due to the curly braces used to initially set $script, any referenced variables will *not* be expanded simply by deploying the iApp.
                        set script [string map [list FORMAT $filename_format BACKUPFILENAMEEXTENSION_WITHDOT $backup_file_name_extension_with_dot BACKUPFILENAMEEXTENSION_NODOT $backup_file_name_extension_no_dot BACKUPDIRECTORY $backup_directory BACKUPCOMMAND $create_backup_command BACKUPAPPEND_PASS $create_backup_command_append_pass BACKUPAPPEND_KEYS $create_backup_command_append_keys TMSHAPPNAME $tmsh::app_name ENCRYPTEDUSERNAME $encryptedusername ENCRYPTEDPASSWORD $encryptedpassword ENCRYPTEDMSDOMAIN $encryptedmsdomain ENCRYPTEDSERVER $encryptedserver ENCRYPTEDMSSHARE $encryptedmsshare ENCRYPTEDMSSUBDIR $encryptedmssubdir ENCRYPTEDMOUNTP $encryptedmountp PRUNINGSUFFIX $pruning_suffix CONSERVE $prune_conserve PRUNINGMODE $pruning_mode] $script]
                    }
                    else {
                        # Saving archives locally
                        set script {
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: STARTED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: STARTED"
                            # Get the hostname of the device we're running on
                            set host [tmsh::get_field_value [lindex [tmsh::get_config sys global-settings] 0] hostname]
                            # Get the current date and time in a specific format
                            set cdate [clock format [clock seconds] -format "FORMAT"]
                            # Form the filename for the backup
                            set fname "${cdate}BACKUPFILENAMEEXTENSION_WITHDOT"
                            # Run the 'create backup' command
                            set fname_log $fname
                            if { "BACKUPFILENAMEEXTENSION_NODOT" eq "scf" } {
                                append fname_log " (and .tar)"
                            }
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log GENERATING"
                            # Delay 1 second to allow proper logging to /var/tmp/scriptd.out
                            exec sleep 1
                            BACKUPCOMMAND $fname BACKUPAPPEND_PASS BACKUPAPPEND_KEYS
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: $fname_log SAVED LOCALLY (BACKUPDIRECTORY)"
                            exec echo "f5.automated_backup iApp TMSHAPPNAME: FINISHED" >> /var/tmp/scriptd.out
                            exec logger -p local0.info "f5.automated_backup iApp TMSHAPPNAME: FINISHED"
                        }
                        # Swap many variables into $script; due to the curly braces used to initially set $script, any referenced variables will *not* be expanded simply by deploying the iApp.
                        set script [string map [list FORMAT $filename_format BACKUPFILENAMEEXTENSION_WITHDOT $backup_file_name_extension_with_dot BACKUPFILENAMEEXTENSION_NODOT $backup_file_name_extension_no_dot BACKUPDIRECTORY $backup_directory BACKUPCOMMAND $create_backup_command BACKUPAPPEND_PASS $create_backup_command_append_pass BACKUPAPPEND_KEYS $create_backup_command_append_keys TMSHAPPNAME $tmsh::app_name] $script]
                    }

                    iapp::conf create sys icall script f5.automated_backup__${tmsh::app_name} definition \{ $script \}

		        ## Get time info for setting first-occurrence on daily handler from iApp input
                    #Create the handlers
                    if { $freq eq "Every X Minutes" } {
                        set everyxminutes $::backup_schedule__everyxminutes_value
                        set interval [expr {$everyxminutes*60}]
                        set cdate [clock format [clock seconds] -format "%Y-%m-%d:%H:%M"]
                        iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}-handler \{ \
                        interval $interval \
                        first-occurrence $cdate:00 \
                        script f5.automated_backup__${tmsh::app_name} \}
                    }
                    elseif { $freq eq "Every X Hours" } {
                        set everyxhours $::backup_schedule__everyxhours_value
                        set interval [expr {$everyxhours*3600}]
                        set minutes $::backup_schedule__everyxhours_min_select
                        set cdate [clock format [clock seconds] -format "%Y-%m-%d:%H"]
                        iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}-handler \{ \
                        interval $interval \
                        first-occurrence $cdate:$minutes:00 \
                        script f5.automated_backup__${tmsh::app_name} \}
                    }
                    elseif { $freq eq "Every X Days" } {
                        set everyxdays $::backup_schedule__everyxdays_value
                        set interval [expr {$everyxdays*86400}]
                        set hours [lindex [split $::backup_schedule__everyxdays_time ":"] 0]
                        set minutes [lindex [split $::backup_schedule__everyxdays_time ":"] 1]
                        set cdate [clock format [clock seconds] -format "%Y-%m-%d"]
                        iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}-handler \{ \
                        interval $interval \
                        first-occurrence $cdate:$hours:$minutes:00 \
                        script f5.automated_backup__${tmsh::app_name} \}
                    }
                    elseif { $freq eq "Every X Weeks" } {
                        set everyxweeks $::backup_schedule__everyxweeks_value
                        set interval [expr {$everyxweeks*604800}]
                        set hours [lindex [split $::backup_schedule__everyxweeks_time ":"] 0]
                        set minutes [lindex [split $::backup_schedule__everyxweeks_time ":"] 1]
                        ## Get day of week info for setting first-occurrence on weekly handler from iApp input
                        array set dowmap {
                            Sunday 0
                            Monday 1
                            Tuesday 2
                            Wednesday 3
                            Thursday 4
                            Friday 5
                            Saturday 6
                        }
                        set sday_name $::backup_schedule__everyxweeks_dow_select
                        set sday_num $dowmap($sday_name)
                        set cday_name [clock format [clock seconds] -format "%A"]
                        set cday_num $dowmap($cday_name)
                        set date_offset [expr {86400*($sday_num - $cday_num)}]
                        set date_final [clock format [expr {[clock seconds] + $date_offset}] -format "%Y-%m-%d"]
                        iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}-handler \{ \
                            interval $interval \
                            first-occurrence $date_final:$hours:$minutes:00 \
                            script f5.automated_backup__${tmsh::app_name} \}
                    }
                    elseif { $freq eq "Every X Months" } {
                        set everyxmonths $::backup_schedule__everyxmonths_value
                        set interval [expr {60*60*24*365}]
                        set dom $::backup_schedule__everyxmonths_dom_select
                        set hours [lindex [split $::backup_schedule__everyxmonths_time ":"] 0]
                        set minutes [lindex [split $::backup_schedule__everyxmonths_time ":"] 1]
                        for { set month 1 } { $month < 13 } { set month [expr {$month+$everyxmonths}] } {
                            set cdate [clock format [clock seconds] -format "%Y-$month-$dom"]
                            iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}-month_${month}-handler \{ \
                            interval $interval \
                            first-occurrence $cdate:$hours:$minutes:00 \
                            script f5.automated_backup__${tmsh::app_name} \}
                        }
                    }
                    elseif { $freq eq "Custom" } {
                        set hours [lindex [split $::backup_schedule__custom_time ":"] 0]
                        set minutes [lindex [split $::backup_schedule__custom_time ":"] 1]
                        ## Get day of week info for setting first-occurrence on weekly handler from iApp input
                        array set dowmap {
                            Sunday 0
                            Monday 1
                            Tuesday 2
                            Wednesday 3
                            Thursday 4
                            Friday 5
                            Saturday 6
                        }
                        foreach sday_name $::backup_schedule__custom_dow_select {
                            set sday_num $dowmap($sday_name)
                            set cday_name [clock format [clock seconds] -format "%A"]
                            set cday_num $dowmap($cday_name)
                            set date_offset [expr {86400*($sday_num - $cday_num)}]
                            set date_final [clock format [expr {[clock seconds] + $date_offset}] -format "%Y-%m-%d"]
                            iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}-handler-$sday_name \{ \
                                interval 604800 \
                                first-occurrence $date_final:$hours:$minutes:00 \
                                script f5.automated_backup__${tmsh::app_name} \}
                        }
                    }
                    else {

                    }

                    ## Automatic Pruning handler for local storage
                    if { $::destination_parameters__protocol_enable eq "On this F5" } {
                        if { $::destination_parameters__pruning_mode ne "Disabled" } {
                            set prune_conserve $::destination_parameters__pruning_keep_amount
                            set today [clock format [clock seconds] -format "%Y-%m-%d"]
                            # Set default $pruning_suffix to blank
                            set pruning_suffix ""
                            if { $::destination_parameters__pruning_mode eq "Only Prune iApp-Generated Archives" } {
                                # Set $pruning_suffix so that pruning script only lists (and prunes) Archives with the suffix
                                append pruning_suffix "_" $::destination_parameters__pruning_suffix
                            }
                            set script {
                                # Get the hostname of the device we're running on
                                set host [tmsh::get_field_value [lindex [tmsh::get_config sys global-settings] 0] hostname]
                                # Set the script filename
                                set scriptfile "/var/tmp/autopruning.sh"
                                # Clean, recreate, run and reclean a custom bash script that will perform the pruning
                                exec rm -f $scriptfile
                                exec echo -e "files_tokeep=\$(ls -t BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null | head -n CONSERVE\)\nfor current_archive_file in `ls BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null` ; do\n\tcurrent_archive_file_basename=`basename \$current_archive_file`\n\tcheck_file=\$(echo \$files_tokeep | grep -w \$current_archive_file_basename)\n\tif \[ \"\$check_file\" == \"\" \] ; then\n\t\trm -f \$current_archive_file\n\tfi\ndone\nif \[ \"BACKUPFILENAMEEXTENSION_NODOT\" == \"scf\" \] ; then\n\ttar_files_tokeep=\$(ls -t BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null | head -n CONSERVE\)\n\tfor current_archive_tar_file in `ls BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null` ; do\n\t\tcurrent_archive_tar_file_basename=`basename \$current_archive_tar_file`\n\t\tcheck_file=\$(echo \$tar_files_tokeep | grep -w \$current_archive_tar_file_basename)\n\t\tif \[ \"\$check_file\" == \"\" \] ; then\n\t\t\trm -f \$current_archive_tar_file\n\t\tfi\n\tdone\nfi" > $scriptfile
                                exec chmod +x $scriptfile
                                exec $scriptfile
                                exec rm -f $scriptfile
                            }
                            set script [string map [list CONSERVE $prune_conserve PRUNINGSUFFIX $pruning_suffix BACKUPDIRECTORY $backup_directory BACKUPFILENAMEEXTENSION_NODOT $backup_file_name_extension_no_dot] $script]
                            iapp::conf create sys icall script f5.automated_backup__${tmsh::app_name}_pruning definition \{ $script \}
                            set cdate [clock format [clock seconds] -format "%Y-%m-%d:%H:%M"]
                            # Interval can be increased as needed if pruning every minute is problematic
                            iapp::conf create sys icall handler periodic f5.automated_backup__${tmsh::app_name}_pruning-handler \{ \
                            interval 60 \
                            first-occurrence $cdate:00 \
                            script f5.automated_backup__${tmsh::app_name}_pruning \}
                        }
                    }
                }

				iapp::template end
            }
            macro {
            }
            presentation {
                section deployment_info {
                    message deployment_info_first_time "Deploying the iApp may not trigger an immediate backup."
                    message deployment_info_updates "For testing, to force the iApp to run an immediate backup it is easiest to set the Backup Schedule to 'Every X Minutes' and simply change value of 'X equals. Redeploying the iApp will not trigger an immediate backup unless the iCall handler is recreated and the first-occurrence value is set to a time before the moment of redeployment. When testing is complete, set the Backup Schedule to the desired ongoing schedule."
                    message deployment_info_logs "The general log for all iApps is '/var/tmp/scriptd.out'. This iApp adds run logs and errors to '/var/tmp/scriptd.out'. Additionally, this iApp sends run logs (not full error messages) to '/var/log/ltm' (compatible with BIG-IP Remote Logging configuration)."
                }
                section backup_type {
					choice backup_type_select display "xlarge" { "UCS (User Configuration Set)", "SCF (Single Configuration File)" }
					optional ( backup_type_select == "SCF (Single Configuration File)" ) {
                        message backup_help_scf "WARNING: SCF files are intended to help in the configuration of additional BIG-IP systems. However, SCFs are not intended to be used to backup and restore a full BIG-IP system configuration. For more information see SOL13408 (http://support.f5.com/kb/en-us/solutions/public/13000/400/sol13408.html)."
                        message backup_help_scf2 "An SCF archive consists of two files: 1) a flat text file with the configuration from bigip.conf, bigip_base.conf, etc., and 2) a tar file that contains most everything from /config/filestore including SSL private keys and certificates, iFiles, RSA SecurID files, APM customization files, etc."
                    }
                    choice backup_passphrase_select display "small" { "Yes", "No" }
                    optional ( backup_passphrase_select == "Yes" ) {
                        message backup_help_passphrase "WARNING: Losing the passphase will render the archives unusable. The encrypted archive will be a PGP encoded file, *not* simply a tar.gz with a password on it."
                        password backup_passphrase required display "large"
                    }
					optional ( backup_type_select == "UCS (User Configuration Set)" ) {
						choice backup_includeprivatekeys display "small" { "Yes", "No" }
                        optional ( backup_includeprivatekeys == "No" ) {
                            message backup_help_privatekeys_ucs "WARNING: A UCS archive that does not contain the private keys CANNOT be used for restoring the device. It should be used for transfers to external services to whom you do not wish to disclose the private keys."
                        }
					}
					optional ( backup_type_select == "SCF (Single Configuration File)" ) {
                        message backup_help_privatekeys_scf "PRIVATE KEY WARNING: The tar files created alongside each SCF flat-text archive will contain sensitive files such as SSL private keys."
                        message backup_help_restore_scf "SCF RESTORE WARNING: An SCF flat-text archive without the accompanying tar file CANNOT be used for restoring the device."
                    }
				}
				section backup_schedule {
					choice frequency_select display "large" { "Disable", "Every X Minutes", "Every X Hours", "Every X Days", "Every X Weeks", "Every X Months", "Custom" }
					optional ( frequency_select == "Every X Minutes" ) {
						editchoice everyxminutes_value default "30" display "small" { "1", "2", "5", "10", "15", "20", "30", "45", "60" }
					}
					optional ( frequency_select == "Every X Hours" ) {
						editchoice everyxhours_value default "1" display "small" { "1", "2", "3", "4", "6", "12", "24" }
						choice everyxhours_min_select display "small" tcl {
							for { set x 0 } { $x < 60 } { incr x } {
								append mins "$x\n"
							}
							return $mins
						}
					}
					optional ( frequency_select == "Every X Days" ) {
						editchoice everyxdays_value default "1" display "small" { "1", "2", "3", "4", "5", "7", "14" }
						string everyxdays_time required display "medium"
					}
					optional ( frequency_select == "Every X Weeks" ) {
						editchoice everyxweeks_value default "1" display "small" { "1", "2", "3", "4", "5", "7", "14" }
						choice everyxweeks_dow_select default "Sunday" display "medium" { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
						string everyxweeks_time required display "small"
					}
					optional ( frequency_select == "Every X Months" ) {
						editchoice everyxmonths_value default "1" display "small" { "1", "2", "3", "6", "12" }
						choice everyxmonths_dom_select display "small" tcl {
							for { set x 1 } { $x < 31 } { incr x } {
								append days "$x\n"
							}
							return $days
						}
						string everyxmonths_time required display "small"
					}
					optional ( frequency_select == "Custom" ) {
						multichoice custom_dow_select default {"Sunday"} display "medium" { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" }
						string custom_time required display "small"
					}
				}
				optional ( backup_schedule.frequency_select != "Disable" ) {
					section destination_parameters {
						choice protocol_enable display "xlarge" { "On this F5", "Remotely via SCP/SFTP", "Remotely via SMB/CIFS", "Remotely via FTP" }
						optional ( protocol_enable == "Remotely via SCP/SFTP") {
							message scp_sftp_help "A connection to an SSH server can be establish using both SCP and SFTP. SCP is more efficient for copying files to a remote network destination while, for interactive sessions, the SFTP protocol offers more features. This iApp uses SCP."
                            string scp_remote_server required display "medium"
                            message scp_remote_server_help "The Destination can be an IP address or an FQDN. DNS must be configured and functional on this BIG-IP (and HA peers) for an FQDN to work."
                            message scp_remote_server_help2 "IMPORTANT: Check '/root/.ssh/known_hosts' on each BIG-IP (including HA peers) to ensure the Destination above is listed. If using an FQDN, the name (not just the IP) must be in known_hosts. On each BIG-IP that does not list the Destination (including HA peers), connect directly to the Destination using the scp or ssh command. You will be asked to verify the 'RSA key fingerprint'. Entering 'yes' will store the fingerprint in '/root/.ssh/known_hosts' and allow subsequent connections without further verification. If you run into cipher errors, you may need to add '-c aes128-ctr' or an appropriate cipher (see the help under Cipher below)."
                            message scp_source_help "Connections to the Destination will be sourced from a non-floating Self IP or from the Management IP based on L2/L3 networking. If the Destination is in the same subnet as a Self IP or the Management IP, you cannot easily affect the source IP. If the Destination must be routed, you can manipulate the source IP by creating a TMM route or Management Route to force the L3 next-hop/gateway (the BIG-IP will use a source IP in the same subnet as the L3 next-hop/gateway)."
                            choice scp_stricthostkeychecking default "Yes" display "large" { "Yes", "No (INSECURE)" }
                            optional ( scp_stricthostkeychecking == "No (INSECURE)" ) {
                                message scp_stricthostkeychecking_warning1 "WARNING: Selecting 'No (INSECURE)' will ignore certificate verification for connections this iApp makes to the server configured above. Backups could be copied to an unintended server, including one owned by a bad actor."
                            }
                            message scp_stricthostkeychecking_help1 "It is MOST SECURE to select Yes, which is the SCP/SSH default setting and which will not allow connections to unknown servers. A server is considered 'unknown' until an SSH key fingerprint has been verified, or if the destination SSL certificate changes and the fingerprint no longer matches."
                            optional ( scp_stricthostkeychecking == "Yes" ) {
                                message scp_stricthostkeychecking_help2 "Selecting 'No (INSECURE)' will ignore certificate verification for connections this iApp makes to the server configured above."
                                message scp_stricthostkeychecking_trouble1 "TROUBLESHOOTING: If the SCP script fails with a 'Host key verification failed' or 'No RSA host key is known for' error (which can viewed in /var/tmp/scriptd.out after deploying this iApp), review the IMPORTANT steps (under Destination IP) above regarding the known_hosts file to resolve the issue. Also, review additional troubleshooting notes."
                                message scp_stricthostkeychecking_trouble2 "TROUBLESHOOTING: If the SCP script fails with a 'WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!' error (which can viewed in /var/tmp/scriptd.out after deploying this iApp), the certificate on the destination server has changed. This could mean 1) The certificate was updated legitimately, or 2) There is an IP conflict and the script is connecting to the wrong server, or 3) the destination server was replaced or rebuilt and has a new certificate, or 4) a bad actor is intercepting the connection (man-in-the-middle) and the script is rightly warning you to not connect. Investigate the destination server before proceeding."
                            }
							string scp_remote_username required display "medium"
							password scp_sshprivatekey required display "large"
                            message scp_encrypted_field_storage_help "Private key must be non-encrypted and in 'OpenSSH' base64 format. As an example run 'ssh-keygen -t rsa -b 4096 -C f5_backups' from the BIG-IP CLI, step through the questions, and view the resulting private key (by default ssh-keygen will save the key to ~/.ssh/id_rsa)."
                            message scp_encrypted_field_storage_help2 "If the Destination Server supports it, you may optionally run 'ssh-copy-id -i /root/.ssh/id_rsa.pub -o Ciphers=aes128-ctr username@destination' (with relevant values) to add the public key to the Destination Server's authorized_keys file (this only needs to be done once per unique key--not from every BIG-IP)."
							message scp_encrypted_field_storage_help3 "Passwords and private keys are stored in an encrypted format. The salt for the encryption algorithm is the F5 cluster's Master Key. The master key is not shared when exporting a qkview or UCS, thus rendering your passwords and private keys safe if a backup file were to be stored off-box."
                            editchoice scp_cipher display "xlarge" { "aes128-ctr", "aes192-ctr", "aes256-ctr", "aes128-gcm@openssh.com", "chacha20-poly1305@openssh.com" }
							message scp_cipher_help "This can often be left blank but, depending on the version of F5 TMOS and the ssh configuration of the destination server, there may be no matching ciphers resulting in a 'no matching cipher found' error (which can viewed in /var/tmp/scriptd.out after deploying this iApp or it can be tested/demonstrated by attempting an scp or ssh connection from this device to the destination server). Find the word 'server' in the error and note the ciphers listed; select one of these ciphers from the list above or paste in one not listed. This can be tested by attempting 'ssh -c aes128-ctr username@destination' (with appropriate cipher) from this device's CLI."
							string scp_remote_directory display "large"
                            message scp_remote_directory_help "Full path without a trailing slash (e.g. '/home/user1/f5_backups/prod')."
						}
						optional ( protocol_enable == "Remotely via SMB/CIFS") {
							string smb_remote_server required display "medium"
                            message smb_remote_server_help "The Destination can be an IP address or an FQDN. DNS must be configured and functional on this BIG-IP (and HA peers) for an FQDN to work."
                            message smb_remote_server_help2 "Ensure this Destination IP is reachable on port 139."
                            message smb_source_help "Connections to the Destination will be sourced from a non-floating Self IP or from the Management IP based on L2/L3 networking. If the Destination is in the same subnet as a Self IP or the Management IP, you cannot easily affect the source IP. If the Destination must be routed, you can manipulate the source IP by creating a TMM route or Management Route to force the L3 next-hop/gateway (the BIG-IP will use a source IP in the same subnet as the L3 next-hop/gateway)."
							string smb_remote_domain required display "medium"
							message smb_remote_domain_help "Start by entering the NetBIOS/Pre-Windows 2000 domain name; the fully qualified DNS domain name may work or be required in some environments."
							string smb_remote_username required display "medium"
							password smb_remote_password display "medium"
                            message smb_remote_password_help "Most special characters are supported as of iApp v3.1.7 (DO NOT use backslash escaping). Do not use comma, single-quote, or double-quote."
							message smb_remote_password_help2 "Passwords and private keys are stored in an encrypted format. The salt for the encryption algorithm is the F5 cluster's Master Key. The master key is not shared when exporting a qkview or UCS, thus rendering your passwords and private keys safe if a backup file were to be stored off-box."
							string smb_remote_path required display "large"
							message smb_remote_path_help "SMB share on a remote server. Do not include leading and trailing slashes. If the full share path is //SERVER/SHARE, enter SHARE in this field. If the full share path is //SERVER/PATH/SHARE, enter PATH/SHARE in this field."
							string smb_remote_directory display "large"
							message smb_remote_directory_help "Relative path inside the SMB share to copy the file. Leave this field empty to store in root of SMB share. Include one leading slash and no trailing slashes. If the target directory is //SERVER/SHARE/PATH/DIRECTORY, enter /PATH/DIRECTORY in this field."
							string smb_local_mountdir required default "/var/tmp/cifs" display "large"
							message smb_local_mountdir_help "Read-Write path on local F5 where SMB share will be mounted. Include one leading slash and no trailing slashes, for example /var/tmp/cifs"
						}
						optional ( protocol_enable == "Remotely via FTP") {
							string ftp_remote_server required display "medium"
                            message ftp_remote_server_help "The Destination can be an IP address or an FQDN. DNS must be configured and functional on this BIG-IP (and HA peers) for an FQDN to work."
                            message ftp_source_help "Connections to the Destination will be sourced from a non-floating Self IP or from the Management IP based on L2/L3 networking. If the Destination is in the same subnet as a Self IP or the Management IP, you cannot easily affect the source IP. If the Destination must be routed, you can manipulate the source IP by creating a TMM route or Management Route to force the L3 next-hop/gateway (the BIG-IP will use a source IP in the same subnet as the L3 next-hop/gateway)."
							string ftp_remote_username required display "medium"
							password ftp_remote_password display "medium"
                            message ftp_remote_password_help "Most special characters are supported as of iApp v3.1.7 (DO NOT use backslash escaping)."
							message ftp_encrypted_field_storage_help "Passwords and private keys are stored in an encrypted format. The salt for the encryption algorithm is the F5 cluster's Master Key. The master key is not shared when exporting a qkview or UCS, thus rendering your passwords and private keys safe if a backup file were to be stored off-box."
							string ftp_remote_directory display "large"
                            message ftp_remote_directory_help "Full path without a trailing slash (e.g. '/home/user1/f5_backups/prod'), or relative directory name inside the user's home directory without leading and trailing slashes (e.g. 'f5_backups' or 'f5_backups/prod')."
						}
						editchoice filename_format display "xxlarge" tcl {
							set host [tmsh::get_field_value [lindex [tmsh::get_config sys global-settings] 0] hostname]
							set formats ""
							append formats {${host}_%Y%m%d_%H%M%S => }
							append formats [clock format [clock seconds] -format "${host}_%Y%m%d_%H%M%S"]
							append formats "\n"
							append formats {${host}_%Y%m%d%H%M%S => }
							append formats [clock format [clock seconds] -format "${host}_%Y%m%d%H%M%S"]
							append formats "\n"
							append formats {${host}_%Y%m%d => }
							append formats [clock format [clock seconds] -format "${host}_%Y%m%d"]
							append formats "\n"
							append formats {%Y%m%d_%H%M%S_${host} => }
							append formats [clock format [clock seconds] -format "%Y%m%d_%H%M%S_${host}"]
							append formats "\n"
							append formats {%Y%m%d%H%M%S_${host} => }
							append formats [clock format [clock seconds] -format "%Y%m%d%H%M%S_${host}"]
							append formats "\n"
							append formats {%Y%m%d_${host} => }
							append formats [clock format [clock seconds] -format "%Y%m%d_${host}"]
							append formats "\n"
							return $formats
						}
						message filename_format_help "You can select one, or create your own with all the [clock format] wildcards available in the tcl language, plus ${host} for the hostname. (See http://www.tcl.tk/man/tcl8.6/TclCmd/clock.htm for details.)"
                        message filename_format_help2 "NOTE: When configuring this iApp for HA pairs be sure to include ${host} variable in this Filename Format, otherwise archives may be indistinguishable. When you sync this iApp configuration to the peer you may see the example in this list show the hostname of the device where this iApp was first configured--this is just cosmetic as long as ${host} is used."
                        message filename_format_help3 "NOTE: If the filename format does not include a unique identifier (e.g. datestamp), new Archives may be generated with the same filename and will overwrite old Archives."
						optional ( protocol_enable == "On this F5" || protocol_enable == "Remotely via SMB/CIFS" ) {
							choice pruning_mode display "xlarge" { "Disabled", "Only Prune iApp-Generated Archives", "Prune All Archives" }
                            message pruning_mode_help_disabled "Disabled: Archives will not be automatically deleted by this iApp."
                            message pruning_mode_help_iapp "Only Prune iApp-Generated Archives: Archives generated by this iApp will contain the Unique Pruning Suffix (defined below) so that files generated manually or by other iApps (e.g. when uploaded to a common network share) should not be pruned by this iApp. NOTE: The Unique Pruning Suffix is shared with HA peers, which should be fine as long has the Filename Format includes ${host}."
                            optional ( protocol_enable == "On this F5" ) {
                                message pruning_mode_help_all_local "Prune All Archives: WARNING--This iApp will delete all but the 'newest X Archives' in /var/local/ucs, even if the Archives were generated manually or by a second copy of this iApp."
                                message pruning_mode_help_local "NOTE: The local pruning script runs every 60 seconds."
                            }
                            optional ( protocol_enable == "Remotely via SMB/CIFS" ) {
                                message pruning_mode_help_all_smb "Prune All Archives: WARNING--This iApp will delete all but the 'newest X Archives' in the mounted directory (e.g. //SERVER/SHARE/PATH/DIRECTORY), even if the Archives were copied there manually, by another copy of this iApp running on this BIG-IP, by another BIG-IP, etc.."
                                message pruning_mode_help_smb "NOTE: The SMB/CIFS pruning (check and delete) occurs only one time per Archive upload (immediately after the upload)."
                            }
                            optional ( pruning_mode == "Only Prune iApp-Generated Archives" ) {
                                string pruning_suffix required display "medium"
                                message pruning_suffix_help "Archive names will be generated according to the Filename Format but will also have this Suffix (e.g. 20180510_221532_hostname.example.com_SUFFIX.ucs)."
                            }
                            editchoice pruning_keep_amount default "3" display "small" { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }
						}
					}
				}
				text {
                    deployment_info "Deployment Information"
                    deployment_info.deployment_info_first_time "First Time Deployment:"
                    deployment_info.deployment_info_updates "Testing the iApp:"
                    deployment_info.deployment_info_logs "Logging:"
                    backup_type "Backup Type"
					backup_type.backup_type_select "Select the type of backup:"
					backup_type.backup_passphrase_select "Use a passphrase to encrypt the archive:"
					backup_type.backup_passphrase "What is the passphrase you want to use?"
					backup_type.backup_includeprivatekeys "Include the private keys in the archives?"
					backup_type.backup_help_scf ""
					backup_type.backup_help_scf2 ""
					backup_type.backup_help_passphrase ""
					backup_type.backup_help_privatekeys_ucs ""
					backup_type.backup_help_privatekeys_scf ""
					backup_type.backup_help_restore_scf ""
					backup_schedule "Backup Schedule"
					backup_schedule.frequency_select "Frequency:"
					backup_schedule.everyxminutes_value "Where X equals:"
					backup_schedule.everyxhours_value "Where X equals:"
					backup_schedule.everyxhours_min_select "At what minute of each X hours should the backup occur?"
					backup_schedule.everyxdays_value "Where X equals:"
					backup_schedule.everyxdays_time "At what time on each X days should the backup occur? (Ex.: 15:25)"
					backup_schedule.everyxweeks_value "Where X equals:"
					backup_schedule.everyxweeks_time "At what time on the chosen day of each X weeks should the backup occur? (e.g. 04:15, 21:30)"
					backup_schedule.everyxweeks_dow_select "On what day of each X weeks should the backup should occur:"
					backup_schedule.everyxmonths_value "Where X equals:"
					backup_schedule.everyxmonths_time "At what time on the chosen day of each X months should the backup occur? (e.g. 04:15, 21:30)"
					backup_schedule.everyxmonths_dom_select "On what day of each X months should the backup should occur:"
					backup_schedule.custom_time "At what time on each selected day should the backup occur? (e.g. 04:15, 21:30)"
					backup_schedule.custom_dow_select "Choose the days of the week the backup should occur:"
					destination_parameters "Destination Parameters"
					destination_parameters.protocol_enable "Where do the backup files need to be saved?"
                    destination_parameters.scp_sftp_help "SCP or SFTP?"
					destination_parameters.scp_remote_server "Destination:"
					destination_parameters.scp_remote_server_help ""
					destination_parameters.scp_remote_server_help2 ""
					destination_parameters.scp_source_help "Source IP"
                    destination_parameters.scp_stricthostkeychecking "StrictHostKeyChecking"
                    destination_parameters.scp_stricthostkeychecking_help1 ""
                    destination_parameters.scp_stricthostkeychecking_help2 ""
                    destination_parameters.scp_stricthostkeychecking_trouble1 ""
                    destination_parameters.scp_stricthostkeychecking_trouble2 ""
                    destination_parameters.scp_stricthostkeychecking_warning1 ""
					destination_parameters.scp_remote_username "Username:"
					destination_parameters.scp_sshprivatekey "Copy/Paste the SSH private key to be used for passwordless authentication:"
					destination_parameters.scp_encrypted_field_storage_help ""
					destination_parameters.scp_encrypted_field_storage_help2 ""
					destination_parameters.scp_encrypted_field_storage_help3 ""
					destination_parameters.scp_remote_directory "Remote directory for archive upload:"
					destination_parameters.scp_remote_directory_help ""
                    destination_parameters.scp_cipher "Cipher"
                    destination_parameters.scp_cipher_help ""
					destination_parameters.smb_remote_server "Destination:"
					destination_parameters.smb_remote_server_help ""
					destination_parameters.smb_remote_server_help2 ""
					destination_parameters.smb_source_help "Source IP"
					destination_parameters.smb_remote_username "Username:"
					destination_parameters.smb_remote_domain "Domain Name:"
					destination_parameters.smb_remote_domain_help ""
					destination_parameters.smb_remote_password "Password:"
					destination_parameters.smb_remote_password_help ""
					destination_parameters.smb_remote_password_help2 ""
					destination_parameters.smb_remote_path "SMB/CIFS share name:"
					destination_parameters.smb_remote_path_help ""
					destination_parameters.smb_remote_directory "Target path inside SMB Share:"
					destination_parameters.smb_remote_directory_help ""
					destination_parameters.smb_local_mountdir "Local mount point:"
					destination_parameters.smb_local_mountdir_help ""
 					destination_parameters.ftp_remote_username "Username:"
					destination_parameters.ftp_remote_password "Password:"
					destination_parameters.ftp_remote_password_help ""
					destination_parameters.ftp_encrypted_field_storage_help ""
					destination_parameters.ftp_remote_server "Destination:"
					destination_parameters.ftp_remote_server_help ""
					destination_parameters.ftp_source_help "Source IP"
					destination_parameters.ftp_remote_directory "Remote Directory the Archive should be copied to:"
					destination_parameters.ftp_remote_directory_help ""
					destination_parameters.filename_format "Select the Filename Format:"
					destination_parameters.filename_format_help ""
					destination_parameters.filename_format_help2 ""
					destination_parameters.filename_format_help3 ""
					destination_parameters.pruning_mode "Automatic Pruning Mode:"
                    destination_parameters.pruning_mode_help_disabled ""
                    destination_parameters.pruning_mode_help_iapp ""
                    destination_parameters.pruning_mode_help_all_local ""
                    destination_parameters.pruning_mode_help_local ""
                    destination_parameters.pruning_mode_help_all_smb ""
                    destination_parameters.pruning_mode_help_smb ""
					destination_parameters.pruning_suffix "Unique Filename Suffix:"
					destination_parameters.pruning_suffix_help ""
					destination_parameters.pruning_keep_amount "Amount of files to keep at any given time:"
				}
            }
            role-acl { admin manager resource-admin }
            run-as none
        }
    }
    description none
    ignore-verification false
    requires-bigip-version-max none
    requires-bigip-version-min 11.5.4
    requires-modules { }
    signing-key none
    tmpl-checksum none
    tmpl-signature none
}
