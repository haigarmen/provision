#Mineblock Pi Quick Provisioner

A set of scripts and configs to take a vanilla RPi to a Mineblock RPi.

How to
---

These instructions assume you're starting from a blank disk image of Raspbian.

1. Log into the Raspberry Pi
2. `sudo raspi-config` to Expand filesystem and Overclock (900MHz), Restart
3. Log in again
4. `git clone https://github.com/haigarmen/provision`
5. `cd provision`
6. `sudo sh prepare.sh`
7. `sudo reboot`
8. `sudo sh install.sh`

Quick way
-----

1. Log into the Raspberry Pi
2. `sudo raspi-config` to Expand filesystem and Overclock (900MHz), Restart
3. Log in again
4. curl -L http://git.io/lhbivA | sudo sh
5. `sudo reboot`
6. `cd mineblock-setup`
7. `sudo sh install.sh`
