# Zodian agent operating rules

This file governs AI agents working in this repository. Repository documentation is guidance, not authorization for production access.

## Operating modes

- **Inspect:** read-only repository, test, configuration, and (when separately authorized) production inspection. Do not mutate data or call a provider.
- **Implement:** make the narrow requested code or documentation change locally. Do not deploy, publish, create batches, or change scheduler state unless explicitly authorized for this task.
- **Deploy:** only after explicit, current-task authorization naming the target, artifact, and scope. Verify the clean source and deployment result.
- **Production:** production inspection or mutation requires an explicit authorization checkpoint immediately before the operation. Authorization never carries forward from an earlier task.

## Permanent boundaries

Inspect the repository and current diff before changing anything. Preserve unrelated work. Keep scope narrow. Do not invent paths, commands, versions, architecture, or recovery steps; mark them unverified.

Current-task instructions override playbook defaults only when they are explicit, safe, and within the requested scope. Never treat a dirty checkout as deployed truth, a migration file as proof that it is applied, or passing tests as authorization to deploy or publish. Distinguish local, development, beta, and production actions.

Branch and commit according to the task request. Do not commit or push unless asked. If a commit is authorized, include only the intended files and report its hash.

Never expose secrets, tokens, authorization headers, or provider payloads containing credentials. Provider calls require explicit authorization and a stated purpose; local tests must be provider-free unless the task explicitly authorizes a canary. Do not create or modify batches, rows, publication state, scheduler/cron state, database data, secrets, or production configuration without explicit authorization.

Preserve evidence before retry, repair, rollback, or replacement. If production impact is unclear, stop rather than improvise.

Testing must match scope. Run relevant provider-free checks and report exact commands and outcomes. Stop rather than improvise when production impact, authorization, rollback, or the correct target is unclear.

## End-of-task report

Report: files changed; evidence used; tests/checks and results; unresolved or unverified areas; deployments (including **zero**); provider calls (including **zero**); batches created (including **zero**); rows written (including **zero**); publication activity (including **zero**); scheduler/cron changes (including **zero**); and commit/push activity. Explicitly report every zero value.
