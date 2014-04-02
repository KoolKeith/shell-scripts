# Push song information of currently played song in mpd.
function m-psi-moc() {
        file=$(mocp -i | sed -n -r 's/File: (.*)/\1/p'); m-psi "$file"
}
 
# Push song information of currently played song in Clementine.
# Uses dbus to get file path.
function m-psi-clementine() {
        file=$(qdbus org.mpris.clementine /Player GetMetadata | sed -n -r 's/location: (.*)/\1/p'); m-psi "${file##*file://}"
}
 
# Push song information of currently played song in Amarok.
# Uses dbus to get file path.
function m-psi-amarok() {
        file=$(qdbus org.mpris.amarok /Player org.freedesktop.MediaPlayer.GetMetadata | sed -n -r 's/location: (.*)/\1/p'); m-psi "$file"
}
 
# Push song information of currently played song in mpd.
function m-psi-mpd() {
        file=$(mpc -f "%file%" | head -1); m-psi "$file"
}
