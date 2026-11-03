# Contrôles depuis la VM Windows ; aucune configuration modifiée.
$server = '172.16.1.230'
Write-Host "=== Configuration IP du client ==="
ipconfig
Write-Host "`n=== TCP SSH (22) ==="
Test-NetConnection $server -Port 22
Write-Host "`n=== TCP HTTP (80) ==="
Test-NetConnection $server -Port 80
Write-Host "`n=== Reponse HTTP ==="
& curl.exe -i --connect-timeout 5 "http://$server/"
