**v2024.12.15 (202412150)**
- [Android]: Wait for boot_completed
- Add vm daemon to enforce vm tweaks
- Fix infinite recursion
- mem_estimates(): Add support for disksize suffixes
- Optimize default config
- Optimize installer
- Prioritize nano over vim, vi.
- Update busybox config
- Update compression ratios
- Update doc & funding info
- Upgrade flashable zip generator
- Use zramctl when available

**v2023.7.17 (202307170)**
- KernelSu support
- Updated documentation
- Various fixes & optimizations

**v2022.3.8 (202203080)**
- Disable dynamic_swappiness on Android by default (misleading /proc/loadavg);
- Do not set mem_limit (causes lockup issues in some kernels);
- Updated documentation and default config.

**v2022.1.9 (202201090)**
- [Android] Do not delay initialization by default.
