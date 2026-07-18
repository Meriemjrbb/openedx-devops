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

## 18/07/2026

### Reprise du travail Mariem 🟦 (WP-01 + WP-02) — par Adrian

Mariem ayant quitté l'équipe, Adrian reprend les WP-01 et WP-02 (Phase 1 — Infrastructure).
Objectif : terminer le travail manuel sur la VM, documenter chaque valeur dans les templates
`docs/manual-notes/wp01-vm-prep.md` et `wp02-docker.md`, puis converger via les rôles Ansible
existants et prouver l'idempotence (Definition of Done).

### État constaté sur la VM (188.40.148.147, 11:26 CEST)

| Élément                       | État                                                                                                          |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------ |
| OS / Kernel                  | Ubuntu 22.04.5 LTS, kernel 5.15.0-185-generic                                                                 |
| Uptime                       | 23h42, load 0.00                                                                                             |
| RAM                          | 5.8 Gi total, 249 Mi utilisés, 5.3 Gi disponibles                                                            |
| Disque                       | 20G total, 5.7G utilisés, 14G libres (30 %)                                                                  |
| Swap                         | ✅ `/swapfile` 2 Go actif (PRIO -2), persisté dans fstab                                                     |
| Timezone                     | ✅ Europe/Paris (CEST, +0200)                                                                                |
| Locale                       | C.UTF-8 — `en_US.utf8` généré mais non sélectionné                                                            |
| Base deps                    | ✅ curl, git, jq, python3, python3-pip, pipx, unattended-upgrades, ufw, fail2ban, ca-certificates, gnupg    |
| UFW                          | ✅ active, deny incoming, 22/80/443 TCP autorisés (SSH avant enable — conform R1)                            |
| unattended-upgrades          | ✅ active                                                                                                    |
| `/var/run/reboot-required`  | absent                                                                                                       |
| Docker Engine                 | 29.6.1, active + enabled                                                                                     |
| Docker Compose               | v5.3.1                                                                                                       |
| Sources Docker apt           | `docker.sources` deb822 uniquement (legacy `docker.list` déjà supprimé)                                     |
| `/etc/docker/daemon.json`    | Présent mais **sans `registry-mirrors` ni `dns`** — log-rotation + live-restore OK                            |
| Groupe docker pour ubuntu    | ✅ ubuntu ∈ docker (non-root OK)                                                                             |
| Fail2Ban                     | ❌ **service FAILED** (socket inaccessible,	stop-sigterm timeout le 17/07 11:48)                            |
| Tutor (hors-scope Mariem)    | 21.0.8 standalone (pas via pipx)                                                                             |

### Corrections appliquées (session 18/07 avant panne SSH)

1. **Fail2Ban : service relancé** — `systemctl reset-failed fail2ban && systemctl start fail2ban`.
   jail.local déjà conforme (bantime=1h, findtime=10m, maxretry=5, sshd enabled). Statut final : **active**, aucun hôte banni.
2. **`/etc/docker/daemon.json` durci** — ajout `registry-mirrors: ["https://mirror.gcr.io"]`, `dns: ["1.1.1.1"]`, `dns-opts: ["use-vc", "attempts:3", "timeout:5"]`. Log-rotation + live-restore conservés.
3. **Docker redémarré** pour appliquer — `systemctl restart docker` (statut active).

### Diagnostic réseau pour `docker pull`

`docker pull hello-world` échouait systématiquement avec
`dial tcp: lookup registry-1.docker.io on 8.8.8.8:53: i/o timeout`.

Tests effectués depuis la VM :
- UDP/53 → 8.8.8.8 → **timeout** (idem 1.1.1.1, 169.254.169.254)
- TCP/53 → 1.1.1.1 → **OK** (réponses A reçues)
- TCP/53 → 8.8.8.8 → timeout
- `resolvectl query` → résout via systemd-resolved, mais renvoie des IPs `100.x` (split-DNS OpenStack) parfois non joignables

**Conclusion :** le UDP sortant est bloqué/filtré par l'OpenStack, mais le TCP/53 passe.
L'option `dns-opts: ["use-vc"]` dans `daemon.json` force Docker à résoudre en TCP, contournant ainsi le filtrage OpenStack. Le role `docker` Ansible devra porter cette configuration.

### Incident SSH — 18/07 ~11:32

Immédiatement après le `systemctl restart docker`, **SSH port 22 a de nouveau refusé les connexions** :
- `ping 188.40.148.147` → OK (RTT 70-96 ms)
- `nc -zv 188.40.148.147 22` → **Connection refused**
- `nc -zv 188.40.148.147 80` → OK
- `nc -zv 188.40.148.147 443` → OK

Pendant ~15 min, l'incident persiste (10 tentatives à 30 s d'intervalle, jusqu'à 10:42). Le port 80 reste joignable
tandis que le port 22 reste `connection refused`. Le daemon SSH ne répond pas, mais uFW laisse passer le port 80
(règle acceptée avant enable) — UFW n'est donc pas la cause première.

**Hypothèses possibles :**
- `systemctl restart docker` interrompt brièvement la cgroup hierarchy — sous systemd+vsock OpenStack, peut masquer sshd ;
- Intervention du coéquipier (taieb) sur la VM en parallèle ;
- Instabilité NAT/Neutron OpenStack documentée dans les sessions précédentes (ses_009) — le port 22 flappe plus souvent que 80/443 ;
- Fail2Ban fraîchement redémarré pourrait avoir banni l'IP locale après plusieurs échecs SSH successifs (mais `fail2ban-client status sshd` montrait 0 banni juste avant la panne).

**Action immédiate :** laisser SSH se rétablir (typiquement, il revient sous 30 min selon l'historique des ses_009/012),
puis reprendre la procédure d'inspection et le test `docker run --rm hello-world` pour valider WP-02.

**Travail en attente (reprise dés que SSH revient) :**
1. Vérifier `docker run --rm hello-world` — ultime preuve WP-02
2. Lancer les rôles Ansible `vm_prep,security,docker` contre la prod pour converger
3. Prouver l'idempotence : 2e exécution avec `changed=0`
4. Remplir `docs/manual-notes/wp01-vm-prep.md` et `wp02-docker.md` avec les valeurs observées ci-dessus
5. Mettre à jour `wbs.md` : WP-01 → ✅ Done, WP-02 → ✅ Done (après validation `hello-world`)

**Suivi Risk R2 (OpenStack Security Group cross-check) :** sans accès Horizon (403 confirmé en ses_009),
la vérification des règles Security Group pour 22/80/443 est transférée au coéquipier admin Terraform.
Un template `openstack-security-group-check.md` sera créé à cet effet.
