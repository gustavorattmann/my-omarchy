#!/bin/bash
TYPE=$1

# 1. Localização dinâmica
for d in /sys/class/hwmon/hwmon*; do
    [ -f "$d/name" ] || continue
    NAME=$(cat "$d/name")
    if [ "$NAME" == "it8613" ]; then PATH_IT8613=$d; fi
    if [ "$NAME" == "coretemp" ]; then PATH_CORETEMP=$d; fi
done

# 2. Get real usage from CPU
get_cpu_times() {
    read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
    echo "$((user + nice + system + idle + iowait + irq + softirq + steal)) $((idle + iowait))"
}

# First sampling
read -r T1 I1 <<< $(get_cpu_times)
sleep 0.4
# Second sampling
read -r T2 I2 <<< $(get_cpu_times)

# Calculation of variation (Delta)
DIFF_TOTAL=$((T2 - T1))
DIFF_IDLE=$((I2 - I1))

# Use = 100 * (1 - Idle/Total)
if [ "$DIFF_TOTAL" -gt 0 ]; then
    USAGE=$(( 100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL ))
else
    USAGE=0
fi

# 3. Cores and Frequencies (GHz)
TOTAL_CORES=$(nproc)
RUNNING_CORES=$(grep "procs_running" /proc/stat | awk '{print $2}')
FREQS=$(grep "cpu MHz" /proc/cpuinfo | awk '{printf "Core %d: %.2f GHz\\n", nr++, $4/1000}')

# 4. Get real fans
CPU_OPT=$(cat "$PATH_IT8613/fan2_input" 2>/dev/null || echo 0)
SYS_FAN=$(cat "$PATH_IT8613/fan3_input" 2>/dev/null || echo 0)

# If fan3 is the Radiator and the Cabinet is on the same signal or invisible (in my case)
FANS_INFO="Bomba WC: ${CPU_OPT} RPM\\nFans (Hub): ${SYS_FAN} RPM"

# 5. Power Limits (PL1/PL2)
if [ -d "/sys/class/powercap/intel-rapl:0" ]; then
    PL1=$(( $(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw 2>/dev/null || echo 0) / 1000000 ))
    PL2=$(( $(cat /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw 2>/dev/null || echo 0) / 1000000 ))
    POWER_INFO="\\nPower Limit 1: ${PL1}W\nPower Limit 2: ${PL2}W"
else
    POWER_INFO="\\nPower Limits: N/A"
fi

# 6. Temperature (Coretemp - Package id 0)
TEMP=$(( $(cat "$PATH_CORETEMP/temp1_input" 2>/dev/null || echo 0) / 1000 ))

case $TYPE in
    usage)
        CLASS=$([ $USAGE -gt 90 ] && echo "critical" || echo "normal")
        TOOLTIP="Uso de CPU: $USAGE%$POWER_INFO\nNúcleos ativos: $RUNNING_CORES/$TOTAL_CORES\\n\\nFrequências:\\n$FREQS"
        echo "{\"text\": \"&#160;&#160;&#160;$USAGE%\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
        ;;
    temp)
        CLASS=$([ $TEMP -gt 85 ] && echo "critical" || echo "normal")
        TOOLTIP="Temperatura atual: ${TEMP}°C\nCrítico se > 85°C\\n$FANS_INFO"
        echo "{\"text\": \"$TEMP°C&#160;\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
        ;;
esac