# Issue: Sleep / Suspend Not Working

## Symptom
System failed to properly suspend (sleep) with the NVIDIA discrete GPU active.

## Fix

### 1. Enable NVIDIA's systemd sleep hooks
```bash
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-resume.service
sudo systemctl enable nvidia-hibernate.service
```

### 2. Configure NVIDIA power management
`/etc/modprobe.d/nvidia-power.conf` (see [config/nvidia-power.conf](../config/nvidia-power.conf)):
```
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_PreserveVideoMemoryAllocations=1
```

### 3. Force deep sleep in GRUB
`/etc/default/grub`:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash mem_sleep_default=deep"
```

Apply any grub change with:
```bash
sudo update-grub
sudo update-initramfs -u
sudo reboot
```
