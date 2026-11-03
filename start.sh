#!/bin/sh
snapclient -h $SNAPSERVER_IP --logsink stderr --player file --mixer none --sampleformat '44100:16:*' | \
ffmpeg -re -f s16le -ar 44100 -ac 2 -i pipe:0 \
-af "aresample=async=1,alimiter=limit=0.9" \
-codec:a libvorbis -q:a 5 -content_type application/ogg \
-f ogg $ICECAST_URL