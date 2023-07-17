#!/usr/bin/env sh

echo
trap 'e=$?; echo; exit $e' EXIT
cd "${0%/*}" 2>/dev/null

for i in *.sh; do
  sh -n $i || exit
done

sed 's|^#!/.*|#!/sbin/sh|' install.sh > customize.sh
cp -f customize.sh META-INF/com/google/android/update-binary

filename=zsm_android_$(date +%Y-%m-%d_%H:%M:%S).zip
echo $filename
zip -r9 $filename * .git* -x \*.zip -x .git/\* -x '_*/*'
