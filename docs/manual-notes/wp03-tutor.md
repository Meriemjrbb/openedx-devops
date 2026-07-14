# WP-03 — Tutor Installation (Manual Notes)

**Owner:** Taieb 🟩
**Date:** _______________

---

## 1. Install Tutor

```bash
pipx install tutor[full]
```

- **Tutor version:** __________________
- **Install method:** pipx / uv / other
- **`~/.local/bin` in PATH ?**  Yes / No

---

## 2. Initial Configuration

```bash
tutor config save --set LMS_HOST=<value> --set CMS_HOST=<value>
tutor config printvalue LMS_HOST
tutor config printvalue CMS_HOST
```

- **LMS_HOST:** __________________
- **CMS_HOST:** __________________
- **ENABLE_HTTPS:** __________________
- Any other custom config values set:

  | Key | Value | Why |
  |-----|-------|-----|
  |     |       |     |

---

## 3. Required Plugins

```bash
tutor plugins list
```

| Plugin | Enabled? | Version |
|--------|----------|---------|
|        |          |         |

---

## ✅ Validation Checklist

- [ ] Tutor installed and responds to `tutor --version`
- [ ] `config.yml` exists in `~/.local/share/tutor/config.yml`
- [ ] All custom values recorded above
- [ ] PATH includes `~/.local/bin`
