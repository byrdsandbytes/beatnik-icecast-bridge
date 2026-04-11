#!/bin/sh
snapclient -h $SNAPSERVER_IP --logsink stderr --player file --mixer none | \
ffmpeg -re -f s16be -ar 44100 -ac 2 -i pipe:0 \
-af "aresample=async=1" \
-codec:a libvorbis -q:a 5 -content_type application/ogg \
-f ogg $ICECAST_URL