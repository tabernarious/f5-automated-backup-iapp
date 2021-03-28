# Currently using tabs (not 4 spaces) throughout these scripts for ease of conversion to a single-line.
# Search for tabs and replace with string "\t"
# Search for newlines and replace with string "\n"
# Copy into main script between 'exec echo -e "' and '" > $scriptfile'

==========
SCP
==========

scp_function()
{
	f5masterkey=\$(f5mku -K)
	username=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	server=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	directory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	echo \"ENCRYPTEDPRIVATEKEY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey} > /var/tmp/TMSHAPPNAME_scp.key

	chmod 600 /var/tmp/TMSHAPPNAME_scp.key
	scp -i /var/tmp/TMSHAPPNAME_scp.key SCPCIPHER SCPSTRICTHOSTKEYCHECKING BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* \${username}@\${server}:\${directory}/ 2>> /var/tmp/scriptd.out
	scp_result=\$?
	rm -f /var/tmp/TMSHAPPNAME_scp.key
	return \$scp_result
}

scp_function


==========
SFTP
==========

sftp_function()
{
	f5masterkey=\$(f5mku -K)
	username=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	server=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	directory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	keyfilepath=\"/var/tmp/TMSHAPPNAME_sftp.key\"
	echo \"ENCRYPTEDPRIVATEKEY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey} > \${keyfilepath}

	# Fix key header formatting if needed
	if \[ \"\$(head -n 1 /var/tmp/TMSHAPPNAME_sftp.key)\" == \"-----BEGIN\" \]
	then
		keyfilelinecount=\$(wc -l \${keyfilepath} |awk \'{print \$1}\')
		awk \'NR==1, NR==4 {print \$0}\' ORS=\' \' \${keyfilepath} > \${keyfilepath}.tmp
		echo >> \${keyfilepath}.tmp
		awk -v count=\"\${keyfilelinecount}\" \'NR==5, NR==count-4 {print \$0}\' \${keyfilepath} >> \${keyfilepath}.tmp
		awk -v count=\"\${keyfilelinecount}\" \'NR==count-3, NR==count {print \$0}\' ORS=\' \' \${keyfilepath} >> \${keyfilepath}.tmp
		echo >> \${keyfilepath}.tmp
		mv \${keyfilepath}.tmp \${keyfilepath}
	fi

	chmod 600 /var/tmp/TMSHAPPNAME_sftp.key
	echo put BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* | sftp -b- -i /var/tmp/TMSHAPPNAME_sftp.key SFTPCIPHER SFTPSTRICTHOSTKEYCHECKING SFTPSSHOPTIONS \${username}@\${server}:\${directory}/ 2>> /var/tmp/scriptd.out
	sftp_result=\$?
	#rm -f /var/tmp/TMSHAPPNAME_sftp.key
	return \$sftp_result
}

sftp_function


==========
FTP
==========

ftp_function()
{
	f5masterkey=\$(f5mku -K)
	username=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	password=\$(echo \"ENCRYPTEDPASSWORD\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	# Escape every character for safe submission of special characters in the password
	password_escaped=\$(echo \${password} | sed \'s/./\\\\\\&/g\')
	server=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	directory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})

	if \[ \"BACKUPFILENAMEEXTENSION_NODOT\" == \"scf\" \]
	then
		ftp_return=\$(ftp -n \${server} << END_FTP
quote USER \${username}
quote PASS \${password_escaped}
binary
put BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT \${directory}/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT
put BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT.tar \${directory}/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT.tar
quit
END_FTP
)
	else
		ftp_return=\$(ftp -n \${server} << END_FTP
quote USER \${username}
quote PASS \${password_escaped}
binary
put BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT \${directory}/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT
quit
END_FTP
)
	fi

	if \[ \"\$ftp_return\" == \"\" \]
	then
		return 0
	else
		echo \"\$ftp_return\" >> /var/tmp/scriptd.out
		return 1
	fi
}

ftp_function


==========
SMB/CIFS
==========

\#\!/bin/sh
f5masterkey=\$(f5mku -K)
username=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
password=\$(echo \"ENCRYPTEDPASSWORD\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
msdomain=\$(echo \"ENCRYPTEDMSDOMAIN\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
server=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
msshare=\$(echo \"ENCRYPTEDMSSHARE\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
mssubdir=\$(echo \"ENCRYPTEDMSSUBDIR\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
mountp=\$(echo \"ENCRYPTEDMOUNTP\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
mountvers=\$(echo \"ENCRYPTEDMOUNTVERS\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
mountsec=\$(echo \"ENCRYPTEDMOUNTSEC\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
cd BACKUPDIRECTORY
if \[ \! -d \${mountp} \]
then
	mkdir -p \${mountp}
	if \[ \$? -ne 0 \]
	then
		rm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*
		exit 1
	fi
fi
\# The password must be surrounded by two single-quotes to successfully handle special characters. Still does not support comma, single-quote, and double-quote.
mount -t cifs //\${server}/\${msshare}\${mssubdir} \${mountp} -o user=\${username}%\'\'\${password}\'\',domain=\${msdomain},vers=\${mountvers},sec=\${mountsec} 2>> /var/tmp/scriptd.out
if \[ \$? -ne 0 \]
	then
	echo \"DEBUG: Failed to mount //\${server}/\${msshare}\${mssubdir}\ to \${mountp}\" >> /var/tmp/scriptd.out
	rm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*
	exit 1
else
	echo \"DEBUG: Successfully mounted //\${server}/\${msshare}\${mssubdir}\ to \${mountp}\" >> /var/tmp/scriptd.out
fi

latestFileOnSMB=\$(ls -t \${mountp}/\*.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null| head -n 1 2>/dev/null)
echo \"DEBUG: Latest BACKUPFILENAMEEXTENSION_NODOT file found on SMB mount: \$latestFileOnSMB\" >> /var/tmp/scriptd.out

if \[ \"X\"\${latestFileOnSMB} \!= \"X\" \]
	then
	sum1=\$(md5sum ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT | awk '{print \$1}')
	sum2=\$(md5sum \${latestFileOnSMB} | awk \'{print \$1}\')
	if \[ \${sum1} == \${sum2} \]
	then
		echo \"ERROR: File ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT already exists in //\${server}/\${msshare}\${mssubdir}\" >> /var/tmp/scriptd.out
		umount \${mountp}
		rm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*
		exit 1
	else
		echo \"DEBUG: File ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT does not already exist in //\${server}/\${msshare}\${mssubdir} (continuing...)\" >> /var/tmp/scriptd.out
	fi
else
	echo \"DEBUG: Destination SMB mount contains no BACKUPFILENAMEEXTENSION_NODOT files (continuing...)\" >> /var/tmp/scriptd.out
fi
cp ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* \${mountp}
rm -f ${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT*

if \[ \"PRUNINGMODE\" \!= \"Disabled\" \]; then

	files_tokeep=\$(ls -t \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null | head -n CONSERVE\)
	for current_archive_file in `ls \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null` ; do
		current_archive_file_basename=`basename \$current_archive_file`
		check_file=\$(echo \$files_tokeep | grep -w \$current_archive_file_basename)
		if \[ \"\$check_file\" == \"\" \] ; then
			rm -f \$current_archive_file
		fi
	done
	if \[ \"BACKUPFILENAMEEXTENSION_NODOT\" == \"scf\" \] ; then
		tar_files_tokeep=\$(ls -t \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null | head -n CONSERVE\)
		for current_archive_tar_file in `ls \${mountp}/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null` ; do
			current_archive_tar_file_basename=`basename \$current_archive_tar_file`
			check_file=\$(echo \$tar_files_tokeep | grep -w \$current_archive_tar_file_basename)
			if \[ \"\$check_file\" == \"\" \] ; then
				rm -f \$current_archive_tar_file
			fi
		done
	fi
fi

umount \${mountp}

echo \"DEBUG: Script completed without errors\" >> /var/tmp/scriptd.out
exit 0


==========
LOCAL PRUNING
==========

files_tokeep=\$(ls -t BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null | head -n CONSERVE\)
for current_archive_file in `ls BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT 2>/dev/null` ; do
	current_archive_file_basename=`basename \$current_archive_file`
	check_file=\$(echo \$files_tokeep | grep -w \$current_archive_file_basename)
	if \[ \"\$check_file\" == \"\" \] ; then
		rm -f \$current_archive_file
	fi
done
if \[ \"BACKUPFILENAMEEXTENSION_NODOT\" == \"scf\" \] ; then
	tar_files_tokeep=\$(ls -t BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null | head -n CONSERVE\)
	for current_archive_tar_file in `ls BACKUPDIRECTORY/*PRUNINGSUFFIX.BACKUPFILENAMEEXTENSION_NODOT.tar 2>/dev/null` ; do
		current_archive_tar_file_basename=`basename \$current_archive_tar_file`
		check_file=\$(echo \$tar_files_tokeep | grep -w \$current_archive_tar_file_basename)
		if \[ \"\$check_file\" == \"\" \] ; then
			rm -f \$current_archive_tar_file
		fi
	done
fi
