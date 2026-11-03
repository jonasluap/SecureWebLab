# 08 — Questions posées et notions acquises

> Fiche de révision rédigée à partir des questions discutées pendant SecureWebLab. Certains concepts (comme le reverse proxy ou Spring Boot) ont été **expliqués** sans être présentés comme installés dans ce laboratoire.

## A. Virtualisation et systèmes

### 01. À quoi sert VirtualBox ?

VirtualBox fournit des machines virtuelles : chaque VM dispose de composants matériels virtuels (CPU, RAM, disque, carte réseau) et peut démarrer son propre système d'exploitation sur l'ordinateur hôte.

### 02. Quelle différence entre un ISO et un VDI ?

L'**ISO** contient généralement les fichiers servant à démarrer l'installateur. Le **VDI** est le disque dur virtuel dans lequel le système et les données sont installés. Supprimer un VDI n'est pas la même chose que retirer l'ISO du lecteur virtuel.

### 03. Pourquoi un ISO ARM64 ne démarre-t-il pas comme un ISO x64 ?

ARM64 et x86-64 sont des architectures de processeur différentes. Une VM configurée pour x86-64 attend un système compatible ; il faut télécharger le support correspondant à l'architecture.

### 04. Pourquoi utiliser Debian sans interface graphique ?

Un serveur n'a pas besoin d'un bureau pour héberger SSH ou Nginx. Une installation minimale consomme généralement moins de ressources et encourage une administration par terminal ou SSH.

### 05. Quelle différence entre le système Debian et un service installé dessus ?

Debian gère le système et les ressources. Nginx, SSH et PHP-FPM sont des programmes/services exécutés par Debian ; ce sont eux qui répondent aux requêtes des clients.

### 06. Qu'est-ce que LVM ?

Le *Logical Volume Manager* organise l'espace disque en volumes logiques. Il facilite certaines évolutions de stockage, mais ne remplace ni le système de fichiers, ni les sauvegardes.

### 07. Qu'est-ce que `sudo` ?

`sudo` autorise un utilisateur habilité à exécuter une commande avec des privilèges élevés. Il ne signifie pas que toute la session devient automatiquement root.

### 08. Pourquoi ne pas travailler en permanence en root ?

Cela augmente les risques d'erreur et de modification accidentelle des fichiers sensibles. Il est préférable d'utiliser un compte courant et `sudo` pour les tâches nécessaires.

## B. IPv4, réseau et DNS

### 09. Quelle différence entre une adresse IP et une adresse MAC ?

Une IPv4 identifie une interface dans un réseau IP et sert à l'acheminement des paquets. Une MAC identifie une interface sur un lien de niveau 2, notamment Ethernet. ARP permet de découvrir une MAC associée à une IPv4 locale.

### 10. Que signifie `/24` dans `172.16.1.230/24` ?

Les 24 premiers bits identifient le préfixe réseau. Le masque correspondant est `255.255.255.0` ; le réseau du laboratoire est `172.16.1.0/24`.

### 11. Pourquoi Debian a-t-il une IP statique et Windows utilise DHCP ?

L'adresse statique rend le serveur facile à retrouver ; DHCP distribue automatiquement les paramètres du client. Dans le laboratoire, l'adresse cliente observée était `172.16.1.5`.

### 12. À quoi sert DHCP ?

DHCP fournit notamment l'adresse IP, le masque, la route par défaut et les DNS sans imposer une saisie manuelle sur chaque client.

### 13. Qu'est-ce qu'une passerelle par défaut ?

C'est le prochain saut utilisé par défaut quand la destination n'appartient pas à un réseau directement connecté. Dans le projet, la passerelle NAT est `172.16.1.1`.

### 14. Pourquoi Windows et Debian n'ont-ils pas besoin de la passerelle pour communiquer entre eux ?

Leurs IPv4 sont dans le même `/24` et le même réseau virtuel. La communication Ethernet locale peut donc se faire directement après résolution ARP.

### 15. À quoi sert NAT ?

NAT traduit des adresses (et souvent des ports) entre deux espaces réseau, par exemple lorsqu'un réseau privé sort vers Internet. NAT ne correspond pas à un serveur DNS.

### 16. Qu'est-ce que le double NAT ?

Il y a plusieurs traductions successives, par exemple le NAT de VirtualBox puis celui de la box domestique. Cela peut compliquer des connexions entrantes ou certaines analyses réseau.

### 17. Quelle différence entre NAT individuel et réseau NAT VirtualBox ?

