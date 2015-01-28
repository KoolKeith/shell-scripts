# Examples:
# getmumbleurl mumble .msi
# getmumbleurl mumble .msi x64 # for 64 bit Windows version
# getmumbleurl mumble .tar.gz

getmumbleurl() 
{ 
    local _prefix="$1";
    local _extension="$2";

    if [ ${_extension} = ".msi" ];
    then
        if [[ ${3} = "x64" ]];
        then
            local _url=$(curl http://mumble.info/snapshot/ 2>/dev/null | grep "${_prefix}" | grep x64 | grep -m 1 "${_extension}\"" | sed -n -r "s#.*\<a href=\"(.*${_extension})\".*#\1#p");
        else
            local _url=$(curl http://mumble.info/snapshot/ 2>/dev/null | grep "${_prefix}" | grep -v x64 | grep -m 1 "${_extension}\"" | sed -n -r "s#.*\<a href=\"(.*${_extension})\".*#\1#p");
        fi
    else
        local _url=$(curl http://mumble.info/snapshot/ 2>/dev/null | grep "${_prefix}" | grep -m 1 "${_extension}\"" | sed -n -r "s#.*\<a href=\"(.*${_extension})\".*#\1#p");
    fi
    echo "http://mumble.info/snapshot/$_url"
}
