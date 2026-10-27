#!/bin/sh
# Auditoria de uma TV box Android pela rede. Só lê, não muda nada.
#
#   sh scripts/auditar.sh <IP:PORTA>        ex.: sh scripts/auditar.sh 192.168.1.50:5555
#
# Para cada app, mostra: se é de sistema ou instalado depois, quem instalou, quando,
# se inicia sozinho com a box e as permissões que costumam aparecer em adware.
# No fim, lista os apps sem ícone (invisíveis para o usuário) que estão rodando agora.
set -e

ALVO="$1"
[ -n "$ALVO" ] || { echo "Uso: sh scripts/auditar.sh <IP:PORTA>" >&2; exit 1; }
adb connect "$ALVO" >/dev/null 2>&1 || true
[ "$(adb -s "$ALVO" get-state 2>/dev/null)" = device ] || {
  echo "Não conectou em $ALVO. A depuração está ligada e autorizada na box?" >&2; exit 1; }

tv() { adb -s "$ALVO" shell "$@" | tr -d '\r'; }

# Permissões que, juntas, são típicas de app de anúncio: tela cheia por cima de tudo,
# iniciar com o sistema, ficar rodando em primeiro plano e o identificador de anúncios.
SUSPEITAS="USE_FULL_SCREEN_INTENT|SYSTEM_ALERT_WINDOW|RECEIVE_BOOT_COMPLETED|FOREGROUND_SERVICE|AD_ID|MANAGE_OWN_CALLS|REQUEST_INSTALL_PACKAGES|ACCESS_FINE_LOCATION"

echo "== Aparelho"
echo "$(tv getprop ro.product.manufacturer) $(tv getprop ro.product.model), Android $(tv getprop ro.build.version.release)"
tv grep -E "MemTotal|MemAvailable" /proc/meminfo
echo

echo "== Apps (tipo | instalado por | data | inicia sozinho | permissões suspeitas)"
for p in $(tv pm list packages | sed 's/package://' | sort); do
  info=$(tv dumpsys package "$p")
  flags=$(printf '%s\n' "$info" | grep -m1 pkgFlags)
  case "$flags" in *SYSTEM*) tipo=sistema ;; *) tipo=instalado ;; esac
  por=$(printf '%s\n' "$info" | grep -m1 installerPackageName= | sed 's/.*=//')
  data=$(printf '%s\n' "$info" | grep -m1 firstInstallTime= | sed 's/.*=//')
  boot=$(printf '%s\n' "$info" | grep -q "android.intent.action.BOOT_COMPLETED" && echo sim || echo não)
  perms=$(printf '%s\n' "$info" | grep "granted=true" | grep -oE "$SUSPEITAS" | sort -u | tr '\n' ' ')
  printf '%s | %s | %s | %s | %s | %s\n' "$p" "$tipo" "${por:--}" "${data:--}" "$boot" "${perms:--}"
done
echo

echo "== Apps sem ícone rodando agora (o usuário não vê, mas estão ativos)"
for p in $(tv ps -A -o NAME | grep '\.' | sed 's/:.*//' | sort -u); do
  tv pm path "$p" >/dev/null 2>&1 || continue
  icone=$(tv cmd package resolve-activity --brief "$p" | tail -1)
  case "$icone" in "No activity found") echo "  $p" ;; esac
done
echo

echo "== Quem mais gasta memória"
tv dumpsys meminfo | sed -n '/Total PSS by process/,/Total PSS by OOM/p' | sed -n '2,16p'
