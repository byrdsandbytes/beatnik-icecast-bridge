# Beatnik Icecast Bridge

A "Silent Bridge" that pipes raw audio data from a Snapcast client directly into an Icecast MP3 stream using a headless Docker container. This setup requires no virtual sound cards or host drivers.

## Overview

- **Input**: Connects to a Snapserver as a client.
- **Processing**: Pipes raw PCM audio from `snapclient` directly to `ffmpeg`.
- **Output**: Encodes audio to MP3 and streams it to an Icecast server.

## Prerequisites

- Docker and Docker Compose installed.
- Access to a running [Snapserver](https://github.com/badaix/snapcast).

## Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd beatnik-icecast-bridge
   ```

2. **Configure Environment Variables**:
   A `.env` file is used to store your configuration. The repository includes a template, but you should create/verify your own:

   ```bash
   # .env
   SNAPSERVER_IP=192.168.1.50
   
   # Icecast Configuration
   ICECAST_SOURCE_PASSWORD=hackme
   ICECAST_ADMIN_PASSWORD=hackme
   ICECAST_PASSWORD=hackme
   ICECAST_RELAY_PASSWORD=hackme
   
   # Internal URL for the bridge to connect to Icecast
   ICECAST_URL=icecast://source:hackme@icecast:8000/stream
   ```

   - `SNAPSERVER_IP`: The IP address of your Snapserver.
   - `ICECAST_URL`: The full URL to stream to the internal Icecast server.
   - `ICECAST_*_PASSWORD`: Passwords for the Icecast server.

## Usage

1. **Build and Run**:
   Use Docker Compose to build the image and start the containers (bridge + icecast) in the background.

   ```bash
   docker compose up -d --build
   ```

2. **View Logs**:
   Check the logs to ensure the connection is established and audio is streaming.

   ```bash
   docker compose logs -f
   ```

3. **Stop**:
   To stop the bridge:

   ```bash
   docker compose down
   ```

## wrapper script

The audio pipeline logic is contained in `start.sh`:

```bash
#!/bin/sh
snapclient -h $SNAPSERVER_IP --logsink stderr --player file | \
ffmpeg -f s16le -ar 48000 -ac 2 -i pipe:0 \
-codec:a libmp3lame -b:a 128k -content_type audio/mpeg \
-f mp3 $ICECAST_URL
```
