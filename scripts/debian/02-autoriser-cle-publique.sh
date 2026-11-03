#!/usr/bin/env bash
# Installer une CLE PUBLIQUE EXISTANTE dans authorized_keys du compte courant.
# Exemple : bash scripts/debian/02-autoriser-cle-publique.sh ~/client_demo.pub
set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
  echo 'Ne pas exécuter comme root : lancer depuis le compte destinataire (ex. dev).' >&2
  exit 1
fi
if [[ "$#" -ne 1 || ! -f "$1" ]]; then
  echo "Usage : $0 chemin/vers/cle_publique.pub" >&2
  exit 1
fi

pub_file="$1"
ssh-keygen -lf "$pub_file" >/dev/null || { echo 'Fichier de clé publique invalide.' >&2; exit 1; }
public_line="$(grep -m1 -E '^(ssh-ed25519|ssh-rsa|ecdsa-sha2-[^ ]+) ' "$pub_file")"
[[ -n "$public_line" ]] || { echo 'Aucune clé publique reconnue.' >&2; exit 1; }

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
chmod u-s,g-s "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

if grep -qxF "$public_line" "$HOME/.ssh/authorized_keys"; then
  echo 'Clé déjà présente : aucune ligne ajoutée.'
else
  printf '%s\n' "$public_line" >> "$HOME/.ssh/authorized_keys"
  echo 'Clé publique ajoutée au compte courant.'
fi

ls -ld "$HOME/.ssh"
ls -l "$HOME/.ssh/authorized_keys"
