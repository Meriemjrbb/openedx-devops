# Journal Technique

## 11/07/2026

### Infrastructure

- Connexion à la VM OpenStack LMS OpenEdX
- Vérification des ressources :
  - 2 vCPU
  - 6 Go RAM
  - 20 Go disque

### Système

- Mise à jour Ubuntu :
  sudo apt update
  sudo apt upgrade -y

- Redémarrage du système :
  sudo reboot

### Vérifications

- free -h
- df -h

Résultat :
- 5.8 Go RAM
- 17 Go disponibles sur disque

### Docker

Installation :

curl -fsSL https://get.docker.com | sudo sh

Version installée :

Docker Engine 29.6.1

Docker Compose :

v5.3.1

### Problème rencontré

Docker Hub inaccessible de manière intermittente.

Symptômes :

- docker pull hello-world échoue parfois
- timeout DNS sur registry-1.docker.io
- timeout DNS sur auth.docker.io

### Diagnostics effectués

- ping google.com
- resolvectl query registry-1.docker.io
- nslookup
- dig
- tracepath
- docker info

Constats :

- Internet fonctionnel
- DNS fonctionnel via systemd-resolved
- Connexions TCP externes instables

Hypothèse :

- Problème infrastructure OpenStack / NAT / Security Group / Neutron

### Validation Docker

docker run hello-world

Résultat :

Hello from Docker!

Docker validé et opérationnel.

## 14/07/2026

### Audit de la VM (Adrian — automation WP-07)

Diagnostic complet effectué via SSH depuis la machine locale (Arch Linux).

#### État constaté

- SSH : clé `~/.ssh/openedx_stage_ed25519` fonctionnelle
- RAM : 5.8 Go (277 Mo utilisés) — aucun conteneur actif
- Disque : 16 Go libres / 20 Go
- Swap : **0 octet** (aucun fichier swap configuré)
- Timezone : Europe/Paris (conforme)
- UFW : actif, ports 22/80/443 ouverts (SSH autorisé avant activation)
- Fail2Ban : actif
- Docker : v29.6.1 + Compose v5.3.1, installé depuis le repo officiel GPG
- Conteneurs Docker : aucun en cours d'exécution
- Tutor : v21.0.8 installé (script standalone, pas via pipx)
- Dépendances de base : curl, git, jq, python3, pipx — tous installés
- Mises à jour : aucune en attente, pas de reboot nécessaire

#### Problèmes identifiés

1. **Docker Hub toujours inaccessible** — `docker pull hello-world` timeout après 60s. Le DNS résout correctement mais les connexions TCP vers registry-1.docker.io sont instables. Même cause que le 11/07 (NAT OpenStack / Neutron).
2. **Repo Docker dupliqué** — `/etc/apt/sources.list.d/docker.list` (ancien format) ET `docker.sources` (deb822) coexistent.
3. **Pas de swap** — risque R3, pas de filet de sécurité mémoire pour les 7-8 conteneurs Tutor.
4. **Pas de daemon.json** — pas de rotation des logs ni de live-restore.
5. **Tutor non installé via pipx** — `pipx list` retourne vide, tutor est un script standalone.
6. **unattended-upgrades inactif** — service non démarré.

#### Corrections appliquées (Ansible roles)

- `vm_prep` : ajout création fichier swap 2 Go + activation unattended-upgrades
- `docker` : ajout mirror `mirror.gcr.io` dans daemon.json + suppression du repo legacy

#### Incident SSH

- Après les sessions de diagnostic, SSH port 22 refuse les connexions (ping OK).
- Cause probable : intervention d'un coéquipier sur la VM ou redémarrage sshd.
- En attente de rétablissement.