Le NAT individuel fournit une connectivité sortante à une VM, tandis qu'un réseau NAT partagé peut relier plusieurs VMs entre elles. Pour SecureWebLab, Debian et Windows appartiennent au même réseau NAT nommé.

### 18. À quoi sert DNS ?

DNS associe des noms à des enregistrements (par exemple une adresse IP). Il aide à trouver une destination mais ne transporte pas la page web elle-même.

### 19. Pourquoi `ping 1.1.1.1` fonctionne-t-il alors que `dig debian.org` peut échouer ?

Le ping teste ICMP vers une IPv4, tandis que `dig` échange des messages DNS avec un résolveur. Les protocoles, ports et politiques de filtrage diffèrent.

### 20. DNS utilise-t-il TCP ou UDP ?

Les deux. Beaucoup de requêtes DNS classiques utilisent UDP/53, mais DNS sur TCP/53 est aussi standard, notamment pour certaines réponses volumineuses ou dans d'autres circonstances. `dig ... +tcp` force le test TCP.

### 21. Pourquoi `dig @1.1.1.1 ... +tcp` fonctionnait-il à l'IUT alors que l'UDP échouait ?

Le chemin réseau et les politiques pouvaient traiter UDP et TCP différemment. Les essais prouvent le **comportement constaté**, mais pas quel équipement précis en était responsable.

### 22. Pourquoi ne faut-il pas toujours modifier `/etc/resolv.conf` directement ?

Parce qu'il peut être généré automatiquement par un gestionnaire de réseau/DNS. Une modification manuelle peut disparaître après redémarrage ou reconnexion.

### 23. Que fait `ip route` ?

Il affiche les routes configurées, notamment celle du réseau local et la route par défaut (`default via ...`).

### 24. Comment interpréter « 0 % de perte » avec « hôte inaccessible » ?

Il faut lire chaque ligne : Windows peut comptabiliser des messages ICMP d'erreur dans les statistiques. Si la source répond « Impossible de joindre l'hôte », ce n'est pas un ping réussi vers la destination.

## C. TCP, UDP et SSH

### 25. Quelle différence entre TCP et UDP ?

**TCP** établit une connexion, fournit des numéros de séquence, des accusés de réception et des retransmissions pour livrer un flux d'octets ordonné. **UDP** envoie des datagrammes sans ces garanties intégrées. Le choix dépend de l'application ; UDP n'est pas « interdit » à la fiabilité, une application peut l'implémenter au-dessus.

### 26. Pourquoi SSH utilise-t-il TCP ?

SSH a besoin d'un flux fiable et ordonné pour transporter ses échanges cryptographiques et ses données interactives. Il fonctionne généralement sur TCP/22.

### 27. SSH envoie-t-il directement des paquets TCP ?

SSH fournit des données au système réseau ; TCP les transporte comme un flux segmenté, puis IP les place dans des paquets. C'est l'**encapsulation** des couches de protocoles.

### 28. Qu'est-ce que le handshake TCP ?

Pour une connexion TCP classique, l'établissement se fait avec SYN, SYN-ACK, ACK. Cela précède l'échange applicatif SSH ou HTTP.

### 29. Que signifie « port TCP 22 » ?

Le port distingue le service visé sur une machine. Le port 22 est le port habituel d'OpenSSH. Il n'est pas le numéro d'adresse IP.

### 30. À quoi sert SSH exactement ?

SSH permet une session distante chiffrée, l'exécution de commandes, les transferts et d'autres usages sécurisés. Dans le TP, il donne accès au shell Debian depuis Windows.

### 31. Quelle différence entre `openssh-client` et `openssh-server` ?

Le premier initie les connexions ; le second écoute et reçoit les connexions entrantes. Une même machine peut installer les deux.

### 32. Pourquoi `sudo apt update` avant `apt install` ?

`apt update` actualise le **catalogue des paquets disponibles** ; `apt install` installe un paquet ; `apt upgrade` met à jour des paquets installés. `update` ne met pas lui-même à jour les applications.

### 33. Pourquoi `systemctl status ssh` et `ss -lntp` ?

`systemctl` vérifie le service ; `ss` vérifie l'existence d'un socket réseau en écoute. Un service peut sembler actif tout en n'écoutant pas sur l'adresse attendue.

### 34. Quelle différence entre `reload` et `restart` ?

`reload` demande au service de relire sa configuration sans l'arrêter complètement lorsqu'il le prend en charge. `restart` le stoppe puis le relance. Pour un serveur administré à distance, on minimise les interruptions.

### 35. Qu'est-ce qu'une clé publique et une clé privée ?

