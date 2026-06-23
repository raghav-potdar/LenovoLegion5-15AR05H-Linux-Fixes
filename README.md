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
