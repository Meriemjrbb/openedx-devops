# Manual Installation Notes

> **WBS Rule:** *"What you do by hand today, you must be able to redo in code tomorrow."*

This directory contains step-by-step templates for the manual installation phase (Option A).

## Process

1. **Mariem 🟦** completes WP-01 → WP-02 on the VM via SSH
2. **Taieb 🟩** completes WP-03 → WP-04 → WP-05 on the VM via SSH
3. Every command is run and every config value is recorded in the corresponding template
4. Adrian 🟨 then updates the Ansible roles to match the documented reality exactly

## Templates

| File | WP | Owner | Est. time |
|------|----|-------|-----------|
| `wp01-vm-prep.md` | WP-01 — VM Preparation | Mariem 🟦 | ~3 days |
| `wp02-docker.md` | WP-02 — Docker | Mariem 🟦 | ~2 days |
| `wp03-tutor.md` | WP-03 — Tutor | Taieb 🟩 | ~2 days |
| `wp04-openedx-deploy.md` | WP-04 — Open edX Deployment | Taieb 🟩 | ~4 days |
| `wp05-admin-accounts.md` | WP-05 — Admin Accounts | Taieb 🟩 | ~1 day |
