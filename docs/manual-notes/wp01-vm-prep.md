# WP-01 — VM Preparation (Manual Notes)

**Owner:** Mariem 🟦
**Date:** _______________
**VM IP:** _______________

> Record every command and config value below. These notes are the source
> of truth for the Ansible role later.

---

## 1. System Updates

```bash
sudo apt update && sudo apt upgrade -y
```

**Reboot required?**  Yes / No (check `/var/run/reboot-required`)

---

## 2. Timezone & Locale

```bash
timedatectl set-timezone Europe/Paris
timedatectl
```

- **Timezone:** __________________
- **Locale:** __________________

---

## 3. Base Dependencies

| Package | Version | Installed ? |
|---------|---------|-------------|
| `curl`  |         |             |
| `git`   |         |             |
| `jq`    |         |             |
| `python3` |       |             |
| `pipx`  |         |             |

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

- **OpenSSH allowed first?**  Yes / No
- **UFW status:** __________________
- **Ports allowed:** __________________

---

## 5. Fail2Ban

```bash
sudo apt install fail2ban -y
```

- **bantime:** __________________
- **findtime:** __________________
- **maxretry:** __________________

---

## 6. Resources Verification

| Resource | Target  | Actual  | OK ? |
|----------|---------|---------|------|
| RAM      | ≥ 8 GB  |         |      |
| CPU      | ≥ 4     |         |      |
| Disk     | ≥ 25 GB |         |      |
| Swap     | ≥ 2 GB  |         |      |

**Swap file path:** __________________

---

## 7. OpenStack Security Group Cross-check

- Port 22 (SSH):  Open / Closed
- Port 80 (HTTP): Open / Closed
- Port 443 (HTTPS): Open / Closed

---

## ✅ Validation Checklist

- [ ] No pending updates (`reboot-required` handled)
- [ ] Timezone confirmed
- [ ] UFW active, ports 22/80/443 open
- [ ] Fail2Ban running
- [ ] Resources meet target
- [ ] Swap configured
- [ ] Security Group matches UFW
- [ ] All config values documented above
