#!/usr/bin/env bash
set -u

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
cpu_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
cpu_idle=$((idle + iowait))
read -r mem_total mem_available < <(awk '/^MemTotal:/ {t=$2} /^MemAvailable:/ {a=$2} END {print t+0, a+0}' /proc/meminfo)

printf '{"cpuTotal":%s,"cpuIdle":%s,"memTotal":%s,"memAvailable":%s}\n' \
  "$cpu_total" "$cpu_idle" "$mem_total" "$mem_available"
