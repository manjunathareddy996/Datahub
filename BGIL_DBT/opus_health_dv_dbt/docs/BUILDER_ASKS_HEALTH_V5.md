# BUILDER_ASKS_HEALTH_V5 — what goes back, routed by whose call it is

This is for `health_consolidated_v5_dv_dbt`. Every quantity is in
`build_artifacts/BUILD_STATUS.json`, and every item listed here is in
`build_artifacts/reports/unresolved_register.json` under the `kind` named, with its subject and
reason (source: unresolved_register.json). Nothing below is counted by hand.

The builder raises these items and leaves them alone. None of them was worked around in the
models.

## For the user

1. **Hub business-key column name.** The reference projects name it `PARENT_BK`; v5 names it
   `<HUB>_BK`, because one view-level stage carries several hubs. The alternative (one stage per
   view and hub, named `PARENT_BK`) and its cost in models are in `BUILD_STATUS.json →
   shared_gate_triage → 4.`
2. **`BUILD_RULES.md` §6 contradicts the central-view rule.** §6 calls a per-source-table layer
   "invariant across every build", while the central-view rule feeds every satellite from one
   view. v5 follows the central-view rule, which you ruled governs, and does not edit §6.
3. **`LOAD_DATETIME: '!CURRENT_TIMESTAMP()'`** is kept as the reference projects write it, on
   your instruction. In AutomateDV the `!` prefix normally marks a constant string. Confirm it at
   the first `dbt compile`.

## For the mapper

- **`key_unresolved`** — legacy rows whose anchor hub has no key form on that table in the map or
  in `health_dv_dbt`, or has several distinct forms with nothing on the row choosing between them.
  An example of the second: `HUB_RISK_OBJECT` on the loader tables is keyed both by `md_seq_no`
  and by `pol_serial_no || '|' || md_seq_no`.
- **`child_key_unresolved`** — multi-active rows whose child-key value is a bare label (for
  example "Per-Member Certificate") rather than `Leg = {COLUMN}` or `Leg = VALUE`. They are landed
  with a NULL child key and the grain is declared, not invented.
- **`augmentation_without_anchor`**, **`augmentation_without_target_name`** — augmentation rows
  whose anchor or target satellite appears only in prose.
- **`augmentation_on_unbuildable_link`** — augmentation anchored on a link whose legs can't be
  told apart by hub key (the one-hub role link, or a link that repeats a hub).
- **`key_not_emittable`, empty expression** — delta3 rows the map itself tiers as unresolved.

## For the source owner

- **`key_not_emittable`, `normalise()`** — content-hash keys that call `normalise()`, which is
  defined nowhere in this project, the originals or the bundle. A key rewritten without it would
  be a different key, so these rows are refused, not rewritten.
- **Row filters stated only in prose.** The map's key derivations say versioned tables must be
  filtered (`TOP_INDICATOR='Y'`, `DELETE_FLAG='0'`) and call the polarity convention, not proof.
  None is applied. Once confirmed, each is a one-line entry in `build_profile.json →
  row_filters`.

## For the modeller

- **Links that repeat a hub** (party–party, policy–policy and similar) aren't built: key
  co-occurrence on a row can't say which leg is which.
- **Reference satellites**: `data_7.js` declares them, and this map targets none, so
  `models/raw_vault/standard/references/` is empty, as it is in partner and travel.
