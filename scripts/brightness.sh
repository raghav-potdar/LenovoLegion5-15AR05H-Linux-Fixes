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
