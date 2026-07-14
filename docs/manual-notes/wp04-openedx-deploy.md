# WP-04 — Open edX Deployment (Manual Notes)

**Owner:** Taieb 🟩
**Date:** _______________

---

## 1. Launch

```bash
tutor local launch --non-interactive
```

- **Start time:** __________________
- **End time:** __________________
- **Duration:** __________________
- **Errors encountered:** Yes / No (describe below)

**Notes / issues during launch:**

---

## 2. Container Status

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

| Container | Status | Ports |
|-----------|--------|-------|
| LMS       |        |       |
| Studio    |        |       |
| MySQL     |        |       |
| MongoDB   |        |       |
| Redis     |        |       |
| OpenSearch|        |       |
| Nginx     |        |       |
| (others)  |        |       |

**All 7–8 containers healthy?**  Yes / No

---

## 3. Accessibility

- **LMS reachable (HTTP 200):**  Yes / No — URL: __________________
- **Studio reachable (HTTP 200):**  Yes / No — URL: __________________
- **Nginx serving ?**  Yes / No

---

## ✅ Validation Checklist

- [ ] `tutor local launch` completed without fatal errors
- [ ] All required containers are running (`docker ps`)
- [ ] LMS responds on port 80 (or configured port)
- [ ] Studio responds on port 80 (or configured port)
- [ ] No OOM or disk issues during launch
