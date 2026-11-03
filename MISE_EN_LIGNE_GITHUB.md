# Publier ce dossier sur le dépôt GitHub SecureWebLab

Dépôt GitHub créé : `jonasluap/SecureWebLab` (dépôt public vide au moment de la capture).

## Méthode simple : envoyer les fichiers par l'interface GitHub

1. Décompresser l'archive **dans un dossier local** : les fichiers `README.md` et `.gitignore` doivent rester à la racine du dépôt.
2. Sur GitHub, ouvrir le dépôt puis **Add file → Upload files** (ou « uploading an existing file » sur un dépôt vide).
3. Envoyer le **contenu** du dossier, en conservant l'arborescence. GitHub peut imposer des limites sur les lots ou certains fichiers : pour un vrai projet suivi dans le temps, utiliser plutôt Git en local.
4. Vérifier l'affichage du README et la navigation dans `documentation/`.

## Méthode recommandée : Git depuis ton PC hôte

Ouvrir un terminal à la racine du dossier extrait (celui qui contient `README.md`) :

```bash
git --version
git init
git branch -M main
git status --short
git add .
git status --short
git commit -m "Documentation et laboratoire SecureWebLab"
git remote add origin https://github.com/jonasluap/SecureWebLab.git
git push -u origin main
```

### Comprendre les commandes

- `git init` : initialise le dépôt Git local.
- `git branch -M main` : nomme la branche principale `main`.
- `git add .` : prépare les fichiers suivis pour le prochain commit (respecte `.gitignore` pour les fichiers non suivis).
- `git status` : permet de **vérifier ce qui va être publié**, notamment les captures et configurations.
- `git commit` : enregistre une version locale.
- `git remote add origin ...` : ajoute l'adresse du dépôt distant.
- `git push` : transfère les commits vers GitHub.

Si `git commit` demande une identité, configurer **tes propres** nom et adresse e-mail Git avec `git config --global user.name` et `git config --global user.email` : ne pas copier de valeur inventée.

GitHub ne permet pas d'utiliser le mot de passe du compte comme mot de passe de `git push` HTTPS. Utiliser un moyen d'authentification accepté (gestionnaire d'identifiants Git, GitHub CLI ou jeton personnel avec droits limités).

## Vérification cruciale

Avant `git push` :

```bash
git status --short
git ls-files
```

Confirmer que ni les **vraies** clés privées, ni un `.env` réel, ni un disque `.vdi`, ni un mot de passe personnel n'apparaissent dans l'index. Le dossier `captures/` est volontairement public : relire son contenu avant publication.

## Et la VM Debian préconfigurée ?

Elle n'est **pas** fournie dans cette version. Lorsqu'une VM de distribution sera créée, l'export nettoyé et ses informations d'import pourront être diffusés séparément, par exemple dans une version publiée (*Release*), sans encombrer l'historique Git avec un disque virtuel volumineux.
