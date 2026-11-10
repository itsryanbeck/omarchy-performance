# Omarchy Performance

A small Omarchy shell bar widget for live CPU and memory performance.

The bar shows CPU and RAM use. Hover over the widget for memory totals.

The widget reads local Linux `/proc` counters. It refreshes every two seconds and makes no network requests.

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

## Files

- `manifest.json` declares the Omarchy plugin and bar widget.
- `Performance.qml` renders the live bar summary and tooltip.
- `collect.sh` reads CPU and memory counters.
- `i18n/en.json` contains the English strings.
