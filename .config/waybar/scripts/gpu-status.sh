#!/bin/bash
TYPE=$1

# Captures data and cleans spaces and commas at once
INFO=$(nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu,fan.speed,power.draw --format=csv,noheader,nounits | tr -d ' ')

# Extract using the correct position in the comma-separated string
UTIL=$(echo $INFO | awk -F',' '{print $1}')
USED=$(echo $INFO | awk -F',' '{print $2}')
TOTAL=$(echo $INFO | awk -F',' '{print $3}')
TEMP=$(echo $INFO | awk -F',' '{print $4}')
FAN=$(echo $INFO | awk -F',' '{print $5}')
PWR=$(echo $INFO | awk -F',' '{print $6}' | awk '{printf "%d", $1}')

case $TYPE in
    gpu)
        CLASS=$([ $UTIL -gt 90 ] && echo "critical" || echo "normal")
        TOOLTIP="Uso de GPU: $UTIL%\nConsumo: ${PWR:-0}W"
	echo "{\"text\": \"󰢮&#160;&#160;&#160;$UTIL%\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
        ;;
    mem)
        USAGE=$(( $USED * 100 / $TOTAL ))
        CLASS=$([ $USAGE -gt 90 ] && echo "critical" || echo "normal")
        TOOLTIP="VRAM: ${USED}MiB / ${TOTAL}MiB\nStatus: $USAGE% usado"
	echo "{\"text\": \"&#160;&#160;&#160;&#160;${USED}MiB\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
        ;;
    temp)
        CLASS=$([ $TEMP -gt 85 ] && echo "critical" || echo "normal")
        
	if [ "$FAN" == "0" ]; then
            FAN_TEXT="Parada (Modo Zero RPM)"
        elif [ "$FAN" == "[NotSupported]" ] || [ -z "$FAN" ]; then
            FAN_TEXT="Não suportado"
        else
            FAN_TEXT="$FAN%"
        fi

        TOOLTIP="Temperatura atual: ${TEMP}°C\nCrítico se > 85°C\nVentoinhas: $FAN_TEXT"
	echo "{\"text\": \"$TEMP°C&#160;\", \"class\": \"$CLASS\", \"tooltip\": \"$TOOLTIP\"}"
        ;;
esac