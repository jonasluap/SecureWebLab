# 05 — Nginx : serveur HTTP, site HTML et journaux

## Debian et Nginx ne sont pas la même chose

- **Debian** est le système d'exploitation : il gère les fichiers, les processus, le réseau et les permissions.
- **Nginx** est un programme installé sous Debian : il écoute les requêtes HTTP et renvoie les ressources demandées.
- **Edge** sur Windows est un client HTTP : il demande la page et interprète le HTML reçu.

Nginx peut aussi être reverse proxy, répartiteur de charge, point de terminaison TLS/HTTPS ou intermédiaire vers PHP-FPM, mais **dans les captures disponibles il est d'abord validé comme serveur HTTP de fichiers HTML**.

## Installation et écoute

```bash
sudo apt update
sudo apt install nginx
sudo systemctl status nginx
sudo ss -lntp | grep ':80'
```

Résultats observés : `active (running)`, processus Nginx `master` et `worker`, écoute sur `0.0.0.0:80` et `[::]:80`. `master` supervise le service, tandis que les `workers` traitent les connexions et requêtes.

Depuis le navigateur de Windows : `http://172.16.1.230` affichait d'abord **Welcome to nginx!**.

## Configuration par défaut examinée

Fichier : `/etc/nginx/sites-enabled/default` (sur Debian, généralement lien vers `sites-available/default`).

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

- `listen 80` : service HTTP sur TCP/80.
- `default_server` : site par défaut pour une combinaison adresse/port.
- `root` : racine du contenu statique.
- `index` : noms de pages d'accueil recherchés, dans l'ordre.
- `location /` : règles applicables aux chemins commençant par `/`.
- `try_files $uri $uri/ =404` : essayer ressource puis dossier ; sinon répondre 404.
- `server_name _` n'est **pas à lui seul un caractère joker** : le statut `default_server` permet ici de traiter les requêtes ne correspondant à aucun hôte plus spécifique.

## Page personnelle créée

Le fichier `/var/www/html/index.html` a été créé avec `sudo nano`. Son contenu est fourni dans [`site-web/index.html`](../site-web/index.html). Puisque `index.html` est prioritaire, la nouvelle page a remplacé à l'affichage la page d'accueil Nginx, **sans supprimer** `index.nginx-debian.html` et **sans recharger** le service.

Pourquoi ? Le HTML est une ressource lue à la demande. En revanche, une modification des directives Nginx exige une validation et un rechargement :

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## HTTP : requête, réponse et en-têtes

Depuis PowerShell Windows :

```powershell
curl.exe -i http://172.16.1.230/
```

La sortie réellement observée incluait :

```http
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
Content-Length: 496
Connection: keep-alive
```

- **`GET /`** : demande la racine du site.
- **`200 OK`** : ressource renvoyée avec succès.
- **`Content-Type: text/html`** : type du contenu dans la réponse.
- **`Content-Length: 496`** : taille du corps HTTP renvoyé, en octets.
- **`Connection: keep-alive`** : une connexion TCP peut être réutilisée.
- **`Last-Modified`** : date rapportée pour la dernière modification.
- **`ETag`** : identifiant utilisable pour la validation du cache HTTP.

## Journaux Nginx

```bash
sudo tail -n 10 /var/log/nginx/access.log
```

Exemple réel observé, présenté sous une forme abrégée :

```text
172.16.1.5 ... "GET / HTTP/1.1" 200 496 ... "curl/8.21.0"
```

Cette entrée renseigne notamment la source (`172.16.1.5`), le chemin demandé (`/`), la méthode (`GET`), la version HTTP, le statut (`200`) et le volume envoyé. Les journaux peuvent contenir des adresses, URL et informations sur les clients : ne pas les publier sans vérifier leur contenu.

Une requête automatique vers `/favicon.ico` a donné **404** parce qu'aucun tel fichier n'était présent. Ce résultat n'empêchait pas la page principale de fonctionner.

| Code | Sens habituel |
|---|---|
| 200 | OK |
| 301 | Redirection permanente |
| 403 | Accès interdit |
| 404 | Introuvable |
| 500 | Erreur interne |
| 502 | Mauvaise réponse d'un serveur amont |

## HTTP et HTTPS

L'adresse testée était `http://172.16.1.230`, et Edge indiquait « Non sécurisé » : **HTTP n'assure pas le chiffrement des données de bout en bout**. HTTPS ajoute TLS et une vérification d'identité du serveur par certificat selon les conditions du déploiement. Les captures disponibles prouvent HTTP sur TCP/80, **pas encore un service HTTPS validé sur TCP/443**.
