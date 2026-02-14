#!/bin/bash
# Principal disk (/)
INFO=$(df -h / | awk 'NR==2 {print $3, $2, $5}' | tr -d '%')
USED=$(echo $INFO | awk '{print $1}')
TOTAL=$(echo $INFO | awk '{print $2}')
PERC=$(echo $INFO | awk '{print $3}')

CLASS=$([ $PERC -gt 90 ] && echo "critical" || echo "normal")

echo "{\"text\": \"&#160;&#160;&#160;&#160;$PERC%\", \"class\": \"$CLASS\", \"tooltip\": \"NVME: $USED ocupados de $TOTAL\nStatus: $PERC% usado\"}"