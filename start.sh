#!/bin/sh
snapclient -h $SNAPSERVER_IP --logsink stderr --player file --mixer none | \
ffmpeg -f s16le -ar 48000 -ac 2 -i pipe:0 \
-af "volume=0.85,alimiter=limit=0.95" \
-codec:a libmp3lame -b:a 128k -content_type audio/mpeg \
-f mp3 $ICECAST_URL