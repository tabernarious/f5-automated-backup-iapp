# Currently using tabs (not 4 spaces) throughout these scripts for ease of conversion to a single-line.
# Search for tabs and replace with string "\t"
# Search for newlines and replace with string "\n"
# Copy into main script between 'exec echo -e "' and '" > $scriptfile'

sftp_function()
{
	f5masterkey=\$(f5mku -K)
	username=\$(echo \"ENCRYPTEDUSERNAME\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	server=\$(echo \"ENCRYPTEDSERVER\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	directory=\$(echo \"ENCRYPTEDDIRECTORY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey})
	echo \"ENCRYPTEDPRIVATEKEY\" | openssl aes-256-ecb -salt -a -A -d -k \${f5masterkey} > /var/tmp/TMSHAPPNAME_sftp.key

	chmod 600 /var/tmp/TMSHAPPNAME_sftp.key
	echo put BACKUPDIRECTORY/${fname_noext}BACKUPFILENAMEEXTENSION_WITHDOT* | sftp -b- -i /var/tmp/TMSHAPPNAME_sftp.key SFTPCIPHER SFTPSTRICTHOSTKEYCHECKING SFTPSSHOPTIONS \${username}@\${server}:\${directory}/ 2>> /var/tmp/scriptd.out
	sftp_result=\$?
	rm -f /var/tmp/TMSHAPPNAME_sftp.key
	return \$sftp_result
}

sftp_function
