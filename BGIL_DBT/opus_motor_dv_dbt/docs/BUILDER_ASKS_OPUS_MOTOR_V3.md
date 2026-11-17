# BUILDER_ASKS_OPUS_MOTOR_V3 — what goes back, routed by whose call it is

This is for `opus_motor_v3_dv_dbt`, built from the mapping `opus_motor_v2_dv_dbt` used. Every
quantity is in `build_artifacts/BUILD_STATUS.json`, and every item listed here is in
`build_artifacts/reports/unresolved_register.json` under the `kind` named (source:
unresolved_register.json). The builder raises these items and leaves them alone.

## For the user

- **`normalise()`** is called in this map's content-hash keys and is defined nowhere. v3 carries
  it verbatim, so a Snowflake function must exist before `dbt run`. Health v5 refuses it instead.
  One estate-wide policy should be chosen.

## For the source owner

- **`key_object_without_expression`** — the E-7 empty `resolved_key` shells. There is nothing to
  key from.
- **`collapse_group_without_emittable_writer`** — a G-3 group with no writer that can be emitted
  without a source answer.

## For the mapper

- **`child_key_leg_unresolved`** — rows whose map assigns fewer child-key legs than `data_7.js`
  declares for the satellite (for example, a four-leg premium-head key with two legs assigned).
  They are landed with NULL legs and the grain is declared, not invented.
- **`key_not_emittable`**, **`augmentation_without_anchor`**, **`augmentation_on_unbuildable_link`**.
- **P-3 … P-11** are still proposals. Send a delta when they land; v3 builds what the map states.

## For the modeller

- **P-2 `GRAIN_UNRATIFIED` satellites** (listed in `BUILD_STATUS.json`). Each needs the business
  identifier of its line named.
- **P-11** — `HUB_RISK_OBJECT` carries four key spaces that don't join. They are emitted as stated.
- **`reference_target_not_built`** — augmentation homed on `REF_VEHICLE_MODEL`. The build emits no
  reference satellites, so `references/` is empty, as in partner and travel.
- **Links that repeat a hub** aren't built, because key co-occurrence can't tell their legs apart.
