# Générer une nouvelle paire SSH pour CE laboratoire, sans écraser une clé existante.
$sshDirectory = Join-Path $HOME '.ssh'
$keyPath = Join-Path $sshDirectory 'secureweblab_demo_ed25519'
New-Item -ItemType Directory -Path $sshDirectory -Force | Out-Null

if (Test-Path $keyPath) {
    Write-Warning "Clé déjà existante : $keyPath. Aucune modification effectuée."
    exit 1
}

Write-Host "Création d'une paire ED25519. Choisir une passphrase lors de l'invite."
& ssh-keygen -t ed25519 -f $keyPath -C 'secureweblab-demo'
Write-Host "Seule la clé PUBLIQUE peut être transmise à Debian : $keyPath.pub"
Write-Host "Ne jamais publier la clé privée ni un fichier .ppk."