Une paire asymétrique comprend une clé **privée** secrète et une clé **publique** diffusable. Pour l'authentification SSH, une signature faite avec la privée est vérifiée grâce à la publique.

### 36. Si quelqu'un possède ma clé publique Windows, peut-il se connecter ?

Pas avec la seule clé publique : il doit prouver la possession de la clé privée correspondante. Une clé privée volée est un problème de sécurité, même dans un laboratoire si elle est réutilisée ensuite.

### 37. Debian déchiffre-t-il la clé publique Windows avec sa propre clé privée ?

Non. Debian vérifie la **signature de l'utilisateur** avec la clé publique autorisée. Les clés privées d'hôte Debian remplissent un autre rôle : prouver l'identité du serveur.

### 38. À quoi sert `known_hosts` ?

Il conserve les identités cryptographiques des **serveurs** déjà approuvés par un client SSH. Sous Windows, il se situe généralement dans `%USERPROFILE%\.ssh\known_hosts`.

### 39. À quoi sert `authorized_keys` ?

Sur Debian, il énumère les clés publiques **autorisées à authentifier un utilisateur donné**. Il ne contient pas sa clé privée.

### 40. Pourquoi vérifier une empreinte SSH ?

Lors de la première connexion, il faut s'assurer que la clé d'hôte annoncée est bien celle du serveur attendu. Sinon, un imposteur pourrait être approuvé par erreur.

### 41. Qu'est-ce qu'une attaque MITM ?

Une attaque *Man-in-the-Middle* tente de placer un tiers entre deux correspondants pour espionner, usurper ou modifier les échanges. L'authentification du serveur et le chiffrement SSH sont des protections importantes.

### 42. Qu'est-ce qu'une passphrase de clé privée ?

C'est une phrase secrète utilisée pour protéger le fichier de clé privée stocké localement. Elle n'est pas le mot de passe de connexion du compte Debian.

### 43. Pourquoi `chmod 700 ~/.ssh` et `chmod 600 authorized_keys` ?

`700` : propriétaire lit/écrit/parcourt le répertoire ; groupe et autres sans accès. `600` : propriétaire lit/écrit le fichier. SSH est sensible à certaines permissions trop ouvertes.

### 44. Pourquoi `chmod 7000` avait-il créé `drws--S---` ?

Le chiffre supplémentaire a modifié des bits spéciaux (`setuid`, `setgid`, etc.) et a retiré les droits ordinaires. Sur un répertoire, un `s`/`S` signalait des bits spéciaux ; la correction a inclus `chmod u-s,g-s`.

### 45. Pourquoi `sudo cat fichier >> destination` ne résout-il pas toujours une erreur de droits ?

`sudo` s'applique à `cat`, alors que `>>` est traité par le shell courant. C'est ce shell qui doit avoir le droit d'ouvrir `destination`.

### 46. Pourquoi `sshd -t` et `sshd -T` ?

`-t` vérifie la **syntaxe** ; `-T` calcule et affiche les valeurs **effectives** de la configuration. Une syntaxe valide ne garantit pas une valeur correcte.

### 47. Pourquoi deux connexions SSH simultanées fonctionnent-elles ?

Un serveur SSH gère plusieurs sessions, avec certaines limites de ressources et de sécurité. Deux connexions du même compte sont généralement possibles.

### 48. `Connection timed out` et `Permission denied` : quelle différence ?

`timed out` indique que la connexion TCP n'a pas abouti dans le délai. `Permission denied` survient lors de l'authentification, quand le serveur est joignable mais refuse le moyen proposé.

## D. Transfert, fichiers et intégrité

### 49. Quelle différence entre SCP et SFTP ?

Les deux permettent des opérations de transfert via SSH. SFTP propose un protocole de gestion de fichiers distant avec commandes comme `put` et `get` ; `scp` fournit une interface de copie de fichiers.

### 50. WinSCP est-il un protocole ?

Non. C'est un **logiciel Windows graphique** pouvant utiliser SFTP ou SCP, entre autres, pour gérer des fichiers distants.

### 51. Que signifient `put` et `get` ?

Dans SFTP : `put` **envoie** le fichier local vers le serveur ; `get` **récupère** un fichier distant vers le client.

### 52. Quelle différence entre `pwd` et `lpwd` dans SFTP ?

`pwd` affiche le répertoire **distant** ; `lpwd` le répertoire **local**. La même convention est utilisée par `ls`/`lls`.

### 53. Pourquoi calculer un SHA-256 après transfert ?

Pour obtenir une empreinte du contenu sur chaque machine et les comparer. Une égalité des empreintes donne une très forte confiance que les fichiers sont identiques.

