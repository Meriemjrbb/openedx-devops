# OpenStack Security Group Cross-check — Risk R2

> **Owner:** Coéquipier admin Terraform (Aduisne/Vincent)
> **Requested by:** Adrian 🟨 (automation)
> **Date:** 18/07/2026
> **WP:** WP-01 (R2 mitigation)

## Contexte

Le brief WBS (risk R2) exige une double vérification du pare-feu :

> UFW open mais OpenStack Security Group fermé (ou vice-versa) ; traffic bloqué
> avant d'atteindre la VM.

Sur la VM, `ufw status` est ✅ active et autorise 22/80/443 en entée. Mais
**l'accès Horizon / API OpenStack** depuis le compte `adrian` renvoie **403** lorsqu'on
tente de lister les projets (voir `docs/journal.md` 14/07/2026 — `Cannot list projects: 403`).
Adrian n'a donc **pas la capacité de vérifier la couche Security Group OpenStack**.

## Objectif

Vérifier que la Security Group OpenStack attachée à la VM `lms-openedx`
(flottante `188.40.148.147`, interne `192.168.100.55`) autorise bien les mêmes ports
que UFW sur la VM : **22, 80, 443 en TCP entrant**.

## Procédure à exécuter par l'admin Terraform

### Option A — Horizon (UI)

1. Horizon → Project → Network → Security Groups
2. Cliquer sur la Security Group attachée à `lms-openedx`
3. Vérifier les règles `Ingress` pour :

| Port | Protocole | Ether Type | Remote | Présent ? | Action |
|------|-----------|-----------|--------|-----------|--------|
| 22   | TCP       | IPv4      | 0.0.0.0/0 | ☐ Oui ☐ Non | Ajouter si absent |
| 80   | TCP       | IPv4      | 0.0.0.0/0 | ☐ Oui ☐ Non | Ajouter si absent |
| 443  | TCP       | IPv4      | 0.0.0.0/0 | ☐ Oui ☐ Non | Ajouter si absent |

### Option B — OpenStack CLI

```bash
openstack server show lms-openedx -f value -c security_groups
# → nom de la Security Group, ex. "stagiaires-ete-2026"

openstack security group rule list stagiaires-ete-2026 \
  --protocol tcp --ingress -f table

openstack security group rule create stagiaires-ete-2026 \
  --protocol tcp --dst-port 22  --remote-ip 0.0.0.0/0
openstack security group rule create stagiaires-ete-2026 \
  --protocol tcp --dst-port 80  --remote-ip 0.0.0.0/0
openstack security group rule create stagiaires-ete-2026 \
  --protocol tcp --dst-port 443 --remote-ip 0.0.0.0/0
```

### Vérifications additionnelles (incidents récurrents)

Lors des sessions précédentes, le port **22 a refusé les connexions à plusieurs reprises** (ses_009 le 14/07,
de nouveau le 18/07 après un `systemctl restart docker`) alors que les ports 80/443 restaient joignables.
Le ping ICMP est toujours OK. Hypothèses : Neutron/NAT flaky, ou sshd victime des opérations sur Docker.

→ Sauf si cela exclut clairement la Security Group, **garder une règle SSH 0.0.0.0/0** et documenter l'incident
dans journal.md.

## ✅ Sign-off

- [ ] Security Group vérifiée (Horizon ou CLI)
- [ ] Règles 22/80/443 TCP Ingress présentes
- [ ] Compatibilité avec UFW confirmée (les deux couches laissent passer les mêmes ports)
- [ ] Date de vérification : ____________________
- [ ] Vérificateur : ____________________

## Référence

- `wbs.md` — Risque R2 : *Double firewall confusion*
- `docs/journal.md` — 14/07/2026 et 18/07/2026 (incidents SSH port 22)
- `ansible/roles/security/` — implémentation UFW côté VM