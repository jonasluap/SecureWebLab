# 10 — Secrets, clés privées et laboratoire reproductible

## Pourquoi ne pas publier les véritables identifiants ?

Le serveur du projet était une VM située derrière un réseau NAT privé. Cela réduit son exposition directe à Internet, mais **ne rend pas une clé privée publiable sans risque**.

- Une clé privée d'utilisateur publiée pourrait être utilisée contre un serveur qui autorise cette clé, si le serveur devient accessible et si l'attaquant peut l'utiliser (par exemple en connaissant la passphrase, ou si elle n'en a pas).
- Une clé d'hôte SSH privée publiée permettrait de se faire passer cryptographiquement pour ce serveur dans certaines conditions.
- Un mot de passe de compte exposé peut être réutilisé accidentellement ailleurs, ou survivre à un futur déploiement.
- Les fichiers `.vdi` et `.ova` peuvent contenir des clés privées, des mots de passe, des historiques de shell, des jetons et des journaux ; ils nécessitent une préparation spécifique avant publication.
- Les contenus commités peuvent rester dans l'historique Git, les clones et les archives même après suppression du fichier visible.

## Reproduire l'exercice sans partager le secret

1. Chaque personne crée sa propre paire ED25519 sur sa VM Windows.
2. Elle copie **uniquement la clé publique** vers Debian.
3. Debian stocke cette clé publique dans `~/.ssh/authorized_keys`.
4. La clé d'hôte Debian est vérifiée depuis Windows avant l'acceptation.
5. Les mots de passe de compte servent au démarrage du laboratoire uniquement, sont choisis localement et sont remplacés ou désactivés pour l'accès SSH distant après validation de la clé.

Un **mot de passe fictif** est donné dans [`exemples/identifiants-de-demonstration.md`](../exemples/identifiants-de-demonstration.md). Il ne correspond pas à celui utilisé personnellement pendant les manipulations.

## Éléments fournis / non fournis

| Fourni | Non fourni |
|---|---|
| Fichiers de configuration exemples | Véritables clés privées Windows et Debian |
| Commandes de génération de clés | Fichiers `.ppk` et `id_ed25519` originaux |
| Script d'ajout de clé publique | Véritable `authorized_keys` et véritable `known_hosts` |
| Captures de tests et empreintes publiques | Véritables mots de passe, clés d'API, jetons |
| Page web, scripts, procédure VirtualBox | Disques VDI/OVA non nettoyés et ISO propriétaires |

Les empreintes et les clés **publiques** ne sont pas considérées comme des clés secrètes. Néanmoins, les captures ont été sélectionnées afin d'éviter de publier inutilement de la configuration personnelle.

## Recommandations lors d'une future exportation de VM

Une VM distribuable doit être préparée comme **un nouveau modèle pédagogique** : identifiants de laboratoire créés pour la distribution, régénération des clés d'hôte SSH au premier démarrage, absence de clés utilisateur privées, vérification des journaux et historiques, suppression des jetons, nettoyage des données de session et validation des licences. Ce dépôt ne contient aucune image de VM préconfigurée.

## Vérification avant `git push`

```bash
git status --short
git ls-files
```

Vérifier que la liste ne contient aucune clé, aucun `.env` réel, aucun export de VM et aucun identifiant de production. `.gitignore` évite certains ajouts **mais ne protège pas un secret déjà commité**.

Pour ajouter un exemple, utiliser des fichiers explicitement fictifs (`*.example`, `identifiants-de-demonstration.md`) et ne jamais coller de mot de passe réellement utilisé ailleurs.
