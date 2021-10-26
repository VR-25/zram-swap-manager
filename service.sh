#!/system/bin/sh
log=/dev/.vr25/zram-swap-manager/service.log
mkdir -p ${log%/*}
while [ ! -d /sdcard/Download ]; do sleep 10; done
/data/adb/modules/zram-swap-manager/zram-swap-manager.sh -dr > $log 2>&1
