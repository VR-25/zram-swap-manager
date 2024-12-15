#!/usr/bin/env sh


timestamp=$(date +%Y-%m-%d_%H.%M.%S)
filename=zsm_android_${timestamp}.zip

version="$(sed -n 1p changelog.md | sed 's/[*()]//g')"
versionCode=${version#* }
version=${version% *}


set_prop() {
  sed -i -e "s/^($1=.*/($1=$2/" -e "s/^$1=.*/$1=$2/" \
    ${3:-module.prop} 2>/dev/null
}


echo
echo $filename
trap 'e=$?; echo; exit $e' EXIT
cd "${0%/*}" 2>/dev/null

for i in *.sh; do
  sh -n $i || exit
done

sed 's|^#!/.*|#!/sbin/sh|' install.sh > customize.sh
cp -f customize.sh META-INF/com/google/android/update-binary

set_prop version $version
set_prop versionCode $versionCode
sed -i "s/^version=.*/version=\"$version \($versionCode\)\"/" zram-swap-manager.sh


cat << EOF > module.json
{
    "busybox": "https://github.com/Magisk-Modules-Repo/busybox-ndk",
    "changelog": "https://raw.githubusercontent.com/VR-25/zram-swap-manager/master/changelog.md",
    "version": "$version",
    "versionCode": $versionCode,
    "zipUrl": "https://github.com/VR-25/zram-swap-manager/releases/download/$version/zsm_android_${timestamp}.zip"
}
EOF


mkdir -p _builds
zip -r9 _builds/$filename * .git* -x \*.zip -x .git/\* -x '_*/*'