### 54. SHA-256 chiffre-t-il le fichier ?

Non. SHA-256 est une **fonction de hachage**, pas un chiffrement réversible. Elle ne cache pas les données et ne prouve pas à elle seule l'origine d'un fichier.

## E. Nginx, HTTP et PHP-FPM

### 55. Qu'est-ce que Nginx ?

C'est un logiciel serveur HTTP pouvant servir des pages, agir comme reverse proxy, gérer TLS et transférer des requêtes à une application. Il fonctionne **sur** Debian, mais n'est pas Debian.

### 56. Pourquoi ne pas héberger simplement le HTML « sur Debian » sans Nginx ?

Le fichier peut être stocké sur Debian, mais un logiciel doit écouter la requête HTTP, lire la ressource et la renvoyer. Nginx fournit cette fonction ; on pourrait utiliser un autre serveur web.

### 57. Nginx sert-il uniquement aux sites web ?

Non. Il peut servir des API, être reverse proxy, terminer HTTPS, équilibrer du trafic et servir de cache HTTP.

### 58. Un site Nginx dans une VM NAT est-il accessible à tout Internet ?

Non, pas automatiquement. `172.16.1.230` est une adresse privée, non routable sur Internet public. Un accès public exige une architecture réseau adaptée et un durcissement supplémentaire.

### 59. Que veut dire `HTTP/1.1 200 OK` ?

La requête HTTP a reçu une réponse réussie. Le code 200 concerne la ressource demandée, pas automatiquement la santé de toutes les ressources du site.

### 60. Pourquoi Nginx affiche-t-il parfois `404` pour `/favicon.ico` ?

Le navigateur cherche l'icône d'onglet ; si elle n'est pas présente, Nginx renvoie « introuvable ». Cela n'empêche pas la page d'accueil de répondre 200.

### 61. Pourquoi faut-il HTTPS ?

HTTPS utilise TLS pour protéger les données HTTP en transit et authentifier le serveur dans les conditions prévues par la configuration des certificats. HTTP seul est en clair.

### 62. Quelle différence entre `index.html` et un script PHP ?

Nginx peut lire et renvoyer `index.html` directement. Un fichier PHP doit être exécuté par PHP (souvent via PHP-FPM) afin de générer le contenu de la réponse.

### 63. Qu'est-ce qu'un socket ?

C'est un point de communication entre programmes. Dans le projet, Nginx écoute sur un socket réseau TCP/80 et PHP-FPM peut écouter sur un **socket Unix local** comme `/run/php/php8.4-fpm.sock`.

### 64. Pourquoi utiliser un socket Unix plutôt que TCP entre Nginx et PHP-FPM ?

Parce que les deux processus sont sur la même machine. Un socket Unix est local, utilise des permissions système et ne nécessite pas de passer par IP. Un socket TCP local serait aussi possible si configuré.

### 65. Qu'est-ce que FastCGI ?

C'est un protocole d'échange entre un serveur web et un processus applicatif. Nginx peut l'utiliser pour transmettre à PHP-FPM les informations nécessaires à l'exécution d'une requête PHP.

### 66. Qu'est-ce que Spring Boot ?

C'est un framework Java servant à créer des applications, API et services backend. Il a été expliqué pour comparer les rôles : Nginx reçoit et distribue éventuellement les requêtes ; une application Spring Boot traite la logique Java. **Spring Boot n'est pas installé dans ce laboratoire.**

### 67. Que signifie reverse proxy ?

C'est un serveur intermédiaire placé devant un ou plusieurs services applicatifs : le client contacte Nginx, qui transmet à l'application et renvoie sa réponse. Un reverse proxy peut ajouter TLS, journalisation, filtrage et répartition de charge.

## F. Git et documentation

### 68. Quelle différence entre Git et GitHub ?

**Git** suit l'historique des versions d'un dossier local. **GitHub** héberge des dépôts Git accessibles en ligne, avec des fonctions de partage et de collaboration.

### 69. À quoi sert `.gitignore` ?

À empêcher l'ajout accidentel de catégories de fichiers **non encore suivis** (clés privées, `.env`, VDI, ISO). Un fichier déjà commité reste dans l'historique : `.gitignore` ne l'efface pas.

### 70. Pourquoi mettre des exemples de mots de passe plutôt que les vrais ?

Pour que d'autres puissent reproduire la manipulation sans rendre réutilisables des identifiants réels. Un secret publié publiquement doit être considéré comme compromis, même si la machine actuelle n'est qu'une VM privée.
