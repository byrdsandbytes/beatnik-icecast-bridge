# Audio Pipeline & Tuning Guide

Piping raw digital audio (PCM) from a headless `snapclient` directly into `ffmpeg` requires precise configurations. Because the audio pipe has no header metadata, `ffmpeg` has to pull the raw binary data blind. If the options are slightly off, you can experience extreme static, loud clipping, quantization noise, or pitch/speed drift.

This document serves as a reference for all the variables, flags, and codecs used in `start.sh` to ensure perfect stream quality.

## Snapclient Variables

*   `--player file`: Instructs Snapclient to output raw PCM data to a file pipe (or `stdout`) rather than attempting to connect to a physical soundcard (ALSA).
*   `--mixer none`: Bypasses Snapclient's software volume control and outputs the audio at exactly 100% digital volume. 
    *   *Why we use it:* Lowering software volume on 16-bit audio creates "quantization noise" (a static hiss). Using `--mixer none` ensures the raw data is untouched, allowing you to control the volume purely at the destination app/hardware.

## FFmpeg Input Variables (Reading the Raw Pipe)

Because the `snapclient` pipe is raw binary without a WAV header, `ffmpeg` must be told strictly how to interpret the 1s and 0s. 

*   `-i pipe:0`: Tells FFmpeg to read its input from standard input (`stdin`).
*   `-f s16be`: (Signed 16-bit Big-Endian). The data format. If this doesn't match the source exactly, you will hear violently loud static or extreme distortion. 
    *   *Alternative values*: `-f s16le` (Little-Endian), `-f s24le`, `-f s32le`. If your audio blasts maximum volume static until you turn the volume down to 1%, it's usually an endianness mismatch (`s16le` vs `s16be`).
*   `-ar 44100` / `-ar 48000`: The Audio Sample Rate (in Hz). 
    *   If FFmpeg is expecting `44100` but the source provides `48000`, the audio will play noticeably **too fast** (chipmunk effect). 
    *   If FFmpeg expects `48000` but the source provides `44100`, the audio will play **too slow** and deep.
*   `-ac 2`: Assumes the input has 2 audio channels (Stereo).

## FFmpeg Timing & Speed (Fixing the Pitch Drift)

Snapclient does not have a physical audio clock when using the `file` player. To prevent it from trying to warp the speed of the audio to stay artificially "in sync", we have to generate a strict software clock.

*   `-re`: Forces FFmpeg to read the input at exactly the native frame rate (1 real second of audio per second). This acts as a physical back-pressure to keep Snapclient from drifting.
*   `-af "aresample=async=1"`: An audio filter that dynamically stretches or squeezes micro-jitter in the timestamps without changing the pitch of the music.

## Audio Filters (Removed/Optional)

*   `volume=0.85` or `volume=0.05`: Mathematically reduces the amplitude of the audio waves. Useful if you have a massive bit-depth mismatch, but degrades audio. It is better to use `--mixer none` in Snapcast and a perfectly matched `-f` parameter.
*   `alimiter=limit=0.99`: Acts as a brick-wall limiter to prevent digital clipping. However, running active limiters on a Raspberry Pi can introduce CPU lag and cause stream "hiccups". With a perfectly matched pipeline, limiters are unnecessary.

## Output Codecs (Icecast Formats)

Depending on your requirements for stream compatibility vs stream quality, you can encode to different formats:

### 1. MP3 (Maximum Compatibility)
Universally playable on any hardware or browser. It is less efficient than modern codecs, so it requires higher bitrates to sound good.
```bash
-codec:a libmp3lame -b:a 320k -content_type audio/mpeg -f mp3
```

### 2. Ogg Vorbis (Native Icecast / High Quality)
Provides excellent, transparent audio quality and native gapless playback support on Icecast servers. (Currently used in this setup).
```bash
-codec:a libvorbis -q:a 5 -content_type application/ogg -f ogg
```
*(Note: `-q:a 5` sets a variable bitrate quality target roughly equivalent to 160-192kbps).*

### 3. AAC (Modern Balance)
Excellent audio quality even at lower bitrates, and natively supported by almost all modern web and mobile browsers.
```bash
-codec:a aac -b:a 192k -content_type audio/aac -f adts
```