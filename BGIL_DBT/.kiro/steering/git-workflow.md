# Git workflow

- When asked to push, commit and push directly to `main` on remote `myrepo`. Do not create feature branches.
- Always `git fetch myrepo` and confirm local `main` is in sync before committing.
- dbt is not installed locally; models run in Snowflake dbt. Verify changes by inspection, not `dbt parse`/`dbt run`.
