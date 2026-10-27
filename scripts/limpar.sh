#!/bin/sh
# Desativa (não desinstala) os apps encontrados na auditoria, em lotes, reiniciando
# a box e conferindo que ela voltou entre um lote e outro.
#
#   sh scripts/limpar.sh <IP:PORTA>
#
# Tudo volta com scripts/desfazer.sh. A lista é desta box (Proeletronic PROSB-3000):
# em outro aparelho, rode a auditoria antes e monte a sua.
set -e

ALVO="$1"
[ -n "$ALVO" ] || { echo "Uso: sh scripts/limpar.sh <IP:PORTA>" >&2; exit 1; }

# Lote 1: o app de anúncios escondido e serviços sem uso
LOTE1="org.koorw.wnknuzch
com.google.android.tvrecommendations
com.google.android.leanbacklauncher.recommendations
com.android.printspooler
com.android.bips
com.android.printservice.recommendation
com.android.htmlviewer"

# Lote 2: apps de streaming pré-instalados que não são usados
LOTE2="com.amazon.amazonvideo.livingroom
com.amazon.avod.thirdpartyclient
com.disney.disneyplus
br.com.sbt.mais
tv.pluto.android
com.spotify.tv.android
com.cbs.ca
com.wbd.stream
com.rblive.tv"

# Lote 3: acesso remoto de fábrica, "suporte técnico", testes de fábrica e a tela inicial antiga
LOTE3="com.anydesk.anydeskandroid
com.anydesk.adcontrol.ad1
com.anydesk.adcontrol.aosp
com.anydesk.adcontrol.aosp2
com.anydesk.adcontrol.formulergtv1
com.technical.support.app
com.yxt.memoryclean
com.yxt.factorytest
com.softwinner.agingdragonbox
com.softwinner.dragonbox
com.android.app.cus.aging
com.a.nova.launcher"

# Apps de sistema suspeitos: um por vez, com reinício entre eles
SOZINHOS="com.android.syslock com.android.nfx"

tv() { adb -s "$ALVO" shell "$@" | tr -d '\r'; }

conectar() {
  adb connect "$ALVO" >/dev/null 2>&1 || true
  [ "$(adb -s "$ALVO" get-state 2>/dev/null)" = device ]
}

# Reinicia e espera a box terminar de ligar. Se não voltar em 3 minutos, para tudo.
reiniciar() {
  echo "Aguardando 30 s para o Android gravar as mudanças e reiniciando…"
  sleep 30
  adb -s "$ALVO" reboot
  adb disconnect "$ALVO" >/dev/null 2>&1 || true
  sleep 40
  i=0
  while [ $i -lt 36 ]; do
    if conectar && [ "$(tv getprop sys.boot_completed)" = 1 ]; then
      echo "Ligou normalmente. Memória livre: $(tv grep MemAvailable /proc/meminfo | awk '{print $2}') kB"
      return 0
    fi
    i=$((i + 1)); sleep 5
  done
  echo "A box não voltou. Rode scripts/desfazer.sh assim que ela responder." >&2
  exit 1
}

desativar() {
  for p in "$@"; do
    # Apps marcados como persistentes voltam sozinhos e podem desestabilizar o sistema: pula.
    case "$(tv dumpsys package "$p" | grep -m1 pkgFlags)" in
      *PERSISTENT*) echo "Pulando $p (persistente)"; continue ;;
    esac
    printf '%s → ' "$p"
    tv pm disable-user --user 0 "$p"
  done
}

conectar || { echo "Não conectou em $ALVO." >&2; exit 1; }
echo "Memória livre antes: $(tv grep MemAvailable /proc/meminfo | awk '{print $2}') kB"

echo "== Lote 1"; desativar $LOTE1
tv settings put global window_animation_scale 0
tv settings put global transition_animation_scale 0
tv settings put global animator_duration_scale 0
reiniciar

echo "== Lote 2"; desativar $LOTE2; reiniciar
echo "== Lote 3"; desativar $LOTE3; reiniciar
for p in $SOZINHOS; do echo "== $p"; desativar "$p"; reiniciar; done

echo "Pronto. Desligue a depuração USB na box."
