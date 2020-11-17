#!/bin/bash

# licini0 - Oct. 2020

# USAGE
# You can run this scritp directly using:
# wget -O - https://raw.githubusercontent.com/licini0/my-public-scripts/main/proxmox_6.x_nosubscription_noenterprisesources.sh | bash

# Sources:
# https://github.com/Tontonjo/proxmox/blob/master/pve_nosubscription_noenterprisesources_update.sh
# https://pve.proxmox.com/wiki/Package_Repositories

# I assume you know what you are doing have a backup and have a default configuration.

#1: Remove no subscription message:
echo "- Removing No Valid Subscription Message"
sed -i.bak "s/data.status !== 'Active'/false/g" /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js && systemctl restart pveproxy.service

#2: Defining distribution name:
echo "- Defining distribution name for sources list"
distribution=$(. /etc/*-release;echo $VERSION_CODENAME)

#3: Edit sources list:
echo "- Adding no-subscription entry to sources.list"
sed -i "\$adeb http://download.proxmox.com/debian/pve $distribution pve-no-subscription" /etc/apt/sources.list
echo "- Hiding Enterprise sources list"
sed -i 's/^/#/' /etc/apt/sources.list.d/pve-enterprise.list

#4: Run updates:
echo "- Updating System"
apt-get -y update
apt-get -y dist-upgrade

#5: Restart Proxmox
reboot
