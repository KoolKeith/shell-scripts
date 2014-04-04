#!/bin/bash

_author="Your name <http://yourwebsite>"
_preservetags="-aperturevalue -shuttervalue -iso -mime -exposuretime -focallength -orientation -exposurebias -flash"
# alle verfuegbaren Tags erhaelt man mit 'exiftool -list'


_file="${1}"
_extention="${_file##*.}"

case $_extention in 
    CR2)
      raw=1
    ;; 
    cr2)
      raw=1
    ;; 
esac

if [[ ${raw} == 1 ]];
then
    kdialog --error "Do not use this on raw files; aborted."
else
    #Remove all data except following...
    exiftool -all= -tagsfromfile @ ${_preservetags} -overwrite_original "${_file}"

    #Add author ...
    exiftool -author="${_author}" -overwrite_original "${_file}"
    kdialog --msgbox "Finished...\nRemoved metadata except \"${_preservetags}\".\nAdded author information \"${_author}\""
fi
