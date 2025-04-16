#!/bin/bash

echo "🔥 Running OP Setup - One-Time Performance Mode ON... ($(date))"

# Restart zram/dockers if not active
! systemctl is-active --quiet docker && systemctl start docker
! systemctl is-active --quiet zramswap && systemctl restart zramswap
! systemctl is-active --quiet tlp && systemctl start tlp

# CPU Performance Mode
echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

# File descriptor limits
if ! grep -q "1048576" /etc/security/limits.conf; then
  echo '* soft nofile 1048576' | tee -a /etc/security/limits.conf
  echo '* hard nofile 1048576' | tee -a /etc/security/limits.conf
fi
ulimit -n 1048576

# Run external scripts (once downloaded by Dockerfile)
cd /opt/setup-scripts
[ -x thorium.sh ] && ./thorium.sh
[ -f ognode.sh ] && bash ognode.sh
[ -f  mega.sh ] && bash mega.sh

echo "✅ All Done Bhai! Ultra OP Container READY 🚀 ($(date))"
