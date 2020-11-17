## How to stop the IKEA Eneby from going to sleep while on AUX
for a raspberry pi, or debian-based device connected by 3.5mm jack.

tested on dietpi distro running on Rpi B gen 1 with shairplay-sync

### Download quiet low tone file, rename to 15tone.wav

From the root user home folder (~/ when logged in to root)

`wget https://s.put.re/w8s9Lk5A.wav -O /root/15tone.wav`

### Create script to detect audio-playback, and if not play silent tone

`nano playsoundifnotplaying.sh`

copy paste the follow script:

```
#!/bin/bash
if grep -q RUNNING /proc/asound/card*/*p/*/status 2>&1; then
   echo "Audio playing, not doing anything"
else
   echo "No audio playing, playing silent tone"
   aplay /root/15tone.wav
fi
```

ctrl:x to save and exit

then make the script executable:

`chmod +x ./playsoundifnotplaying.sh`

you can test the script by running `./playsoundifnotplaying.sh` 

### Add to following to crontab, for the script to run every 15 minutes (Eneby sleep time is 20min):

open crontab

`crontab -e`

add the line:

`*/15 * * * * /bin/bash /root/playsoundifnotplaying.sh >/dev/null 2>&1`

ctrl:x to save and exit

### You might hear a quiet "pop" every 15 minutes or so when no audio is otherwise playing.



Sources :
https://gist.githubusercontent.com/Porco-Rosso/17df8a06b2cbf654c191a116901bc421/raw/4d23972baf77ac8892856bc2a5c29b217ad6b9f4/keepEnebyAwake.md
