#Mineblock Quick Provisioner

A set of scripts and configs to take a RaspberryPi from Raspian to a mineblock.

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