# Issue: Black Screen in Discrete Graphics Mode

## Symptom
Switching to discrete (NVIDIA-only) graphics mode resulted in a black screen on boot.

## Cause
The open-source kernel module variant of the driver (`nvidia-driver-595-open`) did not
properly initialize the display in discrete mode on this hardware/kernel combo.

## Fix
Install the proprietary driver instead of the open variant:

```bash
sudo apt remove nvidia-driver-595-open
sudo apt install nvidia-driver-595
sudo reboot
```

## Notes
NVIDIA recommends the `-open` kernel modules for newer (Turing+) GPUs in general, but on
this Legion 5 / kernel 6.17 combination the proprietary driver was required for discrete
mode to boot correctly.
