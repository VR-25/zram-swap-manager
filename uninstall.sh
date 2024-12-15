#!/usr/bin/env sh

[ $(id -u) -eq 0 ] || {
  printf "\n(!) must run as root\n\n"
  exit 2
}

exec 2>/dev/null
rm /dev/.vr25/zram-swap-manager/*.lock

case "$*" in
  *--stop*)
    zram-swap-manager -f \
      || /data/adb/modules/zram-swap-manager/zram-swap-manager.sh -f;;
esac

case "$*" in
  *--keep-config*) :;;
  *)
    rm -rf /etc/zram-swap-manager.conf /data/adb/vr25/zram-swap-manager-data
    rmdir /data/adb/vr25;;
esac

if [ -d /data/adb ]; then
  # android
  rm -rf /data/adb/modules/zram-swap-manager
else
  # gnu/linux
  systemctl disable zram-swap-manager
  rm /usr/local/bin/zsm \
    /usr/local/bin/zram-swap-manager \
    /usr/local/bin/zram-swap-manager-uninstall \
    /etc/systemd/system/zram-swap-manager.service
fi
