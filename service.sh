#!/system/bin/sh
log=/data/adb/vr25/zram-swap-manager-data/logs/service.log
mkdir -p ${log%/*}
${0%/*}/zram-swap-manager.sh -dr > $log 2>&1
exit 0
