# setting up Network Streaming

# install
sudo apt-get install -y pulseaudio mpd pulseaudio-dlna

# Disable pulseaudio (user mode), so we can run it in system mode
sudo systemctl --global disable pulseaudio.service pulseaudio.socket

# mfp client
sudo apt-get install -y  pasystray pavucontrol paman ncmpcpp 

# All users that need access to PulseAudio have to be in the pulse-access group, even root!
usermod -a -G pulse-access root

# Create mpd and pulseaudio file
touch /etc/mpd.conf

# Create mpd directories

MPDDATA=/var/lib/mpd

mkdir -p ${MPDDATA}/music
mkdir -p ${MPDDATA}/playlists
chown -R mpd:audio ${MPDDATA}

mkdir -p /var/run/mpd
chown -R mpd:audio /var/run/mpd

# Startup 
umask 007 && /usr/bin/pulseaudio --system --daemonize --disallow-exit --disallow-module-loading -vvv

umask 007 && /usr/bin/pulseaudio --realtime --no-cpu-limit --system --verbose --daemonize=no --disallow-exit --disallow-module-loading -vvvvvvvvv

sudo bash -c 'cat << EOF > /etc/mpd.conf
# Files and directories #######################################################
#
# This setting controls the top directory which MPD will search to discover the
# available audio files and add them to the daemons online database. This
# setting defaults to the XDG directory, otherwise the music directory will be
# be disabled and audio files will only be accepted over ipc socket (using
# file:// protocol) or streaming files over an accepted protocol.
#
music_directory         "${MPDDATA}/music"
#
# This setting sets the MPD internal playlist directory. The purpose of this
# directory is storage for playlists created by MPD. The server will use
# playlist files not created by the server but only if they are in the MPD
# format. This setting defaults to playlist saving being disabled.
#
playlist_directory      "${MPDDATA}/playlists"
#
# This setting sets the location of the MPD database. This file is used to
# load the database at server start up and store the database while the
# server is not up. This setting defaults to disabled which will allow
# MPD to accept files over ipc socket (using file:// protocol) or streaming
# files over an accepted protocol.
#
db_file                 "${MPDDATA}/tag_cache"
#
# These settings are the locations for the daemon log files for the daemon.
# These logs are great for troubleshooting, depending on your log_level
# settings.
#
# The special value "syslog" makes MPD use the local syslog daemon. This
# setting defaults to logging to syslog, or to journal if mpd was started as
# a systemd service.
#
log_file                "/var/log/mpd/mpd.log"
#
# This setting sets the location of the file which stores the process ID
# for use of mpd --kill and some init scripts. This setting is disabled by
# default and the pid file will not be stored.
#
pid_file                "${MPDDATA}/pid"
#
# This setting sets the location of the file which contains information about
# most variables to get MPD back into the same general shape it was in before
# it was brought down. This setting is disabled by default and the server
# state will be reset on server start up.
#
state_file              "${MPDDATA}/state"
#
# The location of the sticker database.  This is a database which
# manages dynamic information attached to songs.
#
sticker_file           "${MPDDATA}/sticker.sql"
#
###############################################################################

user                            "mpd"
group                          "audio"
#
# For network
bind_to_address                 "::"
port                            "6600"
#
# This setting controls the type of information which is logged. Available
# setting arguments are "default", "secure" or "verbose". The "verbose" setting
# argument is recommended for troubleshooting, though can quickly stretch
# available resources on limited hardware storage.
#
log_level                       "default"
#
# This setting enables MPD to create playlists in a format usable by other
# music players.
#
#save_absolute_paths_in_playlists       "no"
#
# This setting defines a list of tag types that will be extracted during the
# audio file discovery process. The complete list of possible values can be
# found in the user manual.
#metadata_to_use        "artist,album,title,track,name,genre,date,composer,performer,disc"
#
# This example just enables the "comment" tag without disabling all
# the other supported tags:
#metadata_to_use "+comment"
#
# This setting enables automatic update of MPDs database when files in
# music_directory are changed.
#
auto_update    "yes"
#
# Limit the depth of the directories being watched, 0 means only watch
# the music directory itself.  There is no limit by default.
#
#auto_update_depth "3"
#
###############################################################################


