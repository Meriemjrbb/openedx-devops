# Open edX DevOps Project

## Contexte

Projet réalisé dans le cadre du stage DevOps RIF.

Infrastructure :
- OpenStack
- Ubuntu 22.04
- Docker
- Docker Compose
- Open edX (Tutor)

VM :
- 2 vCPU
- 6 Go RAM
- 20 Go disque

## Objectifs

- Déployer Open edX
- Automatiser avec Terraform
- Automatiser avec Ansible
- Documenter l'infrastructure
- Mettre en place une démarche DevOps

## Structure du dépôt

```
.
├── ansible/                  # Automatisation (WP-07)
│   ├── ansible.cfg
│   ├── requirements.yml      # Collections Galaxy
│   ├── site.yml              # Playbook principal (WP-01 → WP-05)
│   ├── inventories/
│   │   └── production/       # VM OpenStack (IP via variables d'env)
│   └── roles/
│       ├── vm_prep/          # WP-01 : mises à jour, timezone, dépendances
│       ├── security/         # WP-01 : UFW + Fail2Ban
│       ├── docker/           # WP-02 : Docker dépôt officiel, durci
│       ├── tutor/            # WP-03 : Tutor via pipx, configuration
│       └── openedx/          # WP-04/05 : plateforme + compte admin
├── .github/workflows/        # CI : lint (WP-06) ; déploiement à venir (WP-08)
├── scripts/
│   ├── deploy.sh             # Lance le playbook (charge .env)
│   └── check-idempotence.sh  # 2e run doit être changed=0 (risque R5)
├── terraform/                # Couche infra gelée (déjà provisionnée)
├── docs/                     # Journal, architecture, stratégie de branches
└── wbs.md                    # Plan projet / WBS
```

## Déploiement avec Ansible

### Prérequis

1. `ansible-core` + collections : `ansible-galaxy collection install -r ansible/requirements.yml`
2. Un fichier `.env` à la racine (jamais commité) :

```bash
OPENEDX_VM_HOST=<ip-de-la-vm>
OPENEDX_VM_USER=ubuntu
# facultatif : OPENEDX_SSH_KEY=~/.ssh/openedx_stage_ed25519
# pour WP-05 : OPENEDX_ADMIN_PASSWORD=<mot-de-passe-admin>
```

3. Accès SSH par clé à la VM (l'authentification par mot de passe est à proscrire).

### Commandes

```bash
./scripts/deploy.sh                       # déploiement complet
./scripts/deploy.sh --tags wp01           # seulement la préparation VM
./scripts/deploy.sh --check --diff        # simulation sans modification
./scripts/check-idempotence.sh            # validation Definition of Done
```

Le lancement complet d'Open edX (7-8 conteneurs) est désactivé par défaut :
`./scripts/deploy.sh -e openedx_launch=true` (à coordonner avec Taieb, WP-03/04).

## Workflow Git

Voir [docs/branching-strategy.md](docs/branching-strategy.md) : `main` protégée,
branches `feature/*`, PR avec revue, CI `ansible-lint` obligatoire.

## Équipe

- Meriem Jribi — Infrastructure (WP-01, WP-02)
- Taieb Kaddour — Plateforme (WP-03, WP-04, WP-05)
- Adrian Salvador — Automatisation (WP-06, WP-07, WP-08)
