# Issue: Brightness Control Across GPU Modes

## Background
- In **hybrid mode**, the AMD iGPU drives the internal display (`card1-eDP-1`) →
  backlight device `amdgpu_bl1`
- In **discrete mode**, the NVIDIA GPU drives the display → backlight device `nvidia_0`
- Both devices can exist in `/sys/class/backlight/` at the same time, and GNOME / the
  Fn brightness keys need to target whichever one is actually wired to the panel —
  not just whichever one shows up first.

## Fix Summary
1. Set the correct AMD backlight mode in GRUB
2. Replace GNOME's backlight handling with an `acpid`-triggered script that auto-detects
   the active GPU and writes to the right device
3. Keep the `nvidia_0` backlight device writable across boots (needed for discrete mode)

### 1. GRUB
`/etc/default/grub`:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mem_sleep_default=deep amdgpu.backlight=0"
```
`amdgpu.backlight=0` forces PWM backlight mode. (`amdgpu.backlight=1` means AUX/DP
backlight — wrong for this panel, and the cause of one of our dead ends below.)

```bash
sudo update-grub
sudo update-initramfs -u
sudo reboot
```

### 2. ACPI event handlers
See [config/acpi/events/](../config/acpi/events/) — these route the Fn key ACPI events
to the brightness script:

`/etc/acpi/events/brightness-up`:
```
event=video/brightnessup
action=/etc/acpi/brightness.sh up
```

`/etc/acpi/events/brightness-down`:
```
event=video/brightnessdown
action=/etc/acpi/brightness.sh down
```

### 3. Brightness script
See [scripts/brightness.sh](../scripts/brightness.sh). Detects which GPU is driving the
panel and adjusts that device by 5% per keypress:

```bash
#!/bin/bash

# Detect active display driver and use the appropriate backlight device
if [ -d /sys/class/drm/card1-eDP-1 ] && grep -q "connected" /sys/class/drm/card1-eDP-1/status 2>/dev/null; then
    DEVICE="amdgpu_bl1"
else
    DEVICE="nvidia_0"
fi

# Fallback if the detected device doesn't exist
[ ! -d /sys/class/backlight/$DEVICE ] && DEVICE=$(ls /sys/class/backlight/ | head -1)

MAX=$(cat /sys/class/backlight/$DEVICE/max_brightness)
CUR=$(cat /sys/class/backlight/$DEVICE/brightness)
STEP=$((MAX / 20))   # 5% of max per keypress

if [ "$1" = "up" ]; then
    NEW=$((CUR + STEP))
    [ $NEW -gt $MAX ] && NEW=$MAX
else
    NEW=$((CUR - STEP))
    [ $NEW -lt $STEP ] && NEW=$STEP
fi

echo $NEW > /sys/class/backlight/$DEVICE/brightness
```

```bash
sudo chmod +x /etc/acpi/brightness.sh
sudo systemctl restart acpid
```


## What Didn't Work (for future reference)

| Attempt | Result |
|---|---|
| `video.use_native_backlight=1` | No-op — param removed in modern kernels |
| `acpi_backlight=native` | `nvidia_0` stayed registered; GNOME kept targeting it instead of `amdgpu_bl1` |
| `acpi_backlight=vendor` | Exposed an `ideapad` backlight device, but writes never moved the actual panel hardware |
| `acpi_backlight=none` | No backlight device registered at all — amdgpu skipped registration regardless |
| `amdgpu.backlight=1` | Wrong mode (`1` = AUX, not "enabled") — this panel needs PWM, i.e. `0` |
| `xrandr --output ... --brightness` | Doesn't work — gamma-based, X11-only, this session is Wayland |
| `ddcutil setvcp` | "Display not found" — internal eDP panels aren't addressable over DDC/I2C |

## Key Lesson
The Fn brightness keys were firing correctly via ACPI (`video/brightnessup` /
`video/brightnessdown`, confirmed with `acpi_listen`) the entire time. The actual
problem was never the keys — it was which `/sys/class/backlight/*` device truly
controlled the panel hardware versus which one GNOME happened to be writing to.
