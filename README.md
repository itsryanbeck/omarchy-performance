# Omarchy Performance

A small Omarchy shell bar widget for live CPU, memory, and graphics performance.

The bar shows CPU use, RAM use, and GPU utilization when the graphics driver exposes it. If GPU utilization is unavailable, the widget shows the current graphics frequency when available. Hover over the widget for memory totals and a fuller summary.

The widget reads local Linux `/proc` and `/sys` counters. It refreshes every two seconds and makes no network requests. NVIDIA metrics use `nvidia-smi` when a working NVIDIA driver is available; AMD utilization uses the DRM `gpu_busy_percent` counter; Intel graphics can report the current graphics frequency through sysfs.

## Install

```bash
omarchy plugin add https://github.com/itsryanbeck/omarchy-performance.git --enable
```

Omarchy will add the widget to the bar. To remove it later:

```bash
omarchy plugin remove local.performance
```

## Requirements

- Omarchy shell with third-party bar plugin support
- Bash
- Standard Linux `/proc` and `/sys` interfaces
- Optional: `nvidia-smi` for NVIDIA GPU metrics

GPU metrics vary by driver. The widget reports values exposed by the installed driver and shows an em dash when neither utilization nor frequency is available.

## Files

- `manifest.json` declares the Omarchy plugin and bar widget.
- `Performance.qml` renders the live bar summary and tooltip.
- `collect.sh` reads CPU, memory, and available GPU counters.
- `i18n/en.json` contains the English strings.
