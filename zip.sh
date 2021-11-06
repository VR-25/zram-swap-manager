#!/usr/bin/env sh

{ cd "${0%/*}"
cp -u install.sh customize.sh
cp -u install.sh META-INF/com/google/android/update-binary; } 2>/dev/null
zip -r9 zsm-magisk-$(date +%Y%m%d%H%M%S).zip * .git* -x \*.zip -x .git/\*
