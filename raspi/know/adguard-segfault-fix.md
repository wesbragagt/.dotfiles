## Problem

AdGuard Home service was crashing immediately on startup with SEGV (segmentation fault) signal. The service was in an auto-restart loop with restart counter reaching 40+.

## Plan

Investigated the issue by checking:
- Service status and logs (`journalctl -u AdGuardHome`)
- Binary architecture compatibility (`file /opt/AdGuardHome/AdGuardHome`)
- System architecture (`uname -m`)
- Available memory (`free -m`)

The binary appeared correct (ARM 32-bit for armv7l) but was crashing immediately. Decided to reinstall with a fresh download.

## Solution

1. Stopped and disabled the crashing service:
```sh
sudo systemctl stop AdGuardHome
sudo systemctl disable AdGuardHome
```

2. Downloaded latest AdGuard Home for armv7:
```sh
cd /tmp
wget https://github.com/AdguardTeam/AdGuardHome/releases/download/v0.107.71/AdGuardHome_linux_armv7.tar.gz
tar -xzf AdGuardHome_linux_armv7.tar.gz
```

3. Removed old installation and installed fresh:
```sh
sudo rm -rf /opt/AdGuardHome
sudo rm /etc/systemd/system/AdGuardHome.service
sudo systemctl daemon-reload
sudo mv /tmp/AdGuardHome /opt/
sudo chown -R root:root /opt/AdGuardHome
cd /opt/AdGuardHome
sudo ./AdGuardHome -s install
```

4. Verified service is running:
```sh
systemctl status AdGuardHome
```

### Web Interface

- http://192.168.68.87
- http://raspi/login.html
