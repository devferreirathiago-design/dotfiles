#!/bin/bash

# Identificadores fixos baseados no que você nos mostrou
BUILT_IN="alsa_output.pci-0000_00_1b.0.analog-stereo"
HEADSET="alsa_output.usb-Plantronics_Plantronics_Blackwire_3220_Series_A26053C789AE4B2399E3B26CCA58A468-00.analog-stereo"

CURRENT=$(pactl get-default-sink)
NEXT=""

# Lógica de alternância
if [ "$CURRENT" == "$BUILT_IN" ]; then
    NEXT="$HEADSET"
else
    NEXT="$BUILT_IN"
    # O PULO DO GATO: Se for o Built-in, forçamos a porta correta
    pactl set-sink-port 161 analog-output-lineout
fi

# Define o novo sink e acorda o dispositivo
pactl set-default-sink "$NEXT"
pactl suspend-sink "$NEXT" 0

# Move os streams ativos
for sink_input in $(pactl list short sink-inputs | awk '{print $1}'); do
    pactl move-sink-input "$sink_input" "$NEXT"
done

notify-send "Audio" "Trocado para: ${NEXT#*.pci-}"
