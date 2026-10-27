# Tela inicial

A tela inicial instalada na box depois da limpeza: título "Para você", abas Explorar, Filmes e Séries, destaques de filmes e séries em alta, clima da cidade, relógio e uma estante de vidro com os apps favoritos. Tema claro de dia e escuro à noite. App Android em Java, sem Gradle e sem bibliotecas externas.

Baseada em código open source sob licença MIT (aviso em [NOTICE](NOTICE)), com as minhas modificações para esta box.

## Modificações

- **Porta de depuração 8989.** A box abre o ADB na 8989, não na 5555 padrão. O app agora tenta as duas (`Adb.java`).
- **Relógio no topo** da tela com destaques, ao lado dos botões (`HomeView.java`).
- **Estante com os apps desta box** e na ordem escolhida: YouTube, YouCine, Netflix, Globoplay e Downloader (`HomeApps.java`, `Prefs.java`).
- **Netflix de celular reconhecida**, com logo próprio (`app/assets/logos/netflix.png`), porque a box não tem a versão de TV.
- **Sem desenhos e animes** nos destaques, e configuração para o Brasil (região, idioma e moeda) em `config.example.properties`.

## Compilar e instalar

Precisa do JDK 17, do Android SDK (build-tools 34 e platform android-34) e do ADB.

1. `./build.sh` (na primeira vez ele cria `config.properties`).
2. Em `config.properties`, preencha sua cidade (`latitude`, `longitude`, `city`) e, para os destaques, uma chave grátis do TMDB em `tmdb_key` (themoviedb.org → Configurações → API). Esse arquivo não vai para o git.
3. `./build.sh` de novo, que gera `FreeMyTV.apk`.
4. Instale e torne a tela padrão:
   ```sh
   adb connect <IP>:<PORTA>
   adb install -r FreeMyTV.apk
   adb shell cmd role add-role-holder --user 0 android.app.role.HOME io.freemytv
   adb shell cmd package set-home-activity io.freemytv/.HomeActivity
   ```

Guarde o `freemytv.keystore` gerado no primeiro build: as atualizações precisam ser assinadas com a mesma chave.
