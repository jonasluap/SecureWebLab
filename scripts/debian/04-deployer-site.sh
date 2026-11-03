#!/usr/bin/env bash
# Déployer la page HTML statique du dépôt dans /var/www/html.
set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then
  echo "Exécuter : sudo bash scripts/debian/04-deployer-site.sh" >&2
  exit 1
fi
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source_file="$root/site-web/index.html"
destination='/var/www/html/index.html'

[[ -f "$source_file" ]] || { echo "Introuvable : $source_file" >&2; exit 1; }
install -d -m 0755 /var/www/html
if [[ -f "$destination" ]]; then
  cp -a "$destination" "${destination}.before-secureweblab-$(date +%Y%m%d-%H%M%S)"
fi
install -o root -g root -m 0644 "$source_file" "$destination"
nginx -t
printf 'Page HTML déployée. Tester http://172.16.1.230 depuis la VM Windows.\n'
