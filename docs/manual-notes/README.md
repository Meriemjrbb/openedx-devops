# Manual Installation Notes

> **WBS Rule:** *"What you do by hand today, you must be able to redo in code tomorrow."*

This directory contains step-by-step templates for the manual installation phase (Option A).

## Process

1. **Mariem 🟦** *(reprise par Adrian 🟨 depuis le 18/07/2026)* completes WP-01 → WP-02 on the VM via SSH
2. **Taieb 🟩** completes WP-03 → WP-04 → WP-05 on the VM via SSH
3. Every command is run and every config value is recorded in the corresponding template
4. Adrian 🟨 then updates the Ansible roles to match the documented reality exactly
5. **OpenStack Security Group cross-check (R2)** is handed off to the Terraform admin teammate — see `openstack-security-group-check.md`

## Templates

| File | WP | Owner | Est. time |
|------|----|-------|-----------|
| `wp01-vm-prep.md` | WP-01 — VM Preparation | Mariem 🟦 *(→ Adrian 🟨)* | ~3 days |
| `wp02-docker.md` | WP-02 — Docker | Mariem 🟦 *(→ Adrian 🟨)* | ~2 days |
| `wp03-tutor.md` | WP-03 — Tutor | Taieb 🟩 | ~2 days |
| `wp04-openedx-deploy.md` | WP-04 — Open edX Deployment | Taieb 🟩 | ~4 days |
| `wp05-admin-accounts.md` | WP-05 — Admin Accounts | Taieb 🟩 | ~1 day |
| `openstack-security-group-check.md` | WP-01 — R2 mitigation | Admin Terraform | ~10 min |
