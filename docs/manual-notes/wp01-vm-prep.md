# WP-01 — VM Preparation (Manual Notes)

**Owner:** Mariem 🟦 *(reprise par Adrian 🟨 le 18/07/2026)*
**Date:** 18/07/2026
**VM IP:** 188.40.148.147 (flottante) → 192.168.100.55 (interne)
**Hostname:** lms-openedx

> Record every command and config value below. These notes are the source
> of truth for the Ansible role later.

---

## 1. System Updates

```bash
sudo apt update && sudo apt upgrade -y
```

**Reboot required?** No (`/var/run/reboot-required` absent le 18/07 11:26)

Dernier statut constaté : kernel 5.15.0-185-generic, aucun paquet en attente.

---

## 2. Timezone & Locale

```bash
timedatectl set-timezone Europe/Paris
timedatectl
```

- **Timezone:** Europe/Paris (CEST, +0200) ✅
- **Locale active:** `C.UTF-8`
- **Locales générées:** C, C.utf8, POSIX, en_US.utf8

Note : `en_US.UTF-8` est généré (requis par `ansible/roles/vm_prep/`) mais non sélectionné
comme locale système. La VM reste sur `C.UTF-8` — aucun impact connu pour Tutor/Open edX.

---

## 3. Base Dependencies

| Package | Version | Installed ? |
|---------|---------|-------------|
| `curl`             | 7.81.0-1ubuntu1.25            | ✅ |
| `git`              | 1:2.34.1-1ubuntu1.17          | ✅ |
| `jq`               | 1.6-2.1ubuntu3.2              | ✅ |
| `python3`          | 3.10.6-1~22.04.1              | ✅ |
| `python3-pip`      | 22.0.2+dfsg-1ubuntu0.7        | ✅ |
| `pipx`             | 1.0.0-1                       | ✅ |
| `unattended-upgrades` | 2.8ubuntu1                 | ✅ |
| `ufw`              | 0.36.1-4ubuntu0.1             | ✅ |
| `fail2ban`         | 0.11.2-6                      | ✅ |
| `ca-certificates`  | 20260601~22.04.1              | ✅ |
| `gnupg`            | 2.2.27-3ubuntu0.8             | ✅ |

Toutes les dépendances WBS WP-01 sont présentes.

---

## 4. UFW Firewall

**Order matters:** allow SSH *before* enabling.

```bash
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
ufw status verbose
```

- **OpenSSH allowed first?** ✅ Yes (règle ordonnée — risk R1 respecté)
- **UFW status:** active
- **Default policy:** deny (incoming), allow (outgoing), deny (routed)
- **Ports allowed (TCP):**

| Port  | Profile / Comment               | IPv4 | IPv6 |
|-------|---------------------------------|------|------|
| 22    | OpenSSH — "allowed BEFORE enable" | ✅ | ✅ |
| 80    | HTTP — Open edX LMS              | ✅ | ✅ |
| 443   | HTTPS — Open edX LMS             | ✅ | ✅ |

---

## 5. Fail2Ban

```bash
sudo apt install fail2ban -y
```

- **bantime:** 1h (conforme defaults Ansible)
- **findtime:** 10m
- **maxretry:** 5
- **jail.local:** présent, géré par Ansible (`ansible/roles/security/tasks/main.yml`)
- **Service status:** ✅ active (relancé le 18/07 11:27 après incident FAILED du 17/07)

⚠️ **Incident :** le 17/07 11:48, le service est passé en état `failed (timeout)` après arrêt.
Le 18/07 à 11:27, `systemctl reset-failed fail2ban && systemctl start fail2ban` a restauré le service.
`fail2ban-client status sshd` → 0 banni, 0 échecs.

**Suivi:** surveiller l'incident récurrent — possiblement lié aux `systemctl stop` pendant les
redémarrages Docker. Voir `docs/journal.md` 18/07/2026.

---

## 6. Resources Verification

| Resource | Target  | Actual               | OK ? |
|----------|---------|----------------------|------|
| RAM      | ≥ 8 GB  | 5.8 GB total         | ⚠️ sous-cible (R3) |
| CPU      | ≥ 4     | 2 vCPU               | ⚠️ sous-cible (R3) |
| Disk     | ≥ 25 GB | 20 GB (14 GB libres)  | ⚠️ sous-cible (R3) |
| Swap     | ≥ 2 GB  | 2 GB ✅              | ✅ |

**Sous-taille de supposition R3** — la VM est en-dessous des recommandations Tutor
(8 Go / 4 vCPU / 25 Go). Le swap 2 Go est le filet de sécurité actuel. Un resize OpenStack
flavor devrait être demandé au coéquipier admin Terraform si les 7-8 conteneurs Tutor
tombent en OOM (à surveiller pendant WP-04).

**Swap file path:** `/swapfile` (2 Go, file, PRIO -2, persisté dans `/etc/fstab`).

---

## 7. OpenStack Security Group Cross-check

- Port 22 (SSH): `nc -zv 188.40.148.147 22` → variable (parfois OK, parfois `Connection refused`)
- Port 80 (HTTP): `nc -zv 188.40.148.147 80` → ✅ OK
- Port 443 (HTTPS): `nc -zv 188.40.148.147 443` → ✅ OK

⚠️ **Vérification couche OpenStack : non effectuée** — Adrian n'a pas accès Horizon/API
(403, voir `docs/journal.md` 14/07/2026). La checklist à remplir est dans
`openstack-security-group-check.md` (transférée à l'admin Terraform).

---

## ✅ Validation Checklist

- [x] No pending updates (`reboot-required` handled)
- [x] Timezone confirmed (Europe/Paris)
- [x] UFW active, ports 22/80/443 open
- [x] Fail2Ban running (relancé le 18/07)
- [x] Resources documented (sous-cible R3 noté)
- [x] Swap configured (/swapfile 2 Go)
- [ ] Security Group matches UFW — **en attente admin Terraform** (R2)
- [x] All config values documented above