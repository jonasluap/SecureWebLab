# 03 — SSH : accès distant, authentification et durcissement

## Pourquoi installer SSH ?

SSH (*Secure Shell*) permet d'administrer Debian depuis le terminal Windows, sans ouvrir la console de la VM. Le client Windows exécute `ssh dev@172.16.1.230` ; le serveur Debian utilise `openssh-server`, qui écoute généralement sur **TCP/22**. Le trafic de la session est chiffré après négociation des paramètres cryptographiques.

```text
Windows 11 (client SSH)              Debian 13 (serveur SSH)
  172.16.1.5                                   172.16.1.230
      │                                               │
      └────── TCP/22 + protocole SSH ──────────────────┘
```

### Installation et contrôle constatés

```bash
sudo apt update
sudo apt install openssh-server
sudo systemctl status ssh
sudo ss -lntp | grep ':22'
```

`active (running)` confirmait le fonctionnement du service ; `LISTEN ... 0.0.0.0:22` et `[::]:22` confirmaient une écoute IPv4 et IPv6. `enabled` indique le démarrage automatique du service, ce qui est différent de `active`.

## Premier accès et identité du serveur

Sur Debian :

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Cette commande affiche l'**empreinte SHA-256 de la clé d'hôte publique** du serveur. Elle ne doit pas être confondue avec la clé publique d'un utilisateur.

Sur Windows :

```powershell
ssh dev@172.16.1.230
```

Lors du premier accès, l'empreinte affichée par le client a été comparée à celle obtenue directement sur Debian, puis le serveur a été accepté. Windows a enregistré sa clé d'hôte dans `%USERPROFILE%\.ssh\known_hosts`.

**Différence essentielle :**

| Élément | Contrôle effectué |
|---|---|
| Clé **d'hôte Debian** + `known_hosts` Windows | Windows vérifie qu'il parle au bon **serveur** |
| Clé **privée Windows** + `authorized_keys` Debian | Debian vérifie que le client possède une clé autorisée pour **l'utilisateur `dev`** |

En cas de changement de clé d'hôte, SSH peut afficher `REMOTE HOST IDENTIFICATION HAS CHANGED`. Il faut comprendre pourquoi elle a changé avant d'accepter la nouvelle clé ; ne jamais effacer `known_hosts` automatiquement pour supprimer un avertissement.

## Création de la clé utilisateur ED25519

Dans Windows (CMD ou PowerShell) :

```powershell
ssh-keygen -t ed25519
```

