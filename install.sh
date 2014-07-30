## Mineblock setup steps

  MINEBLOCK_CONF=/home/pi/mineblock-setup/config
  MINEBLOCK_USER=pi

# TODO: Add speed hacks inc. tmpfs
  cp -v ${MINEBLOCK_CONF}/prepare-dirs /etc/init.d/prepare-dirs && \
    chmod +x /etc/init.d/prepare-dirs && \
    update-rc.d prepare-dirs defaults 01 99

# Hostname setting when /boot/hostname is written
  cp -rv ${MINEBLOCK_CONF}/hostname-change /etc/init.d/hostname-change && \
    chmod +x /etc/init.d/hostname-change && \
    update-rc.d hostname-change defaults 01 99

# setup funky MOTD
  cp -rv ${MINEBLOCK_CONF}/motd.mineblock /etc/ && \
    echo > /etc/motd && \
    cp -rv ${MINEBLOCK_CONF}/motd.service /etc/init.d/motd && \
    /etc/init.d/motd

# use jessie source for updated ALSA, amongst others
  cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i -e 's/ \(stable\|wheezy\)/ testing/ig' /etc/apt/sources.list && \
    apt-get update

# install mineblock essentials, stop mpd from loading on boot
# removed mpd and mpc from installs
  apt-get install -y alsa-utils vim rabbitmq-server && \
#    update-rc.d -f mpd remove

# add ALSA conf to set usb as default audio device
  # cp -v ${MINEBLOCK_CONF}/alsa-base.conf /etc/modprobe.d/alsa-base.conf

# samba && share music
  apt-get install -y samba avahi-daemon && \
    # mkdir /media/music && chmod 777 -R /media/music && \
    mkdir -pv /opt/mineblock && chown 755 -R /opt/mineblock

  cp -v ${MINEBLOCK_CONF}/smb.conf /etc/samba/smb.conf && \
    service samba restart

  cp -v ${MINEBLOCK_CONF}/smb.service /etc/avahi/services/smb.service && \
    cp -v ${MINEBLOCK_CONF}/ssh.service /etc/avahi/services/ssh.service && \
    cp -v ${MINEBLOCK_CONF}/http.service /etc/avahi/services/http.service && \
    service avahi-daemon restart

# wpa_cli
  apt-get install -y ruby1.9.3 ruby-dev && \
    gem install --no-ri --no-rdoc wpa_cli_web foreman procfile-upstart-exporter

  cp -v ${MINEBLOCK_CONF}/wpa-cli-web.conf /etc/init/wpa-cli-web.conf

  cp -v ${MINEBLOCK_CONF}/wifi-configuration.conf /etc/init/wifi-configuration.conf

  apt-get install -y --force-yes dnsmasq && \
    update-rc.d -f dnsmasq remove && \
    cp -v ${MINEBLOCK_CONF}/dnsmasq.conf /etc/dnsmasq.d/dnsmasq.conf

  apt-get install -y hostapd wpasupplicant && \
    update-rc.d -f hostapd remove && \
    cp -v ${MINEBLOCK_CONF}/hostapd.conf /etc/hostapd/hostapd.conf && \
    cp -v ${MINEBLOCK_CONF}/interfaces /etc/network/interfaces && \
    cp -v ${MINEBLOCK_CONF}/rc.local /etc/rc.local && \
    mkdir -pv /opt/mineblock/adhoc && \
    chmod 755 -R /opt/mineblock/adhoc && \
    cp -v ${MINEBLOCK_CONF}/try_adhoc_network /opt/mineblock/adhoc/try_adhoc_network && \
    chmod +x /opt/mineblock/adhoc/try_adhoc_network && \
    cp -v ${MINEBLOCK_CONF}/wpa-conf-copier.conf /etc/init/wpa-conf-copier.conf && \
    cp -v ${MINEBLOCK_CONF}/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf && \
    cp -v ${MINEBLOCK_CONF}/wpa_supplicant.conf /boot/wpa_supplicant.txt

# WiringPi library
  # rm -rfv /tmp/wiringPi && \
  #   mkdir -pv /tmp/wiringPi && \
  #   curl "https://git.drogon.net/?p=wiringPi;a=snapshot;h=master;sf=tgz" | tar xz --strip-components 1 -C /tmp/wiringPi && \
  #   cd /tmp/wiringPi && \
  #   ./build

# nginx
  apt-get install -y --force-yes nginx && \
    cp -v ${MINEBLOCK_CONF}/wpa_cli_web_redirect /etc/nginx/sites-available/wpa_cli_web_redirect && \
    cp -v ${MINEBLOCK_CONF}/mineblock_client /etc/nginx/sites-available/mineblock_client && \
    cp -v ${MINEBLOCK_CONF}/status511.html /opt/mineblock/adhoc/status511.html && \
    chown 755 /opt/mineblock/adhoc/status511.html && \
    rm -v /etc/nginx/sites-enabled/default

# nodejs
  mkdir -pv /opt/node && \
    $(curl -L http://nodejs.org/dist/v0.10.24/node-v0.10.24-linux-arm-pi.tar.gz | tar xz --strip-components 1 -C /opt/node) && \
    ln -sf /opt/node/bin/node /usr/local/bin/node && \
    ln -sf /opt/node/bin/npm /usr/local/bin/npm

# radiodan apps
    curl -L https://github.com/radiodan/radiodan.js/releases/download/v0.3.0/radiodan-server.tar.gz | tar xz -C /opt/mineblock/ && \
      curl -L https://github.com/radiodan/magic-button/releases/download/v0.1.0/radiodan-magic.tar.gz | tar xz -C /opt/mineblock/ && \
      /opt/node/bin/npm -g install forever && \
      cp -v /opt/mineblock/magic/config/radiodan-config.json.example /opt/mineblock/magic/config/mineblock-config.json && \
      cp -v /opt/mineblock/magic/config/physical-ui-config.json.example /opt/mineblock/magic/config/physical-ui-config.json && \
      cp -v ${MINEBLOCK_CONF}/mineblock-server.conf /etc/init && \
      cp -v ${MINEBLOCK_CONF}/mineblock-magic.conf /etc/init


# Install physical UI
  mkdir -pv /opt/mineblock/buttons/ && \
    curl -L https://github.com/radiodan/physical-ui/releases/download/v0.0.1/radiodan-buttons.tar.gz | tar xz --strip-components 1 -C /opt/mineblock/buttons && \
    cp -v ${MINEBLOCK_CONF}/mineblock-buttons.conf /etc/init

# Permissions
  chown -R pi:pi /opt/mineblock/

# Tidying Up

  # cat /dev/null > ~/.bash_history && history -c

# Write the creation time for future reference
  echo "mineblock/provision (`date`)" > /boot/mineblock-provision-info && \
  ln -sf /boot/mineblock-provision-info /opt/mineblock/
