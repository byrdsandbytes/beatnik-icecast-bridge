#!/bin/sh
# Optional EBU R128 loudness normalization (set NORMALIZE=true in .env)
if [ "$NORMALIZE" = "true" ]; then
  # loudnorm upsamples internally, so resample back to 44.1 kHz afterwards
  FILTER="aresample=async=1,loudnorm=I=${LOUDNESS_TARGET:--14}:TP=${TRUE_PEAK:--1.0}:LRA=${LOUDNESS_RANGE:-11},aresample=44100"
else
  FILTER="aresample=async=1,alimiter=limit=0.9"
fi

snapclient -h $SNAPSERVER_IP --logsink stderr --player file --mixer none --sampleformat '44100:16:*' | \
ffmpeg -re -f s16le -ar 44100 -ac 2 -i pipe:0 \
-af "$FILTER" \
-codec:a libvorbis -q:a 5 -content_type application/ogg \
-f ogg $ICECAST_URL
