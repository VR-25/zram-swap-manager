#!/usr/bin/env sh

version="v2022.1.9 (202201090)"
info="zRAM Swap Manager $version
Upstream repo: github.com/vr-25/zram-swap-manager
Copyright (C) 2021-2022, VR25
License: GPLv3+"

IFS="$(printf ' \t\n')"
temp_dir=/dev/.vr25/zram-swap-manager
magisk_mod=/data/adb/modules/zram-swap-manager
mod_data=/data/adb/vr25/zram-swap-manager-data

calc() {
  awk "BEGIN {print $*}" | xargs printf %.f
}

edit_config() {
  config=/etc/zram-swap-manager.conf
  [ -f $config ] || config=$mod_data/config.txt
  if [ -n "$1" ]; then
    eval "$* $config"
  else
    for i in $EDITOR vim vi nano; do
      which ${i%% *} >/dev/null && {
        eval "$i $config"
        break
      }
    done
  fi
  unset config i
}

hot_add() {
  cat /sys/class/zram-control/hot_add 2>/dev/null || echo 0
}

hot_remove() {
  write /sys/class/zram-control/hot_remove $1
}

mem_estimates() {
  total_mem_before=$(calc "$mem_total / 1024")
  net_gain=$(calc "(($disksize - $mem_limit) / 1024) / 1024")
  total_mem_now=$(calc "$total_mem_before + $net_gain")
  net_gain_percent=$(calc "$net_gain * 100 / $total_mem_before")
  printf "Memory Estimates
  Without zRAM:\t${total_mem_before} MB
  With zRAM:\t${total_mem_now} MB
  Net Gain:\t${net_gain} MB ($net_gain_percent%s)\n" %
  unset total_mem_before total_mem_now net_gain net_gain_percent
}

