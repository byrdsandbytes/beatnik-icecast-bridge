#!/bin/sh
snapclient -h $SNAPSERVER_IP --logsink stderr --player file | \
ffmpeg -f s16le -ar 44100 -ac 2 -i pipe:0 \
-codec:a libmp3lame -b:a 128k -content_type audio/mpeg \
-f mp3 $ICECAST_URL
