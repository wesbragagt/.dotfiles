#!/bin/bash
# Raspberry Pi Health Check Script

echo "=== Raspberry Pi Health Check ==="
echo "Time: $(date)"
echo

# CPU
echo "--- CPU ---"
cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
if [ -n "$cpu_temp" ]; then
    echo "Temperature: $((cpu_temp / 1000))°C"
fi
echo "Load Average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)" | awk '{print "  User: "$2"%, System: "$4"%, Idle: "$8"%"}'

echo
# Memory
echo "--- Memory ---"
free -h | awk '
NR==1 {print "  "$1"\t"$2"\t"$3"\t"$4}
NR==2 {print "  "$1"\t"$2"\t"$3"\t"$4}
NR==3 {print "  "$1"\t"$2"\t"$3}
'

echo
# Disk
echo "--- Disk ---"
df -h / | awk 'NR==2 {print "  Root: "$3" used / "$2" total ("$5" full)"}'

echo
# Uptime
echo "--- Uptime ---"
uptime -p

echo
# Services
echo "--- Key Services ---"
for svc in tailscaled avahi-daemon NetworkManager sshd; do
    status=$(systemctl is-active $svc 2>/dev/null)
    printf "  %-20s %s\n" "$svc:" "$status"
done
