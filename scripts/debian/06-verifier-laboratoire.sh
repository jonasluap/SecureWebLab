#!/usr/bin/env bash
# Vérifications non destructives ; exécution avec ou sans sudo.
set -u

printf '\n=== SYSTEME ===\n'
hostname
cat /etc/os-release | grep -E '^(NAME|VERSION)=' || true
printf '\n=== INTERFACES IPv4 ===\n'
ip -4 addr show || true
printf '\n=== ROUTES ===\n'
ip route || true
printf '\n=== SERVICES ===\n'
for srv in ssh nginx php8.4-fpm; do
  printf '%s : ' "$srv"
  systemctl is-active "$srv" 2>/dev/null || true
done
printf '\n=== SOCKETS TCP EN ECOUTE ===\n'
ss -lnt 2>/dev/null || true
printf '\n=== SOCKET PHP ===\n'
ls -l /run/php/ 2>/dev/null || true
printf '\n=== TEST SYNTAXE NGINX (si permissions suffisantes) ===\n'
nginx -t 2>&1 || true
printf '\nFin des vérifications en lecture.\n'
