#!/usr/bin/env sh

[ $(id -u) -eq 0 ] || {
  printf "\n(!) must run as root\n\n"
  exit 2
}

cd "${0%/*}" 2>/dev/null

if [ -d /data/adb ]; then
  # android
  . $PWD/android/setup-busybox.sh
  install_dir=/data/adb/modules/zram-swap-manager
  data_dir=/data/adb/vr25/zram-swap-manager-data
  rm -rf $install_dir 2>/dev/null
  mkdir -p $install_dir/system/bin $data_dir
  cp $PWD/zram-swap-manager.sh $install_dir/
    ln -sf $install_dir/zram-swap-manager.sh $install_dir/system/bin/zram-swap-manager
      ln -sf $install_dir/zram-swap-manager.sh $install_dir/system/bin/zsm
    ln -sf $install_dir/zram-swap-manager.sh /sbin/zram-swap-manager 2>/dev/null \
      && ln -sf $install_dir/zram-swap-manager.sh /sbin/zsm
  [ -f $data_dir/config.txt ] || cp $PWD/zram-swap-manager.conf $data_dir/config.txt
  cp $PWD/uninstall.sh $install_dir/
    ln -sf $install_dir/uninstall.sh $install_dir/system/bin/zram-swap-manager-uninstall
    ln -sf $install_dir/uninstall.sh /sbin/zram-swap-manager-uninstall 2>/dev/null
  for i in $install_dir/*.sh; do
    sed -i 's|^#!/.*|#!/system/bin/sh|' $i
  done
  unset i
  cp $PWD/android/* $install_dir/
  chmod +x $install_dir/*.sh
  [ ".$1" != .--start ] || $install_dir/service.sh
else
  # gnu/linux
  [ -f /etc/zram-swap-manager.conf ] && upgrade=true
  sh $PWD/uninstall.sh --keep-config >/dev/null 2>&1
  mkdir -p /usr/local/bin/
  install -m 644 $PWD/zram-swap-manager.service /etc/systemd/system/zram-swap-manager.service
  install -m 755 $PWD/zram-swap-manager.sh /usr/local/bin/zram-swap-manager
    ln -s /usr/local/bin/zram-swap-manager /usr/local/bin/zsm
  ${upgrade:-false} || install -m 644 $PWD/zram-swap-manager.conf /etc/
  install -m 755 $PWD/uninstall.sh /usr/local/bin/zram-swap-manager-uninstall
  systemctl enable zram-swap-manager
  [ ".$1" != .--start ] || zram-swap-manager -r
fi
