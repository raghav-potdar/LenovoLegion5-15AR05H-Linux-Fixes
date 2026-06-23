# Lenovo Legion 5 (15ARH05H) — Ubuntu 24.04 Hybrid Graphics Fixes

Documentation of issues encountered (and fixed) running Ubuntu on a Lenovo Legion 5
15ARH05H with AMD iGPU + NVIDIA GTX 1660 Ti hybrid graphics. Written up so future-me
(or anyone else on similar hardware) doesn't have to rediscover all of this from scratch.

## System

| Component | Spec |
|---|---|
| Model | Lenovo Legion 5 15ARH05H |
| iGPU | AMD Renoir (drives display in hybrid mode) |
| dGPU | NVIDIA GTX 1660 Ti |
| OS | Ubuntu 24.04 |
| Kernel | 6.17 |
| Desktop | GNOME (Wayland) |

## Disk Layout

**nvme0n1** (476.9 GB) — Windows drive

| Partition | Size | Filesystem | Notes |
|---|---|---|---|
| nvme0n1p1 | 100 MB | vfat | Windows EFI |
| nvme0n1p2 | 16 MB | — | Microsoft reserved |
| nvme0n1p3 | 476 GB | ntfs | Windows C: |
| nvme0n1p4 | 802 MB | ntfs | Windows recovery |

**nvme1n1** (931.5 GB) — Linux drive

| Partition | Size | Filesystem | Mount |
|---|---|---|---|
| nvme1n1p1 | 954 MB | vfat | /boot/efi |
| nvme1n1p2 | 93.1 GB | btrfs | / |
| nvme1n1p3 | 29.8 GB | swap | [SWAP] — 2× RAM (16 GB), required for hibernate |
| nvme1n1p4 | 372.5 GB | btrfs | /home |

## Reinstallation Notes

- **Separate EFI partitions per drive is intentional.** Ubuntu's entire stack (EFI, `/`, swap, `/home`) lives on `nvme1n1`. To remove Ubuntu cleanly, just reformat `nvme1n1` — Windows on `nvme0n1` is completely unaffected.
- **Windows Update cannot wreck GRUB.** Because the Ubuntu EFI (`nvme1n1p1`) is on a separate drive from the Windows EFI (`nvme0n1p1`), Windows updates never touch the Linux bootloader.
- **OS selection at boot:** Use the UEFI boot menu (`F12` on Legion) to pick which drive to boot. Each drive's EFI registers its own entry in NVRAM independently.
- **During reinstall — point bootloader to the right drive.** The Ubuntu installer may default to `nvme0n1` (the first disk). Make sure GRUB is installed to `nvme1n1` (the Linux drive), not the Windows drive.
- **Swap size:** Keep swap at 2× RAM (~32 GB for 16 GB RAM) if you want hibernate to work — RAM contents must fit entirely on swap.
- **If a boot entry goes missing** after reinstall, restore it from a live session with:
  ```bash
  sudo efibootmgr -v   # list current entries and verify
  ```

## Issues

| # | Issue | Status | Doc |
|---|---|---|---|
| 1 | Black screen in discrete graphics mode | ✅ Fixed | [docs/01-nvidia-drivers.md](docs/01-nvidia-drivers.md) |
| 2 | Sleep/suspend not working | ✅ Fixed | [docs/02-sleep-suspend.md](docs/02-sleep-suspend.md) |
| 3 | Brightness control broken across GPU modes | ✅ Fixed | [docs/03-brightness-fix.md](docs/03-brightness-fix.md) |

## Repo layout

```
docs/      - one markdown file per issue, with symptom/cause/fix
scripts/   - the actual brightness control script
config/    - copy-paste ready config files (grub, modprobe, udev, acpi)
```

## License

MIT — see [LICENSE](LICENSE)
