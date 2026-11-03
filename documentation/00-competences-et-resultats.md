# Compétences démontrées par SecureWebLab

Ce document est destiné à faciliter la présentation du projet lors d'un entretien, d'un stage ou d'une candidature en alternance. Chaque compétence décrite correspond à une manipulation ou à un diagnostic observé et documenté.

| Domaine | Compétence pratiquée | Éléments de preuve |
|---|---|---|
| Virtualisation | Créer et configurer des VM Debian et Windows dans VirtualBox | Réseau NAT, stockage VDI, firmware UEFI, interface réseau |
| Administration Linux | Installer des paquets et contrôler des services `systemd` | `apt`, `systemctl status/reload`, `ss -lntp` |
| Réseau IPv4 | Configurer une adresse statique et diagnostiquer la communication | `ip addr`, `ip route`, `ping`, DHCP Windows |
| DNS | Comparer des résolveurs et tester DNS sur UDP et TCP | `dig`, tests IUT / domicile |
| Administration à distance | Accéder au serveur Debian depuis Windows par SSH | `whoami`, `hostname`, IP Debian depuis la session Windows |
| Cryptographie SSH | Créer une paire ED25519 et vérifier une clé d'hôte | `ssh-keygen`, `known_hosts`, `authorized_keys` |
| Sécurité des accès | Restreindre l'accès SSH par clé et interdire le mot de passe SSH | `sshd -t`, `sshd -T`, connexion positive/négative |
| Permissions Linux | Diagnostiquer et corriger des droits sur `~/.ssh` | `chmod`, `ls -ld`, gestion de bits spéciaux |
| Transfert de fichiers | Copier des fichiers en SCP/SFTP et WinSCP | `scp`, `put`, `get`, interface graphique |
| Intégrité | Calculer et comparer les empreintes SHA-256 | PowerShell `Get-FileHash`, Linux `sha256sum` |
| Serveur web | Installer Nginx et héberger une page HTML | HTTP 200 depuis Edge et curl |
| Débogage web | Lire les journaux d'accès et les codes HTTP | `access.log`, réponses 200/404 |
| Exécution PHP | Installer PHP 8.4 et PHP-FPM, identifier le socket Unix | `php -v`, service `php8.4-fpm`, `/run/php/` |

## Présenter le projet en quelques phrases

« J'ai mis en place un laboratoire client-serveur sous VirtualBox avec Debian 13 et Windows 11. J'ai configuré le réseau NAT, une IP statique côté Debian et DHCP côté Windows, puis installé et sécurisé OpenSSH avec authentification par clé ED25519. J'ai testé les transferts SCP/SFTP/WinSCP et vérifié leur intégrité par SHA-256. Enfin, j'ai déployé une page HTML sous Nginx et contrôlé les réponses HTTP et les journaux d'accès. J'ai documenté les difficultés rencontrées, notamment les problèmes DNS, les permissions SSH et l'installation Windows. »

**Précision technique :** PHP et PHP-FPM étaient installés et actifs, mais aucune page PHP exécutée via Nginx n'a encore été présentée comme testée dans les preuves du projet.