prep_exec() {
  [ -d /data/adb ] && {
    mkswap() {
      for exec in /data/adb/vr25/bin/mkswap /*/*bin/mkswap /sbin/mkswap mkswap; do
        if [ -x $exec ] || which $exec >/dev/null; then
          eval $exec "$@" && break || echo "(i) Trying alternative: $exec..."
        fi
      done
    }
    swapoff() {
      for exec in /data/adb/vr25/bin/swapoff /*/*bin/swapoff /sbin/swapoff swapoff; do
        if [ -x $exec ] || which $exec >/dev/null; then
          eval $exec "$@" && break || echo "(i) Trying alternative: $exec..."
        fi
      done
    }
    swapon() {
      for exec in /data/adb/vr25/bin/swapon /*/*bin/swapon /sbin/swapon swapon; do
        if [ -x $exec ] || which $exec >/dev/null; then
          eval $exec "$@" && break || echo "(i) Trying alternative: $exec..."
        fi
      done
    }
  }
}

stop_swappinessd() {
  rm $temp_dir/*.lock 2>/dev/null && sleep 2
}

swap_off() {
  stop_swappinessd
  for i in ${swap_device}*; do
    [ -b $i ] || continue
    swapoff $i
    write /sys/block/zram${i#$swap_device}/reset 1
    hot_remove ${i#$swap_device}
  done
  for i in $(awk '/^\//{print $1}' /proc/swaps); do
    swapoff $i
  done
  unset i
}

swap_on() {
  i=$(hot_add)
  write /sys/module/zswap/parameters/enabled 0
  modprobe zram num_devices=1 2>/dev/null
  grep -q $comp_algorithm /sys/block/zram$i/comp_algorithm || {
    case "$(cat /sys/block/zram$i/comp_algorithm)" in
      *zstd*) comp_algorithm=zstd; comp_ratio=288;;
      *lz4*) comp_algorithm=lz4; comp_ratio=210;;
      *lzo-rle*) comp_algorithm=lzo-rle; comp_ratio=212;;
      *lzo*) comp_algorithm=lzo; comp_ratio=211;;
    esac
  }
  for j in max_comp_streams comp_algorithm disksize mem_limit; do
    eval write /sys/block/zram$i/$j \$$j
  done
  mkswap $swap_device$i
  swapon $swap_device$i
  for i in $vm; do
    [ -f /proc/sys/vm/${i%=*} ] && [ -n "${i#*=}" ] && write /proc/sys/vm/${i%=*} ${i#*=}
  done
  unset i j
  ! $dynamic_swappiness || swappinessd
}

swappinessd() {
  stop_swappinessd
  lock_file=$temp_dir/$(date +%s).lock
  touch $lock_file
  (set +x
  exec </dev/null >/dev/null 2>&1
  while [ -f $lock_file ]; do
    load_avg1=$(calc "$(awk '{print $1}' /proc/loadavg) * 100 / $max_comp_streams")
    if [ $load_avg1 -ge $high_load_threshold ]; then
      write /proc/sys/vm/swappiness $high_load_swappiness
    elif [ $load_avg1 -ge $medium_load_threshold ]; then
      write /proc/sys/vm/swappiness $medium_load_swappiness
    elif [ $load_avg1 -ge $low_load_threshold ]; then
      write /proc/sys/vm/swappiness $low_load_swappiness
    fi
    sleep $load_sampling_rate
  done) &
}

write() {
  [ -f $1 ] && echo "$2" > $1 2>/dev/null
}

echo
trap 'e=$?; echo; exit $e' EXIT

# verbose
case $1 in
  -d*)
    shift
    [ -n "$LINENO" ] && export PS4='$LINENO: '
    set -x
  ;;
esac

[ $(id -u) -eq 0 ] || {
  echo "(!) must run as root"
  exit 2
}

mkdir -p $temp_dir

# load user config
for i in "${0}.conf" /etc/zram-swap-manager.conf \
  $mod_data/config.txt
do
  [ -f "$i" ] && {
    . "$i"
    break
  }
done

[ -f $magisk_mod/busybox.sh ] && . $magisk_mod/busybox.sh

# default settings

: ${comp_algorithm:=auto}
: ${comp_ratio:=210}
: ${mem_percent:=33}

: ${mem_total:=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)}
: ${mem_limit:=$(calc "$mem_total * $mem_percent / 100 * 1024")}
: ${disksize:=$(calc "$mem_limit * $comp_ratio / 100")}

: ${max_comp_streams:=$(( $(cut -d- -f2 /sys/devices/system/cpu/present) + 1 ))}
: ${swap_device:=$([ -d /data/adb ] && echo /dev/block/zram || echo /dev/zram)}

: ${dynamic_swappiness:=true}
: ${load_sampling_rate:=60}
: ${high_load_threshold:=90}
: ${high_load_swappiness:=80}
: ${medium_load_threshold:=45}
: ${medium_load_swappiness:=90}
: ${low_load_threshold:=0}
: ${low_load_swappiness:=100}

: ${vm:=swappiness=80 page-cluster=0}

case $1 in
  -*c) shift; edit_config "$@";;
  -*e) mem_estimates;;
  -*n) prep_exec; swap_on;;
  -*f) prep_exec; swap_off;;
  -*v) echo $version;;
  -*r) prep_exec; swap_off 2>/dev/null; swap_on;;
  -*s) swappinessd;;
  -*t) stop_swappinessd; write /proc/sys/vm/swappiness $swappiness;;
  -*u) shift; $magisk_mod/uninstall.sh "$@" 2>/dev/null || zram-swap-manager-uninstall "$@";;
  *) echo "$info

Options:

-d[opt]  verbose (set -x)

-c       edit config w/ \"\$@\" | \$EDITOR | vim | vi | nano
-e       memory estimates
-n       swap_on
-f       swap_off
-v       version
-r       swap_off; swap_on
-s       [re]start swappinessd
-t       stop swappinessd
-u       uninstall";;
esac
