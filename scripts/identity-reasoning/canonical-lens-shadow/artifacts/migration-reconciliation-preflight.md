# Migration reconciliation preflight

Captured before repairing remote version `20260711`:

| Local | Remote |
|---|---|
| 20260504 | 20260504 |
| 20260512 | 20260512 |
| 20260706 | 20260706 |
| — | 20260711 |
| 20260711220500 | — |
| 20260711 | — |

The planned reconciliation is limited to replacing the legacy local eight-digit shadow migration with `20260711220000`, then registering that idempotent table migration and the already-applied idempotent lease-claim migration.
