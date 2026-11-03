# Index des captures réelles

Captures issues des manipulations du laboratoire. Elles servent d'éléments de preuve et de contexte ; aucune capture ne doit être interprétée comme preuve de tests non affichés.

> **Confidentialité :** les captures peuvent montrer des noms de comptes et des IP privées de laboratoire. Elles ne contiennent pas de clé privée SSH ni de mot de passe en clair. Vérifier leur contenu avant toute publication publique.

## Installation, VirtualBox, IP et DNS

| Preuve | Illustration |
|---|---|
| Réseau NAT SecureWebLab | [01_nat_network.png](01_nat_network.png) |
| Carte réseau VirtualBox de Debian | [02_carte_debian_nat.png](02_carte_debian_nat.png) |
| Partitionnement Debian et LVM | [03_lvm_confirmation.png](03_lvm_confirmation.png) |
| Debian installé | [04_debian_installe.png](04_debian_installe.png) |
| Adresse IPv4 initialement fournie par DHCP | [05_debian_dhcp_initial.png](05_debian_dhcp_initial.png) |
| Configuration IP Debian | [06_sudo_interfaces.png](06_sudo_interfaces.png) |
| IPv4 statique Debian | [07_ipv4_statique.png](07_ipv4_statique.png) |
| Diagnostic resolver DNS | [08_dns_sans_nameserver.png](08_dns_sans_nameserver.png) |
| Service dhcpcd non disponible | [09_dhcpcd_absent.png](09_dhcpcd_absent.png) |
| DNS en échec sur le réseau de l’IUT | [10_dns_debug_iut.png](10_dns_debug_iut.png) |
| Résolution DNS forcée en TCP à l’IUT | [11_dns_tcp_iut.png](11_dns_tcp_iut.png) |
| Résolveur DNS interne de l’IUT | [12_dns_iut_interne.png](12_dns_iut_interne.png) |
| DNS Cloudflare fonctionnel au domicile | [13_dns_cloudflare_domicile.png](13_dns_cloudflare_domicile.png) |
| Contrôleur de stockage Windows VM | [14_windows_stockage.png](14_windows_stockage.png) |
| Paramètres Windows UEFI / TPM | [15_windows_uefi_tpm.png](15_windows_uefi_tpm.png) |
| Réseau NAT client Windows | [16_windows_nat.png](16_windows_nat.png) |
| Installation Windows après redémarrage | [17_windows_installe_reprise.png](17_windows_installe_reprise.png) |
| Ping Windows : hôte inaccessible, 0 % de perte | [18_windows_ping_echec.png](18_windows_ping_echec.png) |

## Administration distante, SFTP, web et PHP-FPM

| Preuve | Illustration |
|---|---|
| SSH installé : service active (running) | [19_ssh_service_actif.png](19_ssh_service_actif.png) |
| SSH : sockets en écoute sur TCP/22 | [20_ssh_port_tcp22.png](20_ssh_port_tcp22.png) |
| Empreinte ED25519 de la clé d’hôte Debian | [21_empreinte_hote_ssh.png](21_empreinte_hote_ssh.png) |
| Connexion SSH Windows vers Debian, whoami et IP | [22_connexion_ssh_depuis_windows.png](22_connexion_ssh_depuis_windows.png) |
| Entrée known_hosts du client Windows | [23_fichier_known_hosts_windows.png](23_fichier_known_hosts_windows.png) |
| Paire de clés ED25519 générée sur Windows | [24_generation_cle_ed25519.png](24_generation_cle_ed25519.png) |
| Transfert SCP de la clé publique (pas privée) | [25_scp_copie_cle_publique.png](25_scp_copie_cle_publique.png) |
| Erreur Permission non accordée dans .ssh | [26_erreur_permissions_ssh.png](26_erreur_permissions_ssh.png) |
| Fichier authorized_keys en mode 600 | [27_permissions_authorized_keys.png](27_permissions_authorized_keys.png) |
| Bits spéciaux sur le dossier .ssh | [28_chmod_bits_speciaux.png](28_chmod_bits_speciaux.png) |
| Connexion SSH par clé et passphrase réussie | [29_authentification_cle_ok.png](29_authentification_cle_ok.png) |
| Erreur Bad configuration option détectée par sshd -t | [30_erreur_syntaxe_sshd.png](30_erreur_syntaxe_sshd.png) |
| Validation sshd -t sans erreur | [31_sshd_syntaxe_valide.png](31_sshd_syntaxe_valide.png) |
| Paramètres SSH effectifs sécurisés | [32_sshd_hardening_effectif.png](32_sshd_hardening_effectif.png) |
| Service SSH rechargé et actif | [33_ssh_reload_service.png](33_ssh_reload_service.png) |
| Test négatif : SSH refuse le mot de passe | [34_mot_de_passe_ssh_refuse.png](34_mot_de_passe_ssh_refuse.png) |
| Session SFTP et commandes pwd/lpwd/ls | [35_sftp_connecte.png](35_sftp_connecte.png) |
| Transfert SFTP put terminé | [36_sftp_upload_put.png](36_sftp_upload_put.png) |
| SHA-256 du fichier Windows | [37_hash_sha256_windows.png](37_hash_sha256_windows.png) |
| SHA-256 identique du fichier Debian | [38_hash_sha256_debian.png](38_hash_sha256_debian.png) |
| Transfert SFTP get et vérification SHA-256 du retour | [39_sftp_get_hash_retour.png](39_sftp_get_hash_retour.png) |
| Chemin de clé privée .ppk dans WinSCP (sans fichier privé) | [40_winscp_cle_ppk.png](40_winscp_cle_ppk.png) |
| Vérification empreinte SSH côté WinSCP | [41_winscp_verification_hote.png](41_winscp_verification_hote.png) |
| WinSCP connecté aux fichiers de Debian | [42_winscp_connecte.png](42_winscp_connecte.png) |
| WinSCP : fichier présent sur Windows et Debian | [43_winscp_copie_locale.png](43_winscp_copie_locale.png) |
| Nginx actif sur Debian | [44_nginx_service_actif.png](44_nginx_service_actif.png) |
| Page Welcome to nginx dans Edge Windows | [45_page_nginx_origine.png](45_page_nginx_origine.png) |
| Socket Nginx en écoute sur TCP/80 | [46_nginx_port_tcp80.png](46_nginx_port_tcp80.png) |
| Configuration Nginx par défaut — première partie | [47_configuration_nginx_default_1.png](47_configuration_nginx_default_1.png) |
| Configuration Nginx par défaut — seconde partie | [48_configuration_nginx_default_2.png](48_configuration_nginx_default_2.png) |
| Code source HTML dans Nano | [49_source_page_html.png](49_source_page_html.png) |
| Page SecureWebLab affichée sur Windows | [50_page_secureweblab_navigateur.png](50_page_secureweblab_navigateur.png) |
| Journal access.log : HTTP 200 et favicon 404 | [51_journal_acces_nginx.png](51_journal_acces_nginx.png) |
| Réponse HTTP et HTML vus avec curl -i | [52_curl_reponse_http.png](52_curl_reponse_http.png) |
| PHP 8.4 CLI, PHP-FPM actif et socket Unix | [53_php_cli_fpm_socket.png](53_php_cli_fpm_socket.png) |

---

Pour lire les résultats et les difficultés associées, voir [les incidents](../documentation/07-incidents-et-solutions.md) et [les commandes](../documentation/09-commandes-et-preuves.md).
