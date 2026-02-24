FROM debian:bullseye-slim

# Install snapclient and ffmpeg
RUN apt-get update && \
    apt-get install -y snapclient ffmpeg && \
    rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
