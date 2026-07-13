# Branching Strategy

## Model

Simple GitHub Flow — appropriate for a 3-person team and a 5-week project.

```
main ────────●───────●───────●──► always deployable
              \     /
   feature/x   ●───●   (PR + 1 review)
```

## Rules

| Rule | Detail |
|---|---|
| `main` is protected | No direct pushes; PRs only, 1 approving review required |
| Branch naming | `feature/<topic>`, `fix/<topic>`, `docs/<topic>` |
| Owner prefix optional | e.g. `feature/ansible-skeleton` (Adrian), `feature/tutor-config` (Taieb) |
| CI must pass | `ansible-lint` workflow green before merge |
| Small PRs | One work package (or sub-task) per PR |
| No secrets in git | `.env`, keys, passwords — ever ([risk R6](../wbs.md)) |

## Mapping to work packages

| Branch | WP | Owner |
|---|---|---|
| `feature/ansible-skeleton` | WP-06/WP-07 | Adrian |
| `feature/cicd-pipeline` | WP-08 | Adrian |
| `docs/architecture` | WP-10 | Taieb |

## Commit style

Short imperative subject, reference the WP when relevant:

```
Add UFW + Fail2Ban role (WP-01 encoding)
```
