# Tests de validation à refaire dans une copie du laboratoire

Ces tests servent à vérifier la reproduction de l'environnement ; ils ne constituent pas un historique de nouveaux tests effectués par l'auteur.

| Test | Machine | Commande | Résultat attendu |
|---|---|---|---|
| IPv4 fixe | Debian | `ip -4 addr show enp0s3` | `172.16.1.230/24` |
| Routage | Debian | `ip route` | Réseau `172.16.1.0/24` et route `default via 172.16.1.1` |
| DHCP client | Windows | `ipconfig /all` | `172.16.1.x/24`, passerelle `172.16.1.1` |
| Communication ICMP | Windows | `ping 172.16.1.230` | Réponses provenant de `172.16.1.230` |
| SSH actif | Debian | `systemctl is-active ssh` | `active` |
| Port SSH | Debian | `sudo ss -lntp \| grep ':22'` | `LISTEN` |
| Clé utilisateur | Windows | `ssh -i ... dev@172.16.1.230` | Session `dev` ouverte |
| Mot de passe SSH refusé | Windows | SSH sans clé, méthode `password` | `Permission denied (publickey)` |
| Permissions SSH | Debian | `ls -ld ~/.ssh; ls -l ~/.ssh/authorized_keys` | `drwx------` et `-rw-------` |
| Nginx actif | Debian | `systemctl is-active nginx` | `active` |
| HTTP | Windows | `curl.exe -i http://172.16.1.230/` | `HTTP/1.1 200 OK` |
| Journal | Debian | `sudo tail -n 5 /var/log/nginx/access.log` | Ligne `GET /` du client |
| PHP CLI | Debian | `php -v` | PHP 8.4.x sur Debian 13, selon dépôts |
| PHP-FPM | Debian | `systemctl is-active php8.4-fpm` | `active` |
| Socket PHP-FPM | Debian | `ls -l /run/php/` | Socket `php8.4-fpm.sock` |
| PHP via Nginx (si exemple activé) | Windows | `curl.exe -i http://172.16.1.230/demo.php` | 200 et résultat généré par PHP |

**Attention aux conclusions :** un service `active` ne prouve pas un accès distant ; un ping qui échoue ne prouve pas forcément l'indisponibilité de TCP ; et un `Permission denied` n'est pas équivalent à un `Connection timed out`.
