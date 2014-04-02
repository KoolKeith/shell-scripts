#!/bin/bash

_temp=$(mktemp -d)
_convertedwav="${_temp}/converted.wav"
_target_dir="$HOME/Desktop/tomobile"

[ ! -d "${_target_dir}" ] || mkdir "${_target_dir}"

#First, convert to wav in /tmp
function convert_to_wav() {
  local _file=${1}
  local _basename=$(basename "${_file}")

  case $(echo "${_file}" | egrep -o '\.ogg$|\.mp3$|\.flac$|\.wav$') in
    .ogg) #Ogg file
                _basename=$(basename "${_file}" .ogg)
                oggdec "${_file}" -o "${_convertedwav}"
                ;;
    .mp3) #MP3 file
                _basename=$(basename "${_file}" .mp3)
                lame --decode "${_file}" "${_convertedwav}"
                ;;
    .flac) #Flac file
                _basename=$(basename "${_file}" .flac)
                flac --decode "${_file}" -o "${_convertedwav}"
        ;;
    .wav) #wav file
                echo #Do nothing, already wav 
                cp "${_file}" "${_convertedwav}"
        ;;
    *) #anything different
                echo "Unknown file type."
                exit 1
                ;;
  esac
}

function convert_to_mobile() {
   local _basename=$(basename "${1}" .wav)
   lame --cbr -m m "${_convertedwav}" "${_target_dir}/${_basename}.mp3"
   echo "Finished"
}

convert_to_wav "${1}"
convert_to_mobile "${1}"
rm "${_convertedwav}"
rmdir "${_temp}"