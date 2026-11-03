# Identifiants de laboratoire (fictifs)

Ces valeurs sont **des exemples explicitement destinés à une VM de test isolée**. Elles ne sont **pas** les vrais mots de passe utilisés pendant SecureWebLab.

| Champ | Exemple pédagogique |
|---|---|
| Nom du compte Debian | `dev` |
| Mot de passe initial **fictif** | `LAB-Seulement-ChangeMoi!2026` |
| Clé privée Windows | **générée localement**, jamais fournie |
| Clé publique Windows | obtenue localement après `ssh-keygen` |
| Nom d'hôte Debian | `secureweb-debian` |
| Adresse Debian | `172.16.1.230` |
| Sous-réseau privé | `172.16.1.0/24` |

Un utilisateur peut choisir ces valeurs pour apprendre, mais il doit **définir lui-même les identifiants sur sa VM** et les remplacer s'il rend son service accessible hors du laboratoire. Une clé privée et une passphrase utilisées ailleurs ne doivent pas être réutilisées ici.

## Pourquoi ne pas publier une vraie clé pour que les clones « marchent tout de suite » ?

Parce que tous les clones partageraient alors le **même secret**. Même si les VM sont privées aujourd'hui, une future ouverture de port, une erreur réseau ou la réutilisation de la clé peut rendre ce secret exploitable. Générer une clé par installation préserve le caractère reproductible : **les étapes sont identiques, mais les secrets sont uniques**.
