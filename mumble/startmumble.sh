#!/bin/bash
APPDIR="/home/apps/mumble"

mumbles=""

function getmumbles() {
    local _count=0
    for _entry in $(ls -D "${APPDIR}") #List only directories. #Does not work with spaces in dirnames.
    do  
        mumbles[$_count]="${_entry}"
        _count=$(($_count+1))
    done
}

function choosemumbles() {
    printf "Choose a mumble instance to start and press [Enter]:\n"

    local _count=0
    for _entry in ${mumbles[@]}
    do  
      printf "%i - %s\n" $_count "${_entry}"
      _count=$(($_count+1))
    done
    printf "\n> " 
}

getmumbles
choosemumbles
read _selection

cd "${APPDIR}/${mumbles[${_selection}]}"
LD_LIBRARY_PATH=./ ./mumble $@