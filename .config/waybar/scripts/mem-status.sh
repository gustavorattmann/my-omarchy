#!/bin/bash
# Get data directly from the kernel (in kB)
MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
MEM_AVAIL=$(grep MemAvailable /proc/meminfo | awk '{print $2}')

# Calculate memory used
MEM_USED=$((MEM_TOTAL - MEM_AVAIL))

# Convert to GiB with awk
USED_GIB=$(awk "BEGIN {printf \"%.1f\", $MEM_USED / 1048576}")
TOTAL_GIB=$(awk "BEGIN {printf \"%.1f\", $MEM_TOTAL / 1048576}")
PERCENT=$(awk "BEGIN {printf \"%d\", ($MEM_USED / $MEM_TOTAL) * 100}")

# Critical alert
CLASS=$([ $PERCENT -gt 90 ] && echo "critical" || echo "normal")

echo "{\"text\": \"&#160;&#160;&#160;&#160;${USED_GIB}GiB\", \"class\": \"$CLASS\", \"tooltip\": \"RAM: ${USED_GIB}GiB / ${TOTAL_GIB}GiB\nUso: $PERCENT%\"}"