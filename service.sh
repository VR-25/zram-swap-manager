#!/system/bin/sh
log=/data/adb/vr25/zram-swap-manager-data/logs/service.log
mkdir -p ${log%/*}
while [ $(getprop sys.boot_completed) != 1 ]; do
  sleep 5
done
${0%/*}/system/bin/zsm -dr > $log 2>&1
exit 0
