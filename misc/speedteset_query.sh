#!/bin/bash
_upmin=100
_upmax=0
_downmin=100
_downmax=0

[ -z "$1" ] || [ -z "$2" ] && echo -e "Example: $0 3085991880 3086991880" && exit 1

for id in $(seq ${1} ${2});
do
    _resultfile=/tmp/res.txt
    w3m -dump "http://www.speedtest.net/my-result/${id}" > "${_resultfile}"
   
    if [[ $(wc -l "${_resultfile}" | cut -d' ' -f1) -le 44 ]];
    then
        echo "No data... continue"
        continue
    fi

    _downloadrate=$(grep -i 'download' -A2 ${_resultfile} | grep -v ^$ | grep -v 'Download' | tr -d 'Mb/s')
    _uploadrate=$(grep -i 'upload' -A2 ${_resultfile} | grep -v ^$ | grep -v 'Upload' | tr -d 'Mb/s')

    if [[ $(echo "scale=2; ${_downloadrate} > $_downmax" | bc) -gt 0 ]];
    then
        _downmax=$_downloadrate
        _downmaxid=$id
    fi

    if [[ $(echo "scale=2; ${_downloadrate} < $_downmin" | bc) -gt 0 ]];
    then
        _downmin=$_downloadrate
    fi

    if [[ $(echo "scale=2; ${_uploadrate} > $_upmax" | bc) -gt 0 ]];
    then
        _upmax=$_uploadrate
        _upmaxid=$id
    fi

    if [[ $(echo "scale=2; ${_uploadrate} < $_upmin" | bc) -gt 0 ]];
    then
        _upmin=$_uploadrate
    fi


    clear

    cat << EOF
    Current ID: $id
    Current Downloadrate: $_downloadrate
    Current Uploadrate: $_uploadrate

    MAXIMUM Down/Up: $_downmax/$_upmax
    MINIMUM Down/Up: $_downmin/$_upmin
    ID Max Download: $_downmaxid
    ID Max Upload: $_upmaxid
EOF

    sleep 0.1
    

done 
