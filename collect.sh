#!/usr/bin/env bash
set -u

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
cpu_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
cpu_idle=$((idle + iowait))
read -r mem_total mem_available < <(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print t+0, a+0}' /proc/meminfo)

# Prefer a driver's utilization counter. If it is not exposed, report a
# graphics frequency when a sysfs driver provides one.
gpu_busy=null
gpu_freq=null
for path in /sys/class/drm/card*/device/gpu_busy_percent; do
  if [[ -r "$path" ]]; then
    value=$(<"$path")
    if [[ "$value" =~ ^[0-9]+$ ]]; then gpu_busy=$value; break; fi
  fi
done
if [[ "$gpu_busy" == null ]] && command -v nvidia-smi >/dev/null 2>&1; then
  if row=$(timeout 1 nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1) && [[ "$row" =~ ^[[:space:]]*([0-9]+) ]]; then
    gpu_busy=${BASH_REMATCH[1]}
  fi
fi
for path in /sys/class/drm/card*/device/gt_cur_freq_mhz /sys/class/drm/card*/device/gt/gt*/rps_cur_freq_mhz; do
  if [[ -r "$path" ]]; then
    value=$(<"$path")
    if [[ "$value" =~ ^[0-9]+$ ]]; then gpu_freq=$value; break; fi
  fi
done
if [[ "$gpu_freq" == null ]] && command -v nvidia-smi >/dev/null 2>&1; then
  if row=$(timeout 1 nvidia-smi --query-gpu=clocks.current.graphics --format=csv,noheader,nounits 2>/dev/null | head -n1) && [[ "$row" =~ ^[[:space:]]*([0-9]+) ]]; then
    gpu_freq=${BASH_REMATCH[1]}
  fi
fi

printf '{"cpuTotal":%s,"cpuIdle":%s,"memTotal":%s,"memAvailable":%s,"gpuBusy":%s,"gpuFreq":%s}\n' \
  "$cpu_total" "$cpu_idle" "$mem_total" "$mem_available" "$gpu_busy" "$gpu_freq"
