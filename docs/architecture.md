# Architecture Cible

Cette page décrit la pile logicielle déployée sur la VM OpenStack, de l'infrastructure jusqu'aux services applicatifs.

## Couches d'infrastructure

```
OpenStack (provisionné via Terraform — couche figée)
│
└── VM Ubuntu 22.04 (2 vCPU, 6 Go RAM, 20 Go disque + 2 Go swap)
    │
    ├── Sécurité
    │   ├── UFW (ports 22, 80, 443 — SSH autorisé avant activation)
    │   └── Fail2Ban (jail sshd actif)
    │
    ├── Docker Engine 29.x + Compose
    │   └── daemon.json : rotation logs, live-restore, mirror mirror.gcr.io
    │
    └── Tutor v21.x (installé via pipx)
```

## Conteneurs Open edX (gérés par Tutor)

```
Tutor local launch
│
├── LMS        (Learning Management System — port 80/443 via Nginx)
├── Studio/CMS (Content Management System)
├── MySQL      (base de données principale)
├── MongoDB    (données de cours et contenu)
├── Redis      (cache et files d'attente)
├── OpenSearch (moteur de recherche, remplace Elasticsearch)
└── Nginx      (reverse proxy, terminaison TLS)
```

## Flux de déploiement

```
Terraform (déjà fait)
    │
    └── Ansible (depuis le poste local, via SSH)
            │
            ├── wp01  vm_prep    → mises à jour, timezone, swap, UFW, Fail2Ban
            ├── wp02  docker     → repo officiel GPG, daemon.json, groupe docker
            ├── wp03  tutor      → installation pipx, configuration
            ├── wp04  openedx    → tutor local launch (conteneurs)
            └── wp05  openedx    → compte admin, smoke test
```

## Réseau

```
Internet
    │
    ├── Port 22  (SSH)      → OpenStack Security Group + UFW
    ├── Port 80  (HTTP)     → Nginx → LMS/Studio
    └── Port 443 (HTTPS)    → Nginx → LMS/Studio (TLS)
```
