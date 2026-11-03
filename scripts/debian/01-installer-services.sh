#!/usr/bin/env bash
# Installer les services du laboratoire Debian. A lire avant exécution.
set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then
  echo "Exécuter : sudo bash scripts/debian/01-installer-services.sh" >&2
  exit 1
fi

apt-get update
apt-get install -y openssh-server nginx php-fpm

for service in ssh nginx; do
  systemctl is-active --quiet "$service" || { echo "Service inactif : $service" >&2; exit 1; }
done

php -v | head -n 1
if systemctl list-unit-files --type service | grep -q '^php8\.4-fpm\.service'; then
  systemctl is-active --quiet php8.4-fpm || { echo 'php8.4-fpm inactif' >&2; exit 1; }
fi

echo "Installation terminée. Vérifier les ports et l'accès depuis la VM Windows."
