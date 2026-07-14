# Stratégie de branches

## Modèle

GitHub Flow simple — adapté à une équipe de 3 et un projet de 5 semaines.

```
main ────────●───────●───────●──► toujours déployable
               \     /
    feature/x   ●───●   (PR + 1 revue)
```

## Règles

| Règle | Détail |
|---|---|
| `main` est protégée | Pas de push direct ; PR uniquement, 1 revue approbative requise |
| Nommage des branches | `feature/<sujet>`, `fix/<sujet>`, `docs/<sujet>` |
| Préfixe owner optionnel | ex. `feature/ansible-skeleton` (Adrian), `feature/tutor-config` (Taieb) |
| CI doit passer | Le workflow `ansible-lint` doit être vert avant la fusion |
| PR petites | Un work package (ou sous-tâche) par PR |
| Aucun secret dans git | `.env`, clés, mots de passe — jamais ([risque R6](../wbs.md)) |

## Correspondance avec les work packages

| Branche | WP | Responsable |
|---|---|---|
| `feature/ansible-skeleton` | WP-06/WP-07 | Adrian |
| `feature/cicd-pipeline` | WP-08 | Adrian |
| `docs/architecture` | WP-10 | Taieb |

## Style des commits

Sujet impératif court, référence au WP si pertinent :

```
Add UFW + Fail2Ban role (WP-01 encoding)
```
