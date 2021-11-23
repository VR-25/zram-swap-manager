#!/usr/bin/env sh

echo
trap 'e=$?; echo; exit $e' EXIT
cd "${0%/*}" 2>/dev/null

for i in *.sh; do
  sh -n $i || exit
done

cp -u install.sh customize.sh 2>/dev/null
cp -u install.sh META-INF/com/google/android/update-binary 2>/dev/null

filename=zsm-$(date +%Y.%m.%d.%H.%M.%S).zip
echo $filename
zip -r9 $filename * .git* -x \*.zip -x .git/\* -x '_*/*'
