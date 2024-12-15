# zRAM Swap Manager

## Foreword
    This program comes with absolutely no warranty.
    Use it at your own risk.
    Refer to the official kernel docs, ArchWiki and/or other reputable sources for information regarding virtual memory configuration, zRAM, zswap, and swap in general.
    Most users should be served by the default config.
    Advanced users will probably want to tweak a thing or two.

## License
    Copyright (C) 2021-2024, VR25

    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along with this program. If not, see https://www.gnu.org/licenses/.

## Generate a Flashable Zip (Apatch/KernelSU/Magisk)
    sh /path/to/zip.sh

## Install/Upgrade
    Android
      Flash the zip or run su -c sh /path/to/install.sh
      [Optional] Edit /data/adb/vr25/zram-swap-manager-data/config.txt
      Reboot

    GNU/Linux
      sudo sh /path/to/install.sh [--start]

## Uninstall
    Android
      su -c /data/adb/modules/zram-swap-manager/uninstall.sh [[--stop] [--keep-config]]
      Alternatively, use a module manager app and reboot

    GNU/Linux
      sudo zram-swap-manager-uninstall [[--stop] [--keep-config]]

## Config
    Android
      /data/adb/vr25/zram-swap-manager-data/config.txt

    GNU/Linux
      /etc/zram-swap-manager.conf

## Terminal
    Run zsm or zram-swap-manager for help.

## Notes/Tips
    - Note: One can set disksize instead of comp_ratio and mem_percent. It supports suffixes, as per the official kernel doc (e.g., disksize=1M, disksize=2G).
    - On some Android systems, one may want to delay initialization to ensure defaults and/or third party tweaks are overridden. This can be done by adding `sleep 90` or a more elaborate logic to config.
    - To disable swap on boot, add "swap_off; exit" to config, without quotes.
    - To skip applying settings on boot add exit to config.

## Links

- [zRAM ArchWiki](https://wiki.archlinux.org/title/Zram)
- [zRAM Official Kernel Doc](https://docs.kernel.org/admin-guide/blockdev/zram.html)
- [zRAM Performance Analysis](https://notes.xeome.dev/notes/Zram)

- [Facebook Page](https://fb.me/vr25xda)
- [Telegram Channel](https://t.me/vr25_xda)
- [Telegram Profile](https://t.me/vr25xda)
- [Upstream Repository](https://github.com/vr-25/zram-swap-manager)
- [XDA Thread](https://forum.xda-developers.com/t/zram-swap-manager-for-android-and-gnu-linux-systems.4352797)

- [Donate - Patreon](https://patreon.com/vr25)
- [Donate - PayPal](https://paypal.me/vr25xda)
- [Donate - Credit/Debit Card](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=iprj25@gmail.com&lc=US&item_name=VR25+is+creating+free+and+open+source+software.+Donate+to+suppport+their+work.&no_note=0&cn=&currency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted)
