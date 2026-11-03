# 09 — Commandes utilisées et preuves de fonctionnement

Cette fiche rassemble les commandes qui reviennent dans le projet. Les captures originales se trouvent dans [`captures/`](../captures/).

## Commandes Debian

| Commande | Pourquoi elle a servi |
|---|---|
| `ip -4 addr show enp0s3` | Lire l'IPv4 de l'interface réseau |
| `ip route` | Examiner les routes IPv4 et la passerelle |
| `ping -c 4 172.16.1.1` | Tester la passerelle NAT |
| `dig debian.org` | Tester la résolution DNS |
| `dig @1.1.1.1 debian.org +tcp` | Tester une requête DNS ciblée sur TCP |
| `sudo apt update` | Actualiser la liste des paquets disponibles |
| `sudo apt install openssh-server` | Installer le service SSH |
| `sudo systemctl status ssh` | Vérifier l'état du service SSH |
| `sudo ss -lntp \| grep ':22'` | Vérifier que SSH écoute en TCP |
| `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` | Afficher l'empreinte publique du serveur |
| `ls -ld ~/.ssh` | Vérifier les permissions du répertoire |
| `sudo sshd -t` | Tester la syntaxe SSH |
| `sudo sshd -T` | Afficher la configuration SSH effective |
| `sudo systemctl reload ssh` | Faire relire la configuration sans arrêter volontairement le service |
| `sudo apt install nginx` | Installer le serveur HTTP |
| `sudo systemctl status nginx` | Vérifier Nginx |
| `sudo ss -lntp \| grep ':80'` | Vérifier l'écoute HTTP |
| `sudo tail -n 10 /var/log/nginx/access.log` | Examiner les requêtes récentes |
| `php -v` | Voir PHP CLI et sa version |
| `sudo systemctl status php8.4-fpm` | Vérifier le gestionnaire PHP-FPM |
| `ls -l /run/php/` | Voir le socket Unix de PHP-FPM |
| `sha256sum ~/test_sftp.txt` | Vérifier l'empreinte du fichier côté Debian |

## Commandes Windows

| Commande | Pourquoi elle a servi |
|---|---|
| `ipconfig /all` | Voir adresse, DHCP, DNS, passerelle |
| `ping 172.16.1.230` | Tester Debian en ICMP |
| `ssh dev@172.16.1.230` | Ouvrir une session distante |
| `ssh-keygen -t ed25519` | Créer une paire de clés utilisateur |
| `ssh-keygen -F 172.16.1.230` | Chercher le serveur dans `known_hosts` |
| `scp "%USERPROFILE%\.ssh\id_ed25519.pub" dev@172.16.1.230:client_windows.pub` | Copier la clé publique |
| `sftp dev@172.16.1.230` | Ouvrir une session de transfert |
| `Get-FileHash "$HOME\test_sftp.txt" -Algorithm SHA256` | Calculer une empreinte SHA-256 |
| `curl.exe -i http://172.16.1.230/` | Observer réponse et en-têtes HTTP |
| `Test-NetConnection 172.16.1.230 -Port 22` | Tester explicitement le port TCP de SSH |

## Tests de sécurité documentés

**Autorisé :**

```powershell
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no dev@172.16.1.230
```

Résultat observé : passphrase de la clé privée demandée, puis accès `dev@secureweb-debian:~$`.

**Refusé :**

```powershell
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password -o KbdInteractiveAuthentication=no dev@172.16.1.230
```

Résultat observé : `Permission denied (publickey)`.

## Tests web documentés

- Edge sur Windows affiche `Bienvenue sur SecureWebLab` via `http://172.16.1.230`.
- `curl.exe -i` obtient `HTTP/1.1 200 OK`, `Server: nginx`, `Content-Length: 496` et le document HTML.
- Le journal `access.log` contient la requête `GET /` depuis `172.16.1.5` et une requête `favicon.ico` avec 404.
- PHP 8.4.27 CLI et PHP-FPM étaient démarrés ; la preuve de la liaison FastCGI avec Nginx n'a pas été fournie dans les captures.

## Glossaire des preuves

- **Capture de configuration** : prouve la valeur visible à un instant, pas nécessairement que le trafic fonctionne.
- **Test de service** : `active (running)` prouve l'activité locale, pas l'accessibilité depuis Windows.
- **Test distant** : une réponse SSH/HTTP depuis Windows vérifie le chemin client ↔ serveur.
- **Test positif + négatif** : plus fort qu'une configuration seule pour l'authentification SSH.
- **Empreinte SHA-256** : démontre l'égalité du contenu avec une très forte confiance, indépendamment du succès affiché par l'outil de transfert.
