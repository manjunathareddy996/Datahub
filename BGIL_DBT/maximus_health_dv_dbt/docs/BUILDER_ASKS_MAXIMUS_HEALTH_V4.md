# BUILDER_ASKS_MAXIMUS_HEALTH_V4 — what goes back, routed by whose call it is

This is for `maximus_health_v4_dv_dbt`, built from the mapping `maximus_health_v3_dv_dbt` used.
Every quantity is in `build_artifacts/BUILD_STATUS.json`, and every item listed here is in
`build_artifacts/reports/unresolved_register.json` under the `kind` named (source:
unresolved_register.json). The builder raises these items and leaves them alone; none of them was
worked around in the models.

## For the user

- **Which mapping.** The mapper has issued a later revision of this map. v4 deliberately builds
  from v3's mapping, as instructed. Moving to the later revision means re-pinning
  `build_profile.json → inputs_pinned` and rebuilding.
- **`normalise()`** is ratified by the map and called in content-hash keys, but defined nowhere.
  It is carried verbatim (`normalise_policy: emit`), so a Snowflake function must exist before
  `dbt run`. The alternative policy, `refuse`, drops every key that calls it.

## For the mapper

- **`spine[FOREIGN_KEY -> X]`** — the bundle doesn't define `FOREIGN_KEY`. v4 joins it as
  `child.FOREIGN_KEY = parent.KEY_HASH` at the first real level, then climbs. Please confirm.
- **`child_key_leg_unresolved`** — child-key template operands written in the display-only
  `spine:` form, where the row's own `resolved_key` carries no walk to that column (most of them
  are Member Reference). Per KEY_FUNCTIONS, the display form isn't executed. They are landed with a
  NULL leg and the grain is declared.
- **`key_unresolved`** — augmentation blocks that carry no `resolved_key`, and blocks the map
  itself tiers as `unresolved`.
- **`key_not_emittable`** — LNK keys that pack a two-hub key into one composite operand, which
  can't be split into legs.
- **`augmentation_on_unbuildable_link`** — augmentation anchored on the one-hub role link.

## For the source owner

- **`surrogate_child_key_quarantined`** — the shred-surrogate child keys (the BUILD_INSTRUCTIONS
  blocker). They aren't loaded until a stable business key is sourced.
- **`hard_stop_precondition_unchecked`** — coverage keys whose map entry says to run a data check
  before building. Run the check, then lift the refusal.
- **`reference_decode_unavailable`** — code-to-label rows that need a decode table.
- **Row filters** — none is applied. `build_profile.json → row_filters` takes them once they are
  confirmed.

## For the modeller

- **Augmented grain differs from health v5.** The Maximus map declares several augmentation
  blocks multi-active with a child key, while the OPUS map declares the same `SAT_AUG_*`
  single-active. The two builds write separate schemas, so nothing collides; merging the two
  augmented tracks would be your call.
