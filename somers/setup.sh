# setting up Network Streaming

# install
sudo apt-get install pulseaudio mpd ncmpcpp

# Disable pulseaudio (user mode), so we can run it in system mode
sudo systemctl --global disable pulseaudio.service pulseaudio.socket

# All users that need access to PulseAudio have to be in the pulse-access group, even root!
usermod -a -G pulse-access root

# Create mpd and pulseaudio file
/etc/mpd.conf

# Create mpd directories

mkdir -p /var/lib/mpd/music
mkdir -p /var/lib/mpd/playlists
chown -R mpd:audio /var/lib/mpd

mkdir -p /var/log/mpd
chown -R mpd:audio /var/log/mpd

mkdir -p /var/run/mpd
chown -R mpd:audio /var/log/mpd

# Startup 
umask 007 && /usr/bin/pulseaudio --system --daemonize --disallow-exit --disallow-module-loading -vvv

umask 007 && /usr/bin/pulseaudio --realtime --no-cpu-limit --system --verbose --daemonize=no --disallow-exit --disallow-module-loading -vvvvvvvvv


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

