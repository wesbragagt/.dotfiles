# Waybar Battery Module

## Overview

Battery module added to Waybar for laptop battery monitoring.

## Configuration

The battery module is configured in `modules/waybar/config.jsonc`:

```jsonc
"battery": {
  "bat": "BAT0",
  "interval": 60,
  "states": {
    "warning": 30,
    "critical": 15
  },
  "format": "{capacity}% {icon}",
  "format-plugged": "{capacity}% ",
  "format-charging": "{capacity}% ",
  "format-icons": ["\uf244", "\uf243", "\uf242", "\uf241", "\uf240"],
  "max-length": 25
}
```

## Battery Device

The module is configured to monitor `BAT0`. To check available batteries on your system:
```bash
ls /sys/class/power_supply/
```

## Features

- **Auto-detection**: Shows charging, discharging, or plugged status
- **Icons**: Battery level indicators (0-100%)
- **States**: Warning at 30%, Critical at 15%
- **Custom formats**:
  - `{capacity}% {icon}` - Default format
  - `{capacity}% ` - When plugged in
  - `{capacity}% ` - When charging

## Styling

Add CSS rules to `modules/waybar/style.css`:

```css
#battery {
  padding: 0 10px;
}

#battery.warning {
  color: #ebcb8b;
}

#battery.critical {
  color: #bf616a;
  animation: blink 1s linear infinite;
}

@keyframes blink {
  to {
    color: #ffffff;
  }
}
```

**Sources:**
- [Waybar Wiki - Battery Module](https://github.com/Alexays/Waybar/wiki/Module:-Battery)
- [Waybar Manual - battery(5)](https://man.archlinux.org/man/extra/waybar/waybar-battery.5.en)
