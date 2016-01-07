#!/bin/bash
# "GUI" tool to start Mumble :)

_kdialogtext="Choose your mumble client..."
_kdialogstring=""
APPDIR="/home/datenschleuder/apps/mumble"
mumbles=""

function readAvailableMumbles() {
    local _count=0
    for _entry in $(ls -D "${APPDIR}") #List only directories. #Does not work with spaces in dirnames.
    do
        mumbles[$_count]="${_entry}"
        _kdialogstring="${_kdialogstring} ${_count} \"${_entry}\" off"
	_count=$(($_count+1))
    done
}

readAvailableMumbles

_selection=$(kdialog --radiolist "$_kdialogtext" $_kdialogstring)

if [ "$_selection" == "" ];
then
    echo "No selection made. Quitting..."
    exit 1
else
    cd "${APPDIR}/${mumbles[${_selection}]}"
    LD_LIBRARY_PATH=./ ./mumble -m $@ &
    exit 0
fi
