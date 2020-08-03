# setting up MPD


/etc/mpd.conf

mkdir -p /var/lib/mpd/music
mkdir -p /var/lib/mpd/playlists
chown -R mpd:audio /var/lib/mpd

mkdir -p /var/log/mpd
chown -R mpd:audio /var/log/mpd

sudo bash -c 'cat << EOF > /etc/mpd.conf
bind_to_address "::"
audio_output {    
    type        "httpd"
    name        "My Streaming Radio"
    encoder     "vorbis"
    port        "55555"    
    quality     "6"
    format      "44100:16:2"    
}
EOF'

