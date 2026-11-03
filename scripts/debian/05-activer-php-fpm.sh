#!/usr/bin/env bash
# OPTIONNEL : exemple de laboratoire pour activer Nginx + PHP-FPM.
# Ce script n'est PAS une preuve que la configuration a déjà été testée dans le TP initial.
set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then
  echo "Exécuter : sudo bash scripts/debian/05-activer-php-fpm.sh" >&2
  exit 1
fi
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
config_src="$repo_root/configurations/nginx/default-php-fpm.conf"
config_dst='/etc/nginx/sites-available/default'

[[ -S /run/php/php8.4-fpm.sock ]] || { echo 'Socket PHP-FPM absent ; vérifier le service.' >&2; exit 1; }
[[ -f "$config_dst" ]] || { echo 'Configuration Nginx default absente.' >&2; exit 1; }

printf 'Ce script remplacera la configuration Nginx default APRÈS sauvegarde.\n'
read -r -p 'Taper OUI pour continuer : ' answer
[[ "$answer" == OUI ]] || { echo 'Opération annulée.'; exit 0; }
backup="${config_dst}.before-phpfpm-$(date +%Y%m%d-%H%M%S)"
cp -a "$config_dst" "$backup"
install -o root -g root -m 0644 "$config_src" "$config_dst"

if ! nginx -t; then
  echo 'Configuration Nginx invalide : restauration de la sauvegarde.' >&2
  cp -a "$backup" "$config_dst"
  nginx -t || true
  exit 1
fi

install -o root -g root -m 0644 "$repo_root/site-web/demo.php" /var/www/html/demo.php
systemctl reload nginx
printf 'Tester depuis Windows : curl.exe -i http://172.16.1.230/demo.php\n'
