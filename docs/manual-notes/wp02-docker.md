# WP-02 — Docker Installation (Manual Notes)

**Owner:** Mariem 🟦
**Date:** _______________

---

## 1. Install Docker Engine

Record which method was used and the exact commands/output.

**Method (official repo / convenience script / other):** __________________

**Docker version installed:** __________________
**Compose version:** __________________

---

## 2. Post-install Hardening

- **daemon.json created ?**  Yes / No
- **Log driver:** __________________
- **Max log size:** __________________
- **Max log files:** __________________
- **Live-restore enabled ?** Yes / No
- **Registry mirror:** __________________
- **Non-root user added to `docker` group ?** Yes / No
  - **Username:** __________________

---

## 3. Verification

```bash
docker info
docker run --rm hello-world
```

- `docker info` OK?  Yes / No
- `hello-world` OK?  Yes / No

---

## ✅ Validation Checklist

- [ ] Docker installed from official repo (GPG verified)
- [ ] `daemon.json` hardened
- [ ] Non-root docker access works (no `sudo`)
- [ ] `hello-world` container ran successfully
- [ ] Compose plugin works (`docker compose version`)
