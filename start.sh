#!/bin/sh
snapclient -h $SNAPSERVER_IP --logsink stderr --player file --mixer none --sampleformat '48000:16:*' | \
ffmpeg -re -f s16le -ar 48000 -ac 2 -i pipe:0 \
-af "aresample=async=1" \
-codec:a flac -compression_level 5 -content_type audio/ogg \
-f ogg $ICECAST_URL