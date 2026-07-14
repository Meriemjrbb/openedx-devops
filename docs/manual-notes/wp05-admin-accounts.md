# WP-05 — Admin Accounts (Manual Notes)

**Owner:** Taieb 🟩
**Date:** _______________

---

## 1. Create Superuser

```bash
tutor local do createuser --staff --superuser admin admin@openedx.local
```

- **Username:** __________________
- **Email:** __________________
- **Temporary password set?**  Yes / No (__________________)
- **Command output:** __________________

> ⚠️ Do NOT record the real password in this repo. Use GitHub Secrets or
> vault for the production value.

---

## 2. Verify Access

- **LMS login works:**  Yes / No
- **Studio login works:**  Yes / No
- **Admin panel accessible (`/admin`):**  Yes / No

---

## 3. Password Procedure (for automation)

How should the admin password be provided to Ansible?

- **Source:** GitHub Secret / Vault / env var
- **Variable name:** __________________

---

## ✅ Validation Checklist

- [ ] Superuser created (staff + admin flags)
- [ ] Login to LMS with admin credentials works
- [ ] Login to Studio with admin credentials works
- [ ] `/admin` panel accessible
- [ ] Password procedure documented (no secrets in repo)
