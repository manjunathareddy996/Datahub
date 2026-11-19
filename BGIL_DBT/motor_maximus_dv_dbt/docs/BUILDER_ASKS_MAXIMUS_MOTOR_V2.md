# BUILDER_ASKS_MAXIMUS_MOTOR_V2 — what goes back, routed by whose call it is

This is for `motor_maximus_v2_dv_dbt`, built from the mapping `motor_maximus_dv_dbt` used. Every
quantity is in `build_artifacts/BUILD_STATUS.json`, and every item listed here is in
`build_artifacts/reports/unresolved_register.json` under the `kind` named (source:
unresolved_register.json). The builder raises these items and leaves them alone.

## For the user

- **`normalise()`** is ratified by this pack and defined nowhere. v2 carries it verbatim, so a
  Snowflake function must exist before `dbt run`. Health v5 refuses it instead; one estate-wide
  policy should be chosen.

## For the source owner

- **`claim_applicant_unruled`** — `CLAIM_APPLICANT_DOB`, `_NAME` and `_NAME_PREFIX` are written on
  the proposer's key. Is the applicant always the proposer on this feed? Until that is answered
  they are withheld.
- **`key_object_without_expression`** — empty key shells, including the declared keyless insured
  party on the CLM pivot.
- **`EXPENSE_FEE_HEADS`** — is it a duplicate or a delimited list? It is emitted as mapped.

## For the mapper

- **`child_key_leg_unresolved`** — rows whose map assigns fewer child-key legs than `data_7.js`
  declares, or names a schema with no value. They are landed with NULL legs and the grain is
  declared.
- **`link_leg_not_equal_to_hub_key`** — a link leg that differs from every key form of its hub on
  that view. It is withheld rather than reconciled by choosing.
- **`redundant_of_target_not_emitted`** — a writer withheld as `redundant_of` whose target lands
  nowhere on the table.
- **Merged writer groups** (listed in `BUILD_STATUS.json → writer_decisions`) — two columns writing
  one single-active attribute with no `redundant_of`. They are merged in column-name order. Name a
  single writer, or a child key, if that order is wrong.
- **`augmentation_on_unbuildable_link`**, **`key_not_emittable`**.

## For the modeller

- **Proposed satellites (`SAT_AUG_*`)** on the augmented track await ratification.
- **`HUB_RISK_OBJECT` dual grain** — interest grain on the views without a vehicle handle and object
  grain elsewhere. Ruled legitimate and bannered, not unified.
- **`MOTOR-Q1B`** — the link-key strategy for `POLICY_RISK_ID`.
