# 07 — Journal des difficultés rencontrées et de leur résolution

Ce document présente les **incidents réellement décrits pendant le laboratoire**. Les diagnostics sont séparés des hypothèses : une cause qui n'a pas été prouvée ne doit pas être présentée comme certaine.

## Incident 01 — Confusion entre réseau NAT et réseau NAT partagé

**Symptôme :** besoin de permettre à deux VM distinctes de communiquer sur `172.16.1.0/24`.

**Explication :** une carte configurée sur le mode NAT individuel de VirtualBox n'offre pas le même réseau partagé qu'un **réseau NAT VirtualBox**. Un réseau NAT nommé `SecureWebLab` a été créé et affecté aux deux VM.

**Validation :** Debian et Windows ont pu communiquer avec `ping` après configuration.

**Leçon :** vérifier le mode d'attachement réseau et le nom du réseau, pas seulement la présence d'Internet.

## Incident 02 — Adresse IP de Debian initialement attribuée par DHCP

**Symptôme :** Debian possédait d'abord une adresse reçue automatiquement, non garantie après redémarrage.

**Action :** configuration d'une IPv4 statique `172.16.1.230/24` et d'une passerelle `172.16.1.1` pour l'interface `enp0s3`.

**Validation :** `ip -4 addr show enp0s3` et `ip route` ; Windows a ensuite joint le serveur.

**Leçon :** l'adresse fixe d'un serveur évite que les clients perdent sa destination habituelle.

## Incident 03 — DNS inopérant dans un réseau mais fonctionnel dans un autre

**Symptôme :** résolution DNS vers `1.1.1.1` en UDP/53 impossible sur le réseau universitaire, alors que d'autres communications IP fonctionnaient.

**Diagnostic :** tests `dig` comparant UDP, TCP, DNS public et DNS de l'IUT. `dig @1.1.1.1 debian.org +tcp` a abouti ; `10.2.2.201` a répondu sur le réseau de l'IUT ; au domicile, Cloudflare a fonctionné en UDP et en TCP.

**Résolution pratique :** utilisation d'un résolveur accessible dans l'environnement où se trouvait la VM.

**Limite :** aucun équipement précis de filtrage n'a été identifié. Dire que « le pare-feu universitaire bloquait UDP/53 » reste une **hypothèse**, pas une démonstration.

**Leçon :** distinguer les problèmes d'IPv4, de routage et de DNS, et tester séparément UDP/TCP quand c'est pertinent.

## Incident 04 — Service `dhcpcd.service` introuvable

**Symptôme :** tentative de vérifier ou recharger un service supposé gérer le DNS, alors que `dhcpcd.service` n'était pas présent comme service utilisable.

**Action :** retour aux fichiers et commandes de diagnostic réels (`/etc/network/interfaces`, `/etc/resolv.conf`, `ip route`, `dig`) au lieu de présumer le gestionnaire réseau.

**Leçon :** Debian peut gérer son réseau par plusieurs mécanismes. Identifier le système utilisé **avant** de changer un fichier qui pourrait être régénéré automatiquement.

## Incident 05 — ISO Windows non compatible avec l'architecture

**Symptôme :** tentative initiale avec un ISO ARM64 alors que la VM était configurée pour x86-64, puis erreur de démarrage `0xc000035a` pendant les essais.

**Action :** utilisation d'un ISO Windows 11 x64, contrôle du type de VM, du firmware et des périphériques virtuels.

**Leçon :** ARM64 et x86-64 sont deux architectures différentes ; un ISO non compatible ne devient pas utilisable parce qu'on modifie seulement la mémoire ou le disque.

## Incident 06 — Disque virtuel Windows manquant

**Symptôme :** la VM n'avait plus de disque dur virtuel après une suppression accidentelle.

**Action :** création d'un VDI dynamique d'environ 64 Gio et branchement sur un contrôleur SATA/AHCI ; l'ISO est resté sur un lecteur optique virtuel.

**Leçon :** le fichier ISO sert à **installer**, le VDI sert à **conserver le système installé et ses données**.

## Incident 07 — Paramètres VirtualBox invalides

**Symptôme :** VirtualBox signalait un « Paramètre invalide détecté ».

**Action :** adoption de VBoxSVGA comme contrôleur graphique avec 128 Mio de mémoire vidéo ; revue des paramètres UEFI, TPM 2.0 et adaptateur réseau.

**Leçon :** une installation de Windows en VM dépend de la cohérence du matériel virtuel fourni, pas seulement de l'ISO.

## Incident 08 — Écran noir pendant le redémarrage Windows

**Symptôme :** installation Windows autour de 80 %, demande de redémarrage, puis écran noir prolongé.

