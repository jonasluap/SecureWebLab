# 01 — Architecture et virtualisation

## Objectif et rôle des machines

Le laboratoire utilise deux systèmes invités sous Oracle VirtualBox : un **serveur Debian 13** sans interface graphique, administré principalement au terminal, et un **client Windows 11**. Le serveur propose des services réseau ; le client permet de vérifier leur accessibilité en situation réelle, sans héberger le site directement.

| Élément | Configuration constatée |
|---|---|
| Hyperviseur | Oracle VirtualBox 7.2 (environnement du projet) |
| Réseau des deux VM | Réseau NAT VirtualBox nommé `SecureWebLab` |
| Réseau IPv4 | `172.16.1.0/24` |
| Passerelle | `172.16.1.1` |
| Serveur | Debian 13, nom d'hôte `secureweb-debian`, utilisateur `dev` |
| IP serveur | `172.16.1.230/24` (statique), interface `enp0s3` |
| Client | Windows 11, compte de laboratoire local ; IP observée `172.16.1.5` par DHCP |
| Debian — ressources allouées | 2 processeurs virtuels, 4 Gio RAM, disque virtuel d'environ 30 Gio |
| Windows — stockage | VDI SATA dynamique d'environ 64 Gio |
| Windows — firmware et sécurité | UEFI et TPM 2.0 configurés ; contrôleur graphique VBoxSVGA |

> Les valeurs sont un exemple fonctionnel. Le nom `enp0s3`, les numéros de cartes, la quantité de RAM et la présence de Secure Boot dépendent de la configuration de chaque VM.

## Comment lire l'architecture

```text
Hôte physique
 └─ VirtualBox
     └─ Réseau NAT SecureWebLab
         ├─ Windows 11 : client HTTP, SSH et SFTP
         └─ Debian 13 : services SSH, Nginx et PHP-FPM
```

- **Hôte (host)** : ordinateur physique exécutant VirtualBox.
- **Invité (guest)** : système d'exploitation installé dans une machine virtuelle.
- **Hyperviseur** : programme qui alloue des ressources matérielles virtuelles à chaque invité.
- **NAT Network** : réseau virtuel partagé permettant aux VM de communiquer entre elles et, par défaut, de sortir vers des ressources externes via NAT.
- **Carte réseau virtuelle** : interface Ethernet présentée au système invité, distincte de la carte physique de l'hôte.

## Installation Debian — décisions techniques

Une installation minimale a été retenue : interface en ligne de commande, compte `dev` autorisé à utiliser `sudo`, disque virtuel avec LVM et système de fichiers ext4. Cette configuration ressemble à de nombreux serveurs qui n'ont pas d'environnement graphique et sont administrés à distance avec SSH.

### LVM et partitions

LVM (*Logical Volume Manager*) est une couche de gestion des volumes située au-dessus des périphériques ou partitions de stockage. Il facilite notamment la réorganisation de l'espace disque sans dépendre uniquement des partitions classiques. Un volume peut héberger un système de fichiers ext4 ; une zone d'échange (*swap*) peut aussi être configurée.

**Attention :** un volume LVM ne remplace pas une sauvegarde. Le partitionnement et la disposition exacte des volumes doivent être vérifiés sur une nouvelle installation avec `lsblk -f` et `df -h`.

## Installation Windows — difficultés documentées

L'installation du client Windows a nécessité plusieurs ajustements :

1. Un ISO ARM64 avait été téléchargé alors que la machine virtuelle attendait un système x64 (x86-64).
2. Une erreur de démarrage `0xc000035a` a été rencontrée au cours des essais.
3. Le disque virtuel avait été supprimé accidentellement : un VDI dynamique de 64 Gio a été recréé et connecté au contrôleur SATA/AHCI.
4. Les réglages UEFI, TPM 2.0, mémoire vidéo (128 Mio), VBoxSVGA et carte réseau ont été revus.
5. Après un redémarrage Windows pendant l'installation, l'affichage est resté noir. Un `Reset` de la VM bloquée a permis à l'installation de reprendre. Cette manipulation est à réserver à une VM manifestement figée, car elle peut interrompre les écritures en cours.

**Le poste client Windows installé n'a pas vocation à être redistribué** dans le dépôt : les ISO, licences et machines virtuelles complètes sont distincts des fichiers source de documentation.

## Différence serveur et client

Un même système d'exploitation peut être client ou serveur selon les services qu'il fournit ou consomme. Ici, Debian est **serveur SSH** pour recevoir les connexions, **serveur HTTP** via Nginx, et **hôte du service PHP-FPM**. Windows est **client SSH/SFTP/HTTP**. Les rôles sont fonctionnels et non une propriété intrinsèque de Debian ou Windows.

## Preuves

Captures de la configuration NAT, de Debian et de l'installation Windows : voir l'[index des captures](../captures/README.md).
