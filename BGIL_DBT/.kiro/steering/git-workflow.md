# Git workflow

- When asked to push, commit and push directly to `main` on remote `myrepo`. Do not create feature branches.
- Always `git fetch myrepo` and confirm local `main` is in sync before committing.
- On this machine the only remote is `origin` (no `myrepo`). If `myrepo` is missing, use `origin`. When push fails with divergent branches, `git fetch origin` then `git rebase origin/main` (teammates push to main often), then push.
- dbt is not installed locally; models run in Snowflake dbt. Verify changes by inspection, not `dbt parse`/`dbt run`.
