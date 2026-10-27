# Relatório de auditoria

**Aparelho:** Proeletronic PROSB-3000 (16 GB), Android 10, 2 GB de RAM, chip Allwinner (plataforma `cupid`), firmware `PROSB3000/16GB_20260713-1644`.
**Método:** conexão pela rede com ADB, leitura de pacotes, permissões, processos, datas de instalação e componentes de cada app. Nada foi apagado: tudo foi desativado com `pm disable-user` e pode ser revertido.

## Estado inicial

| | |
|---|---|
| Apps instalados | 118 |
| Memória livre | ~1,20 GB de 2 GB |
| Tela inicial | `com.a.nova.launcher` (da fabricante) |
| Animações | ligadas |
| Depuração pela rede | porta **8989** (não a 5555 padrão), encontrada por varredura de portas |

## Achado 1: app de anúncios invisível

| | |
|---|---|
| Pacote | `org.koorw.wnknuzch` (nome aleatório) |
| Versão declarada | "White Shadow 2025.9.30" |
| Ícone | nenhum, então não aparece para o usuário |
| Instalado por | instalador de pacotes (APK de fora da Play Store) |
| Instalado em | 28/01/2026, cerca de 2 horas depois de um app de streaming baixado fora da loja |
| Memória em uso | ~64 MB, rodando o tempo todo |

**Permissões concedidas:**
- `RECEIVE_BOOT_COMPLETED`: liga sozinho junto com a box.
- `USE_FULL_SCREEN_INTENT`: abre telas cheias por cima do que estiver passando. É **o anúncio a cada 2 minutos**.
- `FOREGROUND_SERVICE` e `WAKE_LOCK`: fica ativo em segundo plano e impede o sistema de encerrá-lo.
- `com.google.android.gms.permission.AD_ID`: identificador de publicidade.
- `MANAGE_OWN_CALLS`: permissão de app de chamadas, sem nenhum motivo para estar ali.

**Componentes:**
- Classes com nomes embaralhados (`com.badongutech.playvideos4fun.nOFaNrSCucvC`, `…HGLYLxOnGFmivz`): ofuscação para dificultar a análise.
- Kit de anúncios **Chartboost** (`com.chartboost.sdk…VideoRepositoryDownloadService`), que baixa vídeos de propaganda.
- Um **ConnectionService** (`BIND_TELECOM_CONNECTION_SERVICE`) se passando por app de chamadas. É um truque conhecido para o Android tratar o app como prioritário e não matá-lo.
- WorkManager com gatilhos de rede, bateria, armazenamento e reagendamento: o app volta a rodar a cada mudança de estado.

**Conclusão:** adware que veio "de carona" com um APK instalado por fora da loja. Desativá-lo acabou com os anúncios.

## Achado 2: acesso remoto pré-instalado de fábrica

| Pacote | Onde estava |
|---|---|
| `com.anydesk.anydeskandroid` | `/system/priv-app/AnyDesk` (app privilegiado do sistema) |
| `com.anydesk.adcontrol.ad1`, `.aosp`, `.aosp2`, `.formulergtv1` | `/system/priv-app/AdControAD` |

Os plugins "adcontrol" permitem que o AnyDesk **controle a tela e o controle remoto** à distância, não só que veja a tela. Tudo isso veio no firmware, sem o dono saber. Todos foram desativados.

## Achado 3: apps de sistema disfarçados

| Pacote | Observação |
|---|---|
| `com.android.syslock` | Fica na pasta `/system/app/Mgloboplay` (nome de outro app), roda com o usuário do sistema, tem **localização precisa e em segundo plano**, backup e recebe mensagens push com a categoria `MASTER_CLEAR` (reset de fábrica). |
| `com.android.nfx` | `/system/app/NFXAccessibility`, sem ícone e sem função clara. |
| `com.technical.support.app` | "Suporte técnico" instalado em 05/08/2025, abre direto sem pedir nada. |
| `com.abupdate.fota_demo_iot` | Atualizador de firmware compilado em modo **debug** (`DEBUGGABLE`). Foi mantido ligado para não perder atualizações. |

Nomes começando com `com.android.` dão a impressão de serem do próprio Android, mas esses não fazem parte do sistema original. `syslock` e `nfx` foram desativados **um de cada vez, com reinício entre eles**, para garantir que a box continuava ligando.

## Achado 4: lixo de fábrica

- Testes de fábrica: `com.softwinner.agingdragonbox`, `com.softwinner.dragonbox`, `com.yxt.factorytest`, `com.android.app.cus.aging`.
- "Limpador de memória" da fabricante: `com.yxt.memoryclean`.
- Fileira de recomendações patrocinadas: `com.google.android.tvrecommendations`, `com.google.android.leanbacklauncher.recommendations`.
- Serviços de impressão numa TV: `com.android.printspooler`, `com.android.bips`, `com.android.printservice.recommendation`.
- Um app de downloads ocupava **~148 MB** sozinho em segundo plano (foi mantido, porque o dono usa).

## O que **não** foi tocado

Play Store, Google Play Services, configurações, interface do sistema, teclado, Bluetooth, instalador de pacotes, provedores de dados e tudo marcado como `PERSISTENT`. Nenhum app de sistema foi desinstalado.

## Resultado

| | Antes | Depois |
|---|---|---|
| Anúncios | a cada ~2 min | nenhum |
| Apps desativados | 0 | 30 |
| Memória livre | ~1,20 GB | ~1,50 GB |
| Tela inicial (memória) | ~32 MB | ~28 MB |
| Animações | ligadas | desligadas |
| Acesso remoto de fábrica | ativo | desativado |
| Depuração pela rede | ligada | desligada ao final |

A box reiniciou e foi validada após cada lote, sem nenhuma falha.
