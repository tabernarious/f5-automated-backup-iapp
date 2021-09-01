# Currently using tabs (not 4 spaces) throughout these scripts for ease of conversion to a single-line.
# Search for tabs and replace with string "\t"
# Search for newlines and replace with string "\n"
# Copy into main script between 'exec echo -e "' and '" > $scriptfile'

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
