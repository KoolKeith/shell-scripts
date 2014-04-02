function m-psi() {
        _file="${1}"
 
        # Print help if needed :)
        if [ $# -lt 1 ] 
        then
            echo -e "Usage:\n  music_psi /path/to/file\n"
            return 1
        fi  
 
        # Read settings or exit if file does not exist.
        [[ -f ~/.psi-settings.conf ]] && . ~/.psi-settings.conf || exit 255 
 
        if [ "$( echo ${_file} | cut -c1)" != "/" ]
        then
           #In case of mpd we get the relative path of the file. It does not start with /. In this case, add the musicdir path of mpd.
           _file="${_mpd_musicdir}/${file}"
        fi  
        _date=$(date "+%Y-%m-%d %H:%M %z")
 
        # File header
        echo "blablahtmlcodehiernichtverwendetwegencodeblock :P" > ${_songinfo_file_local}
 
        # Write metadata into the file. Remove the _hide_path string from the absolute file path
        # in order to save privacy of how your filesystem is organized :)
        # For example: _hide_path is "/home/username/musicdir" and your filepath
        # is "/home/username/musicdir/bass/lala.mp3" then the result is:
        # /bass/lala.ogg
        m-printtaginfo "${_file}" 0 | sed s+"${_hide_path}"++g >> "${_songinfo_file_local}"
 
        # File footer
        echo "blablahtmlcodehiernichtverwendetwegencodeblock :P" >> ${_songinfo_file_local}
 
        # Copy file to remote host.
        scp -P ${_remote_port} -i "${_ssh_identity_file}" "${_songinfo_file_local}" "${_remote_user}@${_remote_ip}:${_songinfo_file_remote}"
 
        # Remove temporary file.
        rm ${_songinfo_file_local}
}