Deux fichiers sont créés dans `C:\Users\<utilisateur>\.ssh\` :

- `id_ed25519` : **clé privée**, protégée par une passphrase dans le laboratoire ; elle ne doit pas être copiée sur Debian ni publiée.
- `id_ed25519.pub` : **clé publique**, destinée à être copiée dans `authorized_keys` sur Debian.

Le serveur ne « déchiffre » pas la clé publique du client avec sa propre clé privée. Pour l'authentification utilisateur, le client **signe** des données liées à la session avec sa clé privée ; Debian vérifie la signature avec la clé publique autorisée.

## Transfert de la clé publique et permissions

Dans CMD Windows :

```cmd
scp "%USERPROFILE%\.ssh\id_ed25519.pub" dev@172.16.1.230:client_windows.pub
```

Puis sur Debian, connecté en tant que `dev` :

```bash
ls -l ~/client_windows.pub
mkdir -p ~/.ssh
chmod 700 ~/.ssh
chmod u-s,g-s ~/.ssh
cat ~/client_windows.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ls -ld ~/.ssh
ls -l ~/.ssh/authorized_keys
```

**Pourquoi `>>` ?** Cela ajoute une clé publique sans remplacer les clés existantes ; `>` écraserait tout le contenu.

**Pourquoi les droits ?** Le dossier `.ssh` doit appartenir à `dev` et n'être accessible qu'à son propriétaire (par exemple `700`) ; le fichier `authorized_keys` doit également être protégé (`600`). Vérifier le propriétaire avec `ls -l`.

### Erreur réellement rencontrée : `chmod 7000`

Une saisie accidentelle `chmod 7000 ~/.ssh` a activé des bits spéciaux et retiré les droits ordinaires d'accès au dossier, entraînant `Permission non accordée`. Le retour à `chmod 700` a rétabli les droits ordinaires, mais des bits spéciaux sont restés visibles sous la forme `drws--S---`. Ils ont été retirés avec :

```bash
chmod u-s,g-s ~/.ssh
ls -ld ~/.ssh
```

Le résultat attendu est `drwx------`. **Ce cas montre pourquoi il faut inspecter les permissions plutôt que supposer qu'une commande a restauré l'état voulu.**

### Pourquoi `sudo cat ... >> ...` n'a pas aidé

La commande `sudo cat fichier >> destination` exécute `cat` avec `sudo`, mais la redirection `>>` est opérée par le shell non privilégié. Si ce shell ne peut pas ouvrir `destination`, l'opération échoue. Dans notre situation, la vraie cause était les droits du dossier `.ssh`.

## Test positif de connexion par clé

Sur Windows :

```powershell
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no dev@172.16.1.230
```

La session a demandé la **passphrase de la clé privée** Windows, puis ouvert le shell Debian. Cette passphrase n'est pas le mot de passe du compte `dev`.

Vérifications dans le shell distant :

```bash
whoami
hostname
ip -4 addr show enp0s3
```

Les résultats observés étaient `dev`, `secureweb-debian` et `172.16.1.230/24`.

## Durcissement SSH effectué

Fichier utilisé : `/etc/ssh/sshd_config.d/00-secureweblab.conf`.

```text
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
```

La configuration d'exemple est fournie dans [`configurations/ssh/00-secureweblab.conf`](../configurations/ssh/00-secureweblab.conf).

Deux vérifications distinctes ont été réalisées :

```bash
sudo sshd -t
sudo sshd -T | grep -E '^(passwordauthentication|pubkeyauthentication|permitrootlogin|kbdinteractiveauthentication) '
```

- `sshd -t` : validation de la syntaxe. Une faute de frappe sur `PasswordAuthentication` a d'abord produit `Bad configuration option` ; elle a été corrigée **avant** le rechargement.
- `sshd -T` : inspection des valeurs effectives, confirmant `permitrootlogin no`, `pubkeyauthentication yes`, `passwordauthentication no`, `kbdinteractiveauthentication no`.

Puis :

```bash
sudo systemctl reload ssh
sudo systemctl status ssh
```

La connexion par clé a fonctionné à nouveau depuis une **seconde fenêtre Windows** ; la première session est restée ouverte comme accès de secours.

## Test négatif de connexion par mot de passe

Sur Windows :

```powershell
ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password -o KbdInteractiveAuthentication=no dev@172.16.1.230
```

Réponse observée : `Permission denied (publickey)`. C'est un **succès de sécurité**, car l'authentification par mot de passe est refusée. La désactivation de la connexion root a été **vérifiée par la configuration effective** ; aucun essai de connexion root aboutissant/refusé n'est documenté ici.

## MITM : pourquoi vérifier l'empreinte ?

Lors d'une attaque *Man-in-the-Middle*, un tiers tente de s'interposer entre client et serveur, d'usurper une identité et de modifier les échanges. Le chiffrement ne suffit pas si l'on chiffre vers un imposteur : il faut aussi **authentifier le serveur**, notamment en comparant la clé d'hôte lors de la première connexion. `known_hosts` mémorise cette identité pour les connexions suivantes.

## Sécurité des secrets

Le dépôt **n'inclut pas** la vraie clé privée utilisée pendant le TP. Pour reproduire l'exercice, chaque personne crée une paire de clés propre à son environnement ; voir [`laboratoire/README.md`](../laboratoire/README.md) et [`documentation/10-securite-des-secrets.md`](10-securite-des-secrets.md).
