# Archive — superseded builds, not part of the active dbt project

This directory is **outside** `dbt_project.yml`'s `model-paths` — `dbt run`/`dbt compile`
never sees anything in here. Kept for reference and audit-trail purposes only.

- **`intermediate/` + `raw_vault/`** — the original hand-written Data Vault build
  (staging → intermediate → raw_vault, hand-authored SQL, `dbt_utils.generate_surrogate_key`
  hashing). Superseded by `models/automate_dv/standard/`. See the main project
  `README.md` and `docs/HEALTH_DV_BUILD_NOTES.md` for what it was and why it was replaced.
  Hash values here will **not** match the active build — different hashing formula, an
  independent system, not a drop-in-compatible predecessor.
- **`prototype_automate_dv/`** — the first, deliberately scoped AutomateDV proof-of-concept
  (4 models: `HUB_LOCATION`, `HUB_PARTY`, `SAT_COMMON_ADDRESS`, `SAT_PARTY_ADDRESS_USAGE`)
  built to validate the staging/stitch/hub/link/sat pattern before scaling it to the full
  ~1,200-file `automate_dv/standard` + `augmented` build. Superseded entirely — the
  satellite it was built around (`SAT_PARTY_ADDRESS_USAGE`) has since been removed from the
  canonical model. See `docs/prototype_automate_dv/README.md` for its own notes.

If reviving anything from here, re-verify it against the current `data_5a.js` first — the
canonical model has changed since both of these were built.
