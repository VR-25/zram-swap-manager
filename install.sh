#!/usr/bin/env sh

[ $(id -u) -eq 0 ] || {
  printf "\n(!) must run as root\n\n"
  exit 2
}

# set source code directory
src="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"

# for magisk
SKIPUNZIP=1

if [ -d /data/adb ]; then

  # android

  # extract flashable zip if source code is unavailable
  [ -f $src/TODO ] || {
    src=/dev/.vr25-zsm-install
    on_exit() { rm -rf ${src:-//} 2>/dev/null; }
    on_exit
    trap on_exit EXIT
    mkdir $src
    unzip "${3:-${ZIPFILE}}" -d $src/ >&2
  }

  . $src/busybox.sh

  install_dir=/data/adb/modules/zram-swap-manager
  data_dir=/data/adb/vr25/zram-swap-manager-data

  rm -rf $install_dir 2>/dev/null
  mkdir -p $install_dir/system/bin $data_dir

  cp $src/zram-swap-manager.sh $install_dir/
    ln -sf $install_dir/zram-swap-manager.sh $install_dir/system/bin/zram-swap-manager
      ln -sf $install_dir/zram-swap-manager.sh $install_dir/system/bin/zsm
    ln -sf $install_dir/zram-swap-manager.sh /sbin/zram-swap-manager 2>/dev/null \
      && ln -sf $install_dir/zram-swap-manager.sh /sbin/zsm

  [ -f $data_dir/config.txt ] || cp $src/zram-swap-manager.conf $data_dir/config.txt

  cp $src/uninstall.sh $install_dir/
    ln -sf $install_dir/uninstall.sh $install_dir/system/bin/zram-swap-manager-uninstall
    ln -sf $install_dir/uninstall.sh /sbin/zram-swap-manager-uninstall 2>/dev/null

  for i in $install_dir/*.sh; do
    sed -i 's|^#!/.*|#!/system/bin/sh|' $i
  done

  i="$PWD"
  cd $src/
  cp busybox.sh module.prop service.sh $install_dir/
  cd "$i"
  unset i
  chmod +x $install_dir/*.sh
  [ ".$1" != .--start ] || $install_dir/service.sh

else

  # gnu/linux

  [ -f /etc/zram-swap-manager.conf ] && upgrade=true
  sh $src/uninstall.sh --keep-config >/dev/null 2>&1
  mkdir -p /usr/local/bin/

  install -m 644 $src/zram-swap-manager.service /etc/systemd/system/zram-swap-manager.service

  install -m 755 $src/zram-swap-manager.sh /usr/local/bin/zram-swap-manager
    ln -s /usr/local/bin/zram-swap-manager /usr/local/bin/zsm

  ${upgrade:-false} || install -m 644 $src/zram-swap-manager.conf /etc/
  install -m 755 $src/uninstall.sh /usr/local/bin/zram-swap-manager-uninstall

  systemctl enable zram-swap-manager
  [ ".$1" != .--start ] || zram-swap-manager -r

fi

echo "Done!"
