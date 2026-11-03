#!/usr/bin/env bash
# Configurer l'authentification SSH par clé seulement.
# ATTENTION : vérifier AVANT l'authentification par clé et garder une console de secours.
set -euo pipefail
if [[ "$EUID" -ne 0 ]]; then
  echo "Exécuter : sudo bash scripts/debian/03-durcir-ssh.sh" >&2
  exit 1
fi

printf '\nATTENTION : cette opération peut empêcher les nouvelles connexions SSH.\n'
printf 'Vérifier une connexion par clé réussie ET garder la console VirtualBox ouverte.\n'
read -r -p 'Taper exactement OUI pour continuer : ' answer
[[ "$answer" == OUI ]] || { echo 'Opération annulée.'; exit 0; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
src="$repo_root/configurations/ssh/00-secureweblab.conf"
dest='/etc/ssh/sshd_config.d/00-secureweblab.conf'

if [[ -e "$dest" ]]; then
  cp -a "$dest" "${dest}.before-secureweblab-$(date +%Y%m%d-%H%M%S)"
fi
install -o root -g root -m 0644 "$src" "$dest"

if ! /usr/sbin/sshd -t; then
  echo 'Configuration SSH invalide. Ne pas recharger le service !' >&2
  exit 1
fi

/usr/sbin/sshd -T | grep -E '^(passwordauthentication|pubkeyauthentication|permitrootlogin|kbdinteractiveauthentication) '
read -r -p 'Si ces paramètres sont corrects, taper RELOAD pour recharger SSH : ' confirmation
[[ "$confirmation" == RELOAD ]] || { echo 'Configuration non rechargée.'; exit 0; }

systemctl reload ssh
systemctl is-active ssh
printf '\nGarder cette session ouverte et tester UNE NOUVELLE connexion par clé depuis Windows.\n'