**Action :** après attente et constat apparent d'inactivité, réinitialisation (*Reset*) de la VM bloquée.

**Résultat :** Windows a repris l'installation et affiché une phase à 33 %, puis l'utilisateur a accédé au bureau Windows.

**Prudence :** un Reset forcé peut provoquer une perte de données. Ce n'est pas une procédure standard à appliquer à chaque écran noir.

## Incident 09 — `ping` : « hôte inaccessible » avec 0 % de perte

**Symptôme :** Windows affichait `Réponse de 172.16.1.5 : Impossible de joindre l'hôte de destination` tout en comptabilisant 0 % de perte.

**Analyse :** le message d'erreur provenait du **client Windows**, pas du serveur cible `172.16.1.230`.

**Résultat :** le ping a fonctionné lors des essais suivants, mais la cause précise de l'échec initial n'a pas été isolée.

**Leçon :** les statistiques récapitulatives ne suffisent pas ; il faut lire l'adresse source et le type de réponse.

## Incident 10 — Commande Windows exécutée dans Bash à travers SSH

**Symptôme :** `type %USERPROFILE%\.ssh\known_hosts` renvoyait `-bash: type: %USERPROFILE%...: non trouvé` sur l'invite `dev@secureweb-debian:~$`.

**Cause :** le terminal affichait la session **distante Debian**, pas CMD Windows.

**Résolution :** `exit` pour revenir à `C:\Users\jonas>`, puis `type %USERPROFILE%\.ssh\known_hosts`.

**Leçon :** identifier la machine qui exécute les commandes grâce à l'invite affichée.

## Incident 11 — Permissions SSH incorrectes (`chmod 7000`)

**Symptôme :** `Permission non accordée` lors de l'ajout d'une clé à `~/.ssh/authorized_keys`.

**Cause :** `chmod 7000 ~/.ssh` avait activé des bits spéciaux et retiré les permissions ordinaires.

**Résolution :** `chmod 700 ~/.ssh`, puis `chmod u-s,g-s ~/.ssh` ; vérification `ls -ld ~/.ssh` donnant `drwx------`. Permissions `600` sur `authorized_keys`.

**Leçon :** toujours vérifier la représentation symbolique `rwx` et les bits spéciaux `s/S` après manipulation de `chmod`.

## Incident 12 — Faute dans `sshd_config` détectée avant application

**Symptôme :** `sudo sshd -t` affichait `Bad configuration option` à la ligne 2 du fichier `00-secureweblab.conf`.

**Cause :** paramètre `PasswordAuthentication` mal orthographié.

**Résolution :** correction dans Nano, nouveau `sudo sshd -t` sans message, puis `sudo sshd -T` montrant les valeurs attendues ; rechargement du service seulement après validation.

**Leçon :** tester une configuration avant `reload`/`restart` réduit les risques de perdre l'accès distant.

## Incident 13 — `usage: ssh` et `Connection timed out`

**Symptômes distincts :**

1. `usage: ssh` après une commande SSH incomplète (absence de `dev@172.16.1.230`).
2. `Connection timed out` au cours d'un essai suivant.

**Analyse :** `usage` = problème de syntaxe côté client. `timed out` = connexion TCP non établie avant l'authentification ; ce n'est pas un refus de la clé ED25519.

**Observation :** Debian indiquait SSH actif et en écoute sur TCP/22. L'utilisateur a finalement confirmé qu'il s'était trompé dans sa tentative et que l'accès fonctionnait. La cause exacte du timeout n'a pas été établie, donc aucune panne réseau précise n'est affirmée.

**Leçon :** distinguer les erreurs de syntaxe, de transport TCP et d'authentification SSH.

## Incident 14 — Petite faute de commande SFTP

**Symptôme :** `le -l` → `Invalid command`.

**Résolution :** `ls -l` a listé `client_windows.pub` et `test_sftp.txt` sur Debian.

**Leçon :** l'invite `sftp>` n'est ni Bash ni PowerShell : elle expose son propre ensemble de commandes.

## Incident 15 — Erreur HTTP 404 sur `/favicon.ico`

**Symptôme :** le journal Nginx contenait une requête `/favicon.ico` avec le statut `404`, alors que l'accueil fonctionnait en `200`.

**Cause :** le navigateur demandait une icône de site qui n'avait pas été créée.

**Leçon :** une erreur pour une ressource secondaire ne signifie pas que l'application entière est indisponible. Examiner l'URL, la méthode et le code HTTP.

---

Ces incidents sont conservés comme **preuves de raisonnement et de dépannage**, pas seulement comme une collection de commandes qui finissent par fonctionner.
