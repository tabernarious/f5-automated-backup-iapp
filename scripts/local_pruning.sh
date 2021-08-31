# Currently using tabs (not 4 spaces) throughout these scripts for ease of conversion to a single-line.
# Search for tabs and replace with string "\t"
# Search for newlines and replace with string "\n"
# Copy into main script between 'exec echo -e "' and '" > $scriptfile'

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
