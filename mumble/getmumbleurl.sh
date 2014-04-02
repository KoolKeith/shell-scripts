getmumbleurl() 
{ 
    local _extension="$1";
    local _url=$(curl http://mumble.info/snapshot/ 2>/dev/null | grep -m 1 "${_extension}" | sed -n -r "s#.*\<a href=\"(.*${_extension})\".*#\1#p");
    echo "http://mumble.info/snapshot/$_url"
}

