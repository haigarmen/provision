  chown -R pi:pi /opt/radiodan/

# Write the creation time for future reference
  echo "radiodan/provision (`date`)" > /boot/radiodan-provision-info && \
  ln -sf /boot/radiodan-provision-info /opt/radiodan/
