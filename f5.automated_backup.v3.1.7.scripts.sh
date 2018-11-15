==========
SCP/SFTP
==========

scp_function()
{
	f5masterkey=\$(f5mku -K)
	username=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	server=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	directory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	echo \"ENCRYPTEDPRIVATEKEY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey} > /var/tmp/TMSHAPPNAME_scp.key

	chmod 600 /var/tmp/TMSHAPPNAME_scp.key
	scp -i /var/tmp/TMSHAPPNAME_scp.key SCPCIPHER SCPSTRICTHOSTKEYCHECKING BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* \${username}@\${server}:\${directory} 2>> /var/tmp/scriptd.out
	scp_result=\$?
	rm -f /var/tmp/TMSHAPPNAME_scp.key
	return \$scp_result
}

scp_function

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
# The password must be surrounded by two single-quotes (e.g. ''${password}'') to successfully handle special characters. Still does not support comma, single-quote, and double-quote.
mount -t cifs //\${server}/\${msshare}\${mssubdir} \${mountp} -o user=\${username}%\'\'\${password}\'\',domain=\${msdomain} 2>> /var/tmp/scriptd.out
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
