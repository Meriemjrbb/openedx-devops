# WP-02 — Docker Installation (Manual Notes)

**Owner:** Mariem 🟦 *(reprise par Adrian 🟨 le 18/07/2026)*
**Date:** 18/07/2026
**VM IP:** 188.40.148.147

---

## 1. Install Docker Engine

Record which method was used and the exact commands/output.

**Method (official repo / convenience script / other):** repo officiel Docker (deb822)
— la VM avait initialement installé Docker via `get.docker.com` (11/07/2026), mais le repo a été
convergé vers le format deb822 `docker.sources` signé GPG. L'ancien fichier `docker.list`
(legacy single-line) a été supprimé.

**Docker version installed:** 29.6.1 (build 8900f1d)
**Compose version:** v5.3.1 (plugin `docker-compose-plugin`)

Fichiers apt Docker :
- `/etc/apt/sources.list.d/docker.sources` ✅ (deb822, GPG signed_by)
- `/etc/apt/sources.list.d/docker.list` ❌ supprimé (anti-doublon)

Paquets installés :
- `docker-ce`, `docker-ce-cli`, `containerd.io`
- `docker-buildx-plugin`, `docker-compose-plugin`

---

## 2. Post-install Hardening

`/etc/docker/daemon.json` mis à jour le 18/07/2026 :

```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "live-restore": true,
  "ipv6": false,
  "max-concurrent-downloads": 1,
  "registry-mirrors": ["https://mirror.gcr.io"],
  "dns": ["1.1.1.1"],
  "dns-opts": ["use-vc", "attempts:3", "timeout:5"]
}
```

- **daemon.json created ?** ✅ Yes
- **Log driver:** json-file
- **Max log size:** 10m
- **Max log files:** 3
- **Live-restore enabled ?** ✅ Yes
- **Registry mirror:** https://mirror.gcr.io (mitigation OpenStack NAT)
- **`ipv6`:** false (registry-1.docker.io ne renvoie que des AAAA sur cette VM, IPv6 indisponible)
- **`max-concurrent-downloads`:** 1 (réduit la pression réseau — OpenStack NAT instable)
- **`dns`:** 1.1.1.1 (UDP/53 vers 8.8.8.8 bloque, 1.1.1.1 fonctionne en TCP)
- **`dns-opts`:** `use-vc` (force DNS en TCP), `attempts:3`, `timeout:5`
- **Non-root user added to `docker` group ?** ✅ Yes
  - **Username:** ubuntu (`groups ubuntu` confirme l'appartenance à `docker`)

### ⚠️ Diagnostic réseau Docker Hub (11/07 + 14/07 + 18/07)

`docker pull hello-world` échouait systématiquement :
```
dial tcp: lookup registry-1.docker.io on 8.8.8.8:53: i/o timeout
```

Tests effectués le 18/07 :
- UDP/53 → 8.8.8.8 → **timeout**
- UDP/53 → 1.1.1.1 → **timeout**
- TCP/53 → 1.1.1.1 → ✅ OK
- TCP/53 → 8.8.8.8 → timeout

→ Le UDP sortant est filtré par OpenStack, seul le TCP/53 passe.
L'option `dns-opts: ["use-vc"]` dans `daemon.json` force Docker à résoudre en TCP.

---

## 3. Verification

```bash
docker info
docker run --rm hello-world
```

- `docker info` OK?
  - Server Version: 29.6.1
  - Logging Driver: json-file
  - Live Restore Enabled: true ✅
  - Registry Mirrors confirmés dans la config ❓ (à revérifier après redémarrage Docker)
- `hello-world` OK? **À valider** — SSH tombé juste après le `systemctl restart docker`
  du 18/07 11:32. Le test `docker run --rm hello-world` n'a pas pu être exécuté.

---

## ✅ Validation Checklist

- [x] Docker installed from official repo (deb822 GPG verified)
- [ ] `daemon.json` hardened ✅ (mirrors + TCP DNS + log-rotation + live-restore)
- [x] Non-root docker access works (ubuntu ∈ docker)
- [ ] `hello-world` container ran successfully — **À revalider après retour SSH**
- [x] Compose plugin works (`docker compose version` → v5.3.1)

---

## Suivi R3 (sous-taille VM)

Le `docker info` révèle également la configuration cgroup/ressources. Si Tutor lance 7-8 conteneurs
sur 5.8 Go RAM + 2 Go swap, surveiller les OOM kills via :
```bash
dmesg -T | grep -i 'killed process\|out of memory'
docker system df
```
Si OOM → demander resize flavor OpenStack à l'admin Terraform.