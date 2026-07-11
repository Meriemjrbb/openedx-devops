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
