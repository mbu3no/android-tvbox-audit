#!/bin/sh
# Reativa tudo o que scripts/limpar.sh desativou e volta as animações.
#
#   sh scripts/desfazer.sh <IP:PORTA>
set -e

ALVO="$1"
[ -n "$ALVO" ] || { echo "Uso: sh scripts/desfazer.sh <IP:PORTA>" >&2; exit 1; }
adb connect "$ALVO" >/dev/null 2>&1 || true

for p in $(adb -s "$ALVO" shell pm list packages -d | tr -d '\r' | sed 's/package://'); do
  [ "$p" = com.android.nfc ] && continue   # já vinha desligado de fábrica
  printf '%s → ' "$p"
  adb -s "$ALVO" shell pm enable "$p" | tr -d '\r'
done
adb -s "$ALVO" shell settings put global window_animation_scale 1.0
adb -s "$ALVO" shell settings put global transition_animation_scale 1.0
adb -s "$ALVO" shell settings delete global animator_duration_scale
echo "Tudo reativado. Reinicie a box."