# Symbolic link behavior ######################################################
#
# If this setting is set to "yes", MPD will discover audio files by following
# symbolic links outside of the configured music_directory.
#
#follow_outside_symlinks        "yes"
#
# If this setting is set to "yes", MPD will discover audio files by following
# symbolic links inside of the configured music_directory.
#
#follow_inside_symlinks         "yes"
#
###############################################################################


# Zeroconf / Avahi Service Discovery ##########################################
#
# If this setting is set to "yes", service information will be published with
# Zeroconf / Avahi.
#
zeroconf_enabled                "yes"
#
# The argument to this setting will be the Zeroconf / Avahi unique name for
# this MPD server on the network. %h will be replaced with the hostname.
#
zeroconf_name                  "3RS Music Player"
# zeroconf_name                  "3RS Music Player @ %h"
#
###############################################################################


# Permissions #################################################################
#
# If this setting is set, MPD will require password authorization. The password
# setting can be specified multiple times for different password profiles.
#
password                        "password@read,add,control,admin"
#
# This setting specifies the permissions a user has who has not yet logged in.
#
#default_permissions             "read,add,control,admin"
#
###############################################################################


# Database #######################################################################
#

#database {
#       plugin "proxy"
#       host "other.mpd.host"
#       port "6600"
#}

# Input #######################################################################
#

# Decoder #####################################################################
#

decoder {
    plugin                  "hybrid_dsd"
    enabled                 "no"
    gapless                 "no"
}

# Audio Output

# httpd only allows one stream to be played, and multiple users cannot listen to multiple musics at the same time. 

audio_output {    
    type        "httpd"
    name        "Streaming Radio"
    encoder     "vorbis"
    port        "55555"
    quality     "6"
    format      "44100:16:2"    
    always_on   "yes"
    tags        "yes"
}

audio_output {
    type                            "pulse"
    name                            "Pulse Output - Local"
    mixer_type                      "software"
    always_on                       "yes"
    audio_output_format             "44100:16:2"
    samplerate_converter            "Medium Sinc Interpolator"
    mixer_type                      "software"
    replaygain                      "album"
    volume_normalization            "no"
}

# Normalization automatic volume adjustments ##################################
#
# This setting specifies the type of ReplayGain to use. This setting can have
# the argument "off", "album", "track" or "auto". "auto" is a special mode that
# chooses between "track" and "album" depending on the current state of
# random playback. If random playback is enabled then "track" mode is used.
# See <http://www.replaygain.org> for more details about ReplayGain.
# This setting is off by default.
#
#replaygain                     "album"
#
# This setting sets the pre-amp used for files that have ReplayGain tags. By
# default this setting is disabled.
#
#replaygain_preamp              "0"
#
# This setting sets the pre-amp used for files that do NOT have ReplayGain tags.
# By default this setting is disabled.
#
#replaygain_missing_preamp      "0"
#
# This setting enables or disables ReplayGain limiting.
# MPD calculates actual amplification based on the ReplayGain tags
# and replaygain_preamp / replaygain_missing_preamp setting.
# If replaygain_limit is enabled MPD will never amplify audio signal
# above its original level. If replaygain_limit is disabled such amplification
# might occur. By default this setting is enabled.
#
#replaygain_limit               "yes"
#
# This setting enables on-the-fly normalization volume adjustment. This will
# result in the volume of all playing audio to be adjusted so the output has
# equal "loudness". This setting is disabled by default.
#
volume_normalization            "yes"
#
###############################################################################

# Character Encoding ##########################################################
#
# If file or directory names do not display correctly for your locale then you
# may need to modify this setting.
#
filesystem_charset              "UTF-8"
#
###############################################################################
EOF'

