# TV Box: auditoria e limpeza

Uma TV box genérica esquecida na gaveta: lenta, com **anúncio em tela cheia a cada 2 minutos** e uma tela inicial poluída. Este repositório documenta a auditoria que descobriu o motivo e a limpeza que a deixou rápida, sem anúncios e mais segura, sem desinstalar nada e sem root.

## O que foi encontrado

- **Um app invisível de anúncios**, sem ícone e com nome aleatório, que ligava junto com a box e abria propaganda em tela cheia. Tinha código ofuscado, um kit de anúncios embutido e um truque para o Android nunca encerrá-lo. Entrou "de carona" com um APK instalado por fora da loja.
- **AnyDesk pré-instalado de fábrica**, como app privilegiado do sistema, com plugins que permitem controlar a box à distância.
- **Apps de sistema disfarçados**: um deles ficava numa pasta com nome de outro app e tinha acesso à localização em segundo plano.

Os detalhes técnicos (permissões, componentes, datas, pastas) estão em **[AUDITORIA.md](AUDITORIA.md)**.

## Resultado

| | Antes | Depois |
|---|---|---|
| Anúncios | a cada ~2 min | nenhum |
| Apps desativados | 0 | 30 |
| Memória livre | ~1,20 GB | ~1,50 GB |
| Acesso remoto de fábrica | ativo | desativado |

A tela inicial da fabricante também foi trocada por uma nova, em Java, com destaques de filmes e séries, clima, relógio e só os apps usados. O código, as modificações e como compilar estão em **[tela-inicial/](tela-inicial/)**.

## Como foi feito

1. **Achar a box na rede.** Uma varredura de portas mostrou que a depuração não estava na porta padrão (5555), mas na **8989**.
2. **Auditar.** `scripts/auditar.sh` lista cada app com tipo, quem instalou, data, se liga sozinho, permissões suspeitas e quais apps sem ícone estão rodando. Foi assim que o app de anúncios apareceu.
3. **Limpar em lotes.** `scripts/limpar.sh` desativa os apps em lotes e reinicia a box entre eles, conferindo se ela voltou. Os apps de sistema suspeitos são desativados um de cada vez.
4. **Trocar a tela inicial** e desligar as animações.
5. **Desligar a depuração** no fim, para ninguém na rede conseguir controlar a box.

## Usar no seu aparelho

Precisa só do [ADB](https://developer.android.com/tools/releases/platform-tools) e de um terminal (no Windows, o Git Bash).

1. Na box: **Configurações → Sobre → Número da versão** (7 cliques) e depois **Opções do desenvolvedor → Depuração USB**.
2. No computador:
   ```sh
   sh scripts/auditar.sh 192.168.1.50:5555     # só lê, não muda nada
   ```
3. Leia a saída antes de qualquer coisa. A lista de `scripts/limpar.sh` é **desta box**: em outro aparelho, monte a sua a partir da auditoria.
4. Para voltar tudo:
   ```sh
   sh scripts/desfazer.sh 192.168.1.50:5555
   ```

> **Atenção:** desativar apps de sistema tem risco. Nunca desative Play Store, Google Play Services, configurações, interface do sistema, teclado, Bluetooth ou instalador de pacotes. Faça em lotes pequenos e reinicie entre eles.

## Dicas

- Se a sua box mostra anúncio do nada, **desconfie de APKs instalados por fora da Play Store**.
- Boxes genéricas podem vir com acesso remoto de fábrica: **não faça login em banco ou e-mail nelas**.
- Depois da limpeza, **desligue a depuração USB**.
