# HOW-TO INSTALL A MULTIROOM

## Before starting... please read me...
This guide will help to install a multiroom system based on a server with multiple sources streaming to multiple client devices.
I assume the central server is runing Ubuntu Desktop 20.04 LTS out of the box with all the current updates.
The clients are raspberry devices connected to speakers.

**Sources examples:**<br/>
1 or multiple Spotify Connect<br/>
1 or multiple radio web stream<br/>
Bluetooth receiver<br/>
Any other software or hardware able to output to a fifo file

**Diagram:**<br/>
Source ---> fifo file -------> Snapcast server ----> network ----> Snapcast client

**What will we achieve in this how-to?**<br/>
We will have 4 sources (3 spotify connect + 1 webradio with mutiple webradio streams available) streaming to as many devices as we wish.

## Installing the server side
I want a lightweight server, so let's remove the GUI (yes, I could use Ubuntu server instead of desktop but then some depedencies are missing and therefore the result is the same), but before that I will enable ssh to be able to manage the server without the need of a screen.

### - Install ssh on Ubuntu Desktop 20.04
```
sudo apt install ssh
sudo systemctl enable --now ssh
```
  
### - Start Ubuntu Desktop 20.04 without GUI
```
sudo cp -n /etc/default/grub /etc/default/grub.orig
sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT/#GRUB_CMDLINE_LINUX_DEFAULT/g' /etc/default/grub
sudo sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="text"/g' /etc/default/grub
sudo sed -i 's/#GRUB_TERMINAL/GRUB_TERMINAL/g' /etc/default/grub
sudo update-grub && sudo systemctl set-default multi-user.target
sudo reboot
```
  
##### If I need to put back the GUI, I simply use these commands:
```
sudo mv /etc/default/grub.orig /etc/default/grub && sudo update-grub
sudo systemctl set-default graphical.target
```

### - Installing snapserver
```
wget https://github.com/badaix/snapcast/releases/download/v0.22.0/snapserver_0.22.0-1_amd64.deb
sudo dpkg -i snapserver_0.22.0-1_amd64.deb
sudo update-rc.d snapserver enable
sudo sed -i 's/source = pipe:\/\/\/tmp\/snapfifo?name=default/source = pipe:\/\/\/tmp\/snapspotu1?name=SpotifyUser1&sampleformat=44000:16:2\nsource = pipe:\/\/\/tmp\/snapspotu2?name=SpotifyUser2&sampleformat=44000:16:2\nsource = pipe:\/\/\/tmp\/snapspotu3?name=SpotifyUser3&sampleformat=44000:16:2\nsource = pipe:\/\/\/tmp\/snapradios?name=Radios/g' /etc/snapserver.conf
sudo systemctl restart snapserver
```

### - Installing librespot (Spotify client) from sources
```
sudo apt install -y build-essential cargo libasound2-dev git

git clone https://github.com/librespot-org/librespot.git
cd librespot
cargo build --release
cd target/release
sudo mkdir -p /opt/librespotu1/ && sudo mkdir -p /opt/librespotu2/ && sudo mkdir -p /opt/librespotu3/
sudo mv * /opt/librespotu1/
cd .. && cd ..
cargo build --release
cd target/release
sudo mv * /opt/librespotu2/
cd .. && cd ..
cargo build --release
cd target/release
sudo mv * /opt/librespotu3/

sudo touch /usr/local/bin/librespotu1 && sudo touch /usr/local/bin/librespotu2 && sudo touch /usr/local/bin/librespotu3

echo '#!/bin/bash' | sudo tee -a /usr/local/bin/librespotu1
echo '##Librespot runner' | sudo tee -a /usr/local/bin/librespotu1
echo 'cd /opt/librespot-l/' | sudo tee -a /usr/local/bin/librespotu1
echo 'sudo ./librespot -n "Multiroom" -u aaaaaaaaaaa -p bbbbbbbbbbbbbbb --backend pipe --device /tmp/snapspotl -b 320 -c ./cache --enable-volume-normalisation --disable-discovery --autoplay --initial-volume 100 --device-type avr' | sudo tee -a /usr/local/bin/librespotu1
echo '#!/bin/bash' | sudo tee -a /usr/local/bin/librespotu2
echo '##Librespot runner' | sudo tee -a /usr/local/bin/librespotu2
echo 'cd /opt/librespot-i/' | sudo tee -a /usr/local/bin/librespotu2
echo 'sudo ./librespot -n "Multiroom" -u aaaaaaaaa -p bbbbbbbbbb --backend pipe --device /tmp/snapspoti -b 320 -c ./cache --enable-volume-normalisation --disable-discovery --autoplay --initial-volume 100 --device-type avr' | sudo tee -a /usr/local/bin/librespotu2
echo '#!/bin/bash' | sudo tee -a /usr/local/bin/librespotu3
echo '##Librespot runner' | sudo tee -a /usr/local/bin/librespotu3
echo 'cd /opt/librespot-m/' | sudo tee -a /usr/local/bin/librespotu3
echo 'sudo ./librespot -n "Multiroom" -u aaaaaaaaaaaa -p bbbbbbbbbbbbbbb --backend pipe --device /tmp/snapspotm -b 320 -c ./cache --enable-volume-normalisation --disable-discovery --autoplay --initial-volume 100 --device-type avr' | sudo tee -a /usr/local/bin/librespotu3

sudo chmod +x /usr/local/bin/librespotu1 && sudo chmod +x /usr/local/bin/librespotu2 && sudo chmod +x /usr/local/bin/librespotu3
sudo chmod 755 /opt/librespotu1/ && sudo chmod 755 /opt/librespotu2/ && sudo chmod 755 /opt/librespotu3/
sudo reboot
```

## - Installing the client side
```
sudo apt-get update && sudo apt-get -y install libavahi-client3 libavahi-common3 libflac8 libopus0 libsoxr0 libvorbisenc2 avahi-daemon
wget https://github.com/badaix/snapcast/releases/download/v0.22.0/snapclient_0.22.0-1_armhf.deb
sudo dpkg -i snapclient_0.22.0-1_armhf.deb
sudo sed -i 's/SNAPCLIENT_OPTS=""/SNAPCLIENT_OPTS="--host aaaaaaaaaa"/g' /etc/default/snapclient
sudo update-rc.d snapclient enable
```

## Some usefull commands for maintenance

**Restart snapcast server:**<br/>
`sudo systemctl restart snapserver`

**Verify snapcast server status:**<br/>
sudo systemctl status snapserver`

**Restart snapclient:**<br/>
`sudo systemctl restart snapclient`

**Verify snapclient status:**<br/>
`sudo systemctl status snapclient`

## Sources
https://www.addictivetips.com/ubuntu-linux-tips/listen-spotify-from-the-linux-terminal-with-librespot/<br/>
https://mondedie.fr/d/10750-tuto-multiroom-audio-avec-snapcast-sur-un-rpi<br/>
https://snapcraft.io/blog/ubuntu-core-smart-speaker<br/>
https://ubuntuforums.org/showthread.php?t=2422283<br/>
https://github.com/librespot-org/librespot<br/>
https://github.com/badaix/snapcast/releases<br/>
https://www.youtube.com/watch?v=0YnSwYFpzDA<br/>
https://www.youtube.com/watch?v=eQC6nTzvCbU<br/>
https://docs.mopidy.com/en/latest<br/>
