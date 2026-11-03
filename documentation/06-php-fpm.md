# 06 — PHP et PHP-FPM : du site statique au traitement dynamique

## Installation effectivement observée

Sur Debian, l'installation a produit :

```text
PHP 8.4.27 (cli)
php8.4-fpm.service : active (running)
/run/php/php8.4-fpm.sock
```

Vérifications réalisées :

```bash
php -v
sudo systemctl status php8.4-fpm
ls -l /run/php/
```

Le statut de PHP-FPM indiquait alors `Processes active: 0, idle: 2, Requests: 0` : deux processus étaient disponibles, mais aucune requête n'avait encore été comptabilisée par ce service à cet instant.

## Pourquoi Nginx ne suffit pas à exécuter PHP ?

Nginx peut transmettre un fichier HTML tel quel. Un script `.php` nécessite un **interpréteur PHP**. L'architecture habituelle est :

```text
Windows / navigateur
      │ HTTP / TCP 80
      ▼
Nginx sur Debian
      │ FastCGI via socket Unix
      ▼
PHP-FPM → exécute le script → renvoie le résultat
      │
      ▼
Nginx → réponse HTTP au navigateur
```

- **PHP CLI** : exécution depuis un terminal (`php script.php`).
- **PHP-FPM** (*FastCGI Process Manager*) : gestion de processus PHP pour traiter des requêtes transmises par le serveur web.
- **FastCGI** : protocole permettant à Nginx de transmettre les paramètres de requête à PHP-FPM.

## À quoi sert le socket Unix ?

Le fichier spécial `/run/php/php8.4-fpm.sock` observé avec `ls -l` commençait par `s` et appartenait à `www-data`. Un **socket Unix** fournit un canal local entre processus sur la même machine. Son chemin n'est pas un document à ouvrir dans le navigateur.

Autres sockets connus : les programmes peuvent aussi communiquer par TCP, avec une adresse IP et un port. Sur une même machine, PHP-FPM peut être configuré pour écouter sur `127.0.0.1:9000`, mais ce n'était **pas** le mode observé sur le serveur du projet.

## Exemple de configuration Nginx

> **Exemple reproductible, non présenté comme testé dans les captures du projet.** Le service PHP-FPM a été validé ; une réponse HTTP provenant de l'exécution d'un script PHP n'a pas été fournie.

```nginx
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/run/php/php8.4-fpm.sock;
}
```

- `location ~ \.php$` sélectionne les chemins correspondant au motif de fin `.php`.
- `include` charge les paramètres FastCGI Debian.
- `fastcgi_pass` indique le socket de PHP-FPM à contacter.

Le modèle de site [`default-php-fpm.conf`](../configurations/nginx/default-php-fpm.conf) inclut aussi une règle empêchant l'exposition de fichiers cachés sensibles. Après toute modification, **tester** la syntaxe avec `sudo nginx -t` avant `sudo systemctl reload nginx`.

Un script non sensible [`site-web/demo.php`](../site-web/demo.php) permet de vérifier le chemin Nginx → PHP-FPM sur une installation reproduite. Éviter d'exposer durablement `phpinfo()` sur une machine publique, car il divulgue beaucoup de détails de configuration.

## Exécution dynamique vs fichier statique

- `index.html` : Nginx lit et renvoie le fichier.
- `demo.php` : Nginx doit transmettre une demande à PHP-FPM ; le résultat PHP est renvoyé au client.
- Un serveur web dynamique peut ensuite consulter une base de données, générer des listes ou gérer des sessions, mais **aucune base de données propre à ce laboratoire n'est documentée comme installée à ce stade**.
