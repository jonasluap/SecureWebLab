# Reproduire SecureWebLab chez soi

Ce guide permet de refaire les manipulations décrites dans la documentation, sans recopier de vrais identifiants et sans dépendre d'une image de VM personnelle.

> **Attention :** les commandes `apt`, `sudo` et les changements de configuration doivent être exécutés **dans la VM Debian de laboratoire**, jamais à l'aveugle sur un serveur de production. Les changements de réseau et de SSH peuvent couper l'accès distant ; conserver la console VirtualBox accessible.

## 1. Préparer les machines

1. Installer Oracle VirtualBox sur l'hôte.
2. Télécharger une image d'installation officielle Debian 13 x64 et une image officielle Windows 11 x64 compatible avec les droits de licence de l'utilisateur.
3. Dans VirtualBox, créer un **réseau NAT partagé** nommé `SecureWebLab` avec le préfixe `172.16.1.0/24` et le DHCP VirtualBox activé pour le client.
4. Créer une VM Debian 13 minimale (exemple : 2 vCPU, 4 Gio RAM, 30 Gio disque) et une VM Windows 11 (exemple : 2+ vCPU, 8 Gio RAM, 64 Gio VDI dynamique, UEFI et TPM 2.0, VBoxSVGA).
5. Dans la configuration réseau **de chaque VM**, activer l'adaptateur 1 et choisir **Réseau NAT** nommé `SecureWebLab` (ne pas confondre avec le mode NAT individuel).

Une VM peut utiliser des ressources différentes selon l'hôte physique. Les VM originales **ne sont pas présentes dans le dépôt**.

## 2. Configurer Debian

Pendant l'installation, créer un utilisateur standard `dev` avec un mot de passe **choisi localement**, puis activer `sudo` pour ce compte si nécessaire.

Sur la console Debian :

```bash
ip link
ip -4 addr
ip route
```

Adapter l'interface réelle (`enp0s3` dans les captures). Pour reproduire l'adresse fixe, étudier [`configurations/reseau/interfaces.example`](../configurations/reseau/interfaces.example) et sauvegarder le fichier réseau existant avant modification.

Vérifier :

```bash
ip -4 addr show enp0s3
ip route
ping -c 4 172.16.1.1
```

Dans la VM Windows, vérifier avec `ipconfig /all` qu'elle reçoit une IPv4 `172.16.1.x` par DHCP ; sa dernière partie peut différer de `.5`. Puis tester `ping 172.16.1.230`.

## 3. Installer SSH, Nginx et PHP-FPM

Les manipulations manuelles sont détaillées dans la documentation : [SSH](../documentation/03-ssh-et-cles.md), [Nginx](../documentation/05-nginx-et-http.md), [PHP-FPM](../documentation/06-php-fpm.md).

Sur la VM Debian uniquement :

```bash
sudo apt update
sudo apt install openssh-server nginx php-fpm
sudo systemctl status ssh --no-pager
sudo systemctl status nginx --no-pager
php -v
```

Le script facultatif [`scripts/debian/01-installer-services.sh`](../scripts/debian/01-installer-services.sh) regroupe ces commandes et les contrôles. **Lire le script avant de l'exécuter.**

## 4. Créer les clés SSH du client

Dans **PowerShell de la VM Windows**, générer une clé distincte de toute clé privée personnelle :

```powershell
ssh-keygen -t ed25519 -f "$HOME\.ssh\secureweblab_demo_ed25519" -C "secureweblab-demo"
```

Définir une passphrase et **ne pas déposer le fichier privé dans Git**.

Transférer uniquement la clé publique (si les fichiers sont dans le dossier personnel Windows) :

```powershell
scp "$HOME\.ssh\secureweblab_demo_ed25519.pub" dev@172.16.1.230:client_demo.pub
```

Lors du premier SSH, **comparer l'empreinte du serveur** à celle calculée sur Debian :

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Sur Debian, connecté en tant que `dev`, installer la clé publique :

```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod u-s,g-s ~/.ssh
cat ~/client_demo.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Le script [`scripts/debian/02-autoriser-cle-publique.sh`](../scripts/debian/02-autoriser-cle-publique.sh) réalise ce contrôle et évite les doublons, après inspection.

Depuis Windows, **vérifier** l'authentification par clé explicitement :

```powershell
ssh -i "$HOME\.ssh\secureweblab_demo_ed25519" -o PreferredAuthentications=publickey -o PasswordAuthentication=no dev@172.16.1.230
```

## 5. Sécuriser les nouvelles connexions SSH

**Uniquement après réussite de l'étape précédente**, avec une session SSH ouverte et la console VirtualBox disponible :

1. Lire [`configurations/ssh/00-secureweblab.conf`](../configurations/ssh/00-secureweblab.conf).
2. Créer ce fichier dans `/etc/ssh/sshd_config.d/` sous `root`.
3. Exécuter `sudo sshd -t` puis `sudo sshd -T`.
4. Si les valeurs sont correctes, `sudo systemctl reload ssh`.
5. Tester une nouvelle session par clé ; seulement ensuite tester le refus de l'authentification par mot de passe.

Un script facultatif avec confirmation explicite est disponible : [`03-durcir-ssh.sh`](../scripts/debian/03-durcir-ssh.sh). **Ne pas lancer depuis une session sans accès de secours.**

## 6. Héberger la page HTML

Sur Debian :

```bash
sudo cp /var/www/html/index.html /var/www/html/index.html.bak 2>/dev/null || true
sudo cp site-web/index.html /var/www/html/index.html
sudo nginx -t
```

L'exemple ci-dessus suppose que le dépôt a été copié sur Debian, et que tu te trouves à sa racine. Le script [`04-deployer-site.sh`](../scripts/debian/04-deployer-site.sh) fait cette opération avec une sauvegarde si un `index.html` existe déjà.

Dans Edge sur Windows, visiter `http://172.16.1.230`. On peut aussi effectuer un test détaillé :

```powershell
curl.exe -i http://172.16.1.230/
```

## 7. PHP-FPM dans une installation reproduite

Le service PHP-FPM a été réellement vérifié dans le projet d'origine. Le raccordement Nginx → PHP-FPM est décrit séparément comme **configuration de démonstration** dans [`configurations/nginx/default-php-fpm.conf`](../configurations/nginx/default-php-fpm.conf).

Si tu souhaites le tester dans **ton propre clone**, lire le modèle, sauvegarder la configuration active et vérifier avec `sudo nginx -t` avant rechargement. Le script facultatif [`05-activer-php-fpm.sh`](../scripts/debian/05-activer-php-fpm.sh) inclut ces étapes et un fichier `demo.php` sans information sensible.

## 8. Vérifier sans modifier

Sur Debian, le script [`06-verifier-laboratoire.sh`](../scripts/debian/06-verifier-laboratoire.sh) affiche les paramètres et l'état des services sans modifier la configuration. Depuis Windows, [`scripts/windows/test-reseau.ps1`](../scripts/windows/test-reseau.ps1) vérifie notamment les ports TCP 22 et 80.

## Identifiants de démonstration

Le document [`exemples/identifiants-de-demonstration.md`](../exemples/identifiants-de-demonstration.md) montre comment choisir un mot de passe fictif pour **un compte créé dans le laboratoire**, et pourquoi il doit être changé si un accès extérieur existe. Ce dépôt ne configure pas de mot de passe à ton insu.
