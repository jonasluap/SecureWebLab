# 02 — Réseau IPv4, NAT, DHCP et DNS

## Adressage utilisé

```text
NAT Network : 172.16.1.0/24
Passerelle   : 172.16.1.1
Debian       : 172.16.1.230/24 (statique)
Windows      : 172.16.1.5/24   (adresse observée par DHCP)
```

### Pourquoi le même sous-réseau ?

Avec un masque `/24` (`255.255.255.0`), les adresses `172.16.1.5` et `172.16.1.230` appartiennent au même sous-réseau. Elles peuvent donc échanger des trames directement sur le réseau virtuel, sans demander à la passerelle d'acheminer ces échanges locaux. **ARP** associe l'IPv4 de destination à une adresse MAC sur ce lien Ethernet virtuel.

**IP statique côté serveur :** le client doit retrouver le serveur toujours à la même adresse. **DHCP côté client :** il simplifie l'attribution des paramètres IPv4 et leur renouvellement.

### Exemple `/etc/network/interfaces` (Debian)

Fichier modèle : [`configurations/reseau/interfaces.example`](../configurations/reseau/interfaces.example). Extrait :

```ini
auto enp0s3
iface enp0s3 inet static
    address 172.16.1.230/24
    gateway 172.16.1.1
```

Le nom de l'interface doit être vérifié avec `ip link`, car il varie selon le matériel virtuel. **Une connexion SSH active peut être interrompue si l'on applique une mauvaise configuration réseau** : modifier de préférence depuis la console VirtualBox.

## Les tests effectués

| Test | Commande | Ce qu'il démontre |
|---|---|---|
| Interface | `ip -4 addr show enp0s3` | Adresse IPv4 locale |
| Routes | `ip route` | Présence du sous-réseau et d'une route par défaut |
| Passerelle | `ping -c 4 172.16.1.1` | Accès ICMP à la passerelle NAT |
| IPv4 externe | `ping -c 4 1.1.1.1` | Connectivité IP vers l'extérieur, sans prouver le DNS |
| DNS | `dig debian.org` | Résolution de nom avec le résolveur configuré |
| DNS TCP ciblé | `dig @1.1.1.1 debian.org +tcp` | Requête DNS dirigée vers un serveur particulier, sur TCP |
| Windows | `ipconfig /all` | IP, DHCP, passerelle, serveurs DNS |
| Communication | `ping 172.16.1.230` | Test ICMP depuis Windows vers Debian |

## DNS : le cas du réseau universitaire

Des difficultés de résolution DNS ont été observées sur le réseau de l'IUT alors que l'adressage et la communication IP semblaient fonctionner :

- Une requête DNS directe vers `1.1.1.1` en **UDP/53** expirait.
- `dig @1.1.1.1 debian.org +tcp` fonctionnait lors du test, montrant qu'une requête DNS directe en TCP/53 pouvait aboutir.
- Le serveur DNS interne `10.2.2.201` répondait à des requêtes ; `10.2.35.201` n'a pas répondu pendant le test concerné.
- Sur le réseau domestique, le DNS Cloudflare a pu fonctionner en UDP et en TCP.

**Conclusion mesurée :** le comportement dépendait du réseau utilisé, du résolveur cible et du transport UDP/TCP. Une politique réseau ou un filtrage est une explication plausible, **mais l'équipement responsable n'a pas été identifié avec certitude**.

### DNS ≠ ping

- `ping 1.1.1.1` vérifie une forme de joignabilité IP avec ICMP.
- `dig debian.org` interroge un serveur DNS pour associer un nom à des données DNS.
- Un réseau peut autoriser ICMP tout en filtrant UDP/53 ; inversement ICMP peut être bloqué alors qu'un service reste accessible.

### Fichiers de résolution

`/etc/resolv.conf` indique des serveurs de noms à certains résolveurs Linux ; il peut être généré par DHCP, NetworkManager ou `systemd-resolved` suivant la machine. **Ne pas supposer que son contenu sera persistant après redémarrage.** Sur le serveur du projet, un service `dhcpcd.service` recherché n'était pas présent comme service actif. Il faut donc identifier le gestionnaire réellement employé avant d'automatiser une modification.

Les fichiers [`resolv-maison.example`](../configurations/reseau/resolv-maison.example) et [`resolv-iut.example`](../configurations/reseau/resolv-iut.example) montrent des valeurs relevées. **Ce sont des modèles de compréhension, pas des instructions pour remplacer systématiquement `/etc/resolv.conf`.**

## Différence NAT / route / DNS

- **NAT** : traduit notamment les adresses sources des connexions sortantes pour permettre à un réseau privé d'utiliser une autre adresse vers l'extérieur.
- **Route par défaut** : choisit le prochain saut lorsque la destination n'est pas sur un réseau directement connecté.
- **DNS** : résout les noms de domaine. Il n'assure pas le transport des paquets HTTP/SSH.
- **DHCP** : peut fournir une IP, un masque, une passerelle et des DNS.

## Incident du ping affichant « 0 % de perte »

Sur Windows, le test vers `172.16.1.230` a d'abord affiché `Réponse de 172.16.1.5 : Impossible de joindre l'hôte de destination` tout en indiquant `0 % de perte`. Cette statistique ne signifiait pas que Debian répondait : Windows rapportait des erreurs ICMP. La communication a ensuite été confirmée fonctionnelle ; lors d'un diagnostic, il faut lire **la nature des réponses et leur adresse source**, pas seulement le pourcentage de perte.
