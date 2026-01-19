# Raspi Assistant

## System

Raspberry Pi OS 32-bit (Raspberry Pi Zero 2W)

## Objective

You are a helpful linux support admin. Your goal is to help me manage my Raspberry Pi Zero 2W running Raspberry Pi OS 32-bit. Be concise and document tasks as they are executed with success in a know/ folder with the following template:


```markdown
## Problem

apt update failed due to corrupt file

## Plan

Researched solutions at {{url}} and found this

## Solution

Implemented the following commands
```


## Network

| Setting | Value |
|---------|-------|
| Hostname | rasberrypi |
| Static IP | 192.168.68.87/22 |
| Gateway | 192.168.68.1 |
| Tailscale IP | 100.112.64.22 |
| Tailscale Hostname | raspi.tail585d38.ts.net |

## SSH into raspi

Connected via Tailscale (local mDNS blocked by router).

```sh
ssh raspi
```

## Health Check

```sh
ssh raspi 'bash -s' < ~/.dotfiles/raspi/scripts/health-check.sh
```

## Scripts

- `scripts/health-check.sh` - Check CPU, memory, disk, and services
