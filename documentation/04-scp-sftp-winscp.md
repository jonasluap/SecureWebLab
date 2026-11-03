# 04 — SCP, SFTP, WinSCP et intégrité des fichiers

## Les outils et leur rôle

| Outil / protocole | Rôle | Transport |
|---|---|---|
| SSH | Terminal distant et canal sécurisé | Généralement TCP/22 |
| SCP | Copie de fichiers via SSH | SSH ; les clients OpenSSH récents peuvent employer SFTP sous-jacent |
| SFTP | Gestion et transfert de fichiers distants | Sous-système SSH (pas FTP classique) |
| WinSCP | Logiciel graphique Windows utilisant notamment SFTP et SCP | Selon le protocole choisi |
| SHA-256 | Fonction de hachage pour comparer le contenu des fichiers | Pas un protocole de transfert |

WinSCP **n'est pas un protocole**. Il fournit une interface graphique aux fonctionnalités de transfert : envoyer, télécharger, renommer, parcourir des répertoires.

## Première connexion SFTP

Depuis Windows PowerShell :

```powershell
sftp dev@172.16.1.230
```

Les commandes saisies pendant le TP étaient :

```text
sftp> pwd       # répertoire distant /home/dev
sftp> lpwd      # répertoire local C:\Users\jonas
sftp> ls        # liste du répertoire distant
```

Le préfixe **`l`** signifie *local* dans ces commandes : `lpwd`, `lls`, `lcd`.

## Exemple de fichier et transfert aller-retour

Création sous PowerShell Windows :

```powershell
Set-Content -Path "$HOME\test_sftp.txt" -Value "Test de transfert SFTP SecureWebLab" -Encoding utf8
Get-Content "$HOME\test_sftp.txt"
```

Envoi vers Debian depuis `sftp>` :

```text
put test_sftp.txt
ls -l test_sftp.txt
```

Transfert observé : fichier de **41 octets**, stocké en `/home/dev/test_sftp.txt`.

Retour depuis Debian vers Windows, sous un autre nom :

```text
get test_sftp.txt test_sftp_retour.txt
bye
```

`put` = client → serveur ; `get` = serveur → client. L'utilisation d'un second nom évite d'écraser l'original pendant le test.

## Vérification indépendante par SHA-256

Sur Windows :

```powershell
Get-FileHash "$HOME\test_sftp.txt" -Algorithm SHA256
Get-FileHash "$HOME\test_sftp_retour.txt" -Algorithm SHA256
```

Sur Debian :

```bash
sha256sum ~/test_sftp.txt
```

Les empreintes observées sont identiques (la casse majuscules/minuscules n'a pas d'importance) :

```text
9900937D9B1B7BCAA18D79F95C879FDC8FD2BE8DB2D582C0FAE011DE146DB9C9
```

**Interprétation :** la correspondance des empreintes fournit une très forte confiance que les octets des fichiers sont identiques. SHA-256 ne chiffre pas les données, ne remplace pas une signature et n'établit pas à lui seul l'identité du serveur.

## WinSCP : configuration réellement testée

| Champ | Paramètre |
|---|---|
| Protocole | `SFTP` |
| Hôte | `172.16.1.230` |
| Port | `22` |
| Utilisateur | `dev` |
| Authentification | Clé privée ED25519 |

Dans la version utilisée, WinSCP a demandé de convertir la clé privée OpenSSH au format `.ppk` (PuTTY). La conversion a conservé la même paire cryptographique, au format de stockage requis par l'application. Le nouveau fichier **est lui aussi secret et ne doit pas être publié**.

Au premier accès, WinSCP a affiché l'empreinte de la clé d'hôte Debian, vérifiée avant de l'ajouter à son cache de confiance. La connexion a réussi et les dossiers `/home/dev` (Debian) et `C:\Users\jonas\Documents` (Windows) ont été visibles.

Un glisser-déposer de `test_sftp.txt` depuis le panneau distant vers le panneau local a réussi. Le transfert s'effectuait en **mode binaire**, sans transformation du contenu.

## Erreurs utiles

- `le -l` dans l'invite `sftp>` → `Invalid command` ; la bonne commande est `ls -l`.
- `scp` et `sftp` copient à travers une connexion SSH, mais **SSH seul** sert surtout à fournir une session distante.
- La passphrase de la clé privée SSH peut être demandée lors du transfert : ce n'est pas une réactivation du mot de passe de compte SSH.

## Preuves

Voir les images des connexions SFTP, des empreintes et du transfert WinSCP dans [captures/README.md](../captures/README.md).
