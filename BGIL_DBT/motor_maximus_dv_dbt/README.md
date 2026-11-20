# Maximus Motor Data Vault — dbt project, v2

Data Vault 2.0 build for Maximus Motor (the shredded EAV UWR and CLM feeds), on Snowflake, using
[AutomateDV](https://automate-dv.readthedocs.io/) (`Datavault-UK/automate_dv`). It follows
[`partner_dv_dbt/`](../partner_dv_dbt/README.md) and [`travel_dv_dbt/`](../travel_dv_dbt/README.md)
exactly, in the same layout as health v5, Maximus Health v4 and OPUS Motor v3. It is built from
**exactly the mapping `motor_maximus_dv_dbt` was built from**.

**Status: not yet `dbt deps`'d or run against Snowflake.** Every model is generated and verified
statically. Model counts, coverage, verification outcomes and the tree digest are in
`build_artifacts/BUILD_STATUS.json`.

## Why v2 exists

`motor_maximus_dv_dbt` hand-wrote every hub, link, satellite and hash. It called no AutomateDV
macro and declared no packages, and spread its vault over `hub_feeds`, `proposed`, `reject_log` and
`assertions` layers. v2 puts the vault on the macros, in the reference layout, under the governing
central-view rule. `motor_maximus_dv_dbt` is left untouched.

## Source documents

These are read in place from `SourceMapping_Skill/Motor Maximus Mapping/outputs/` (read-only),
each asserted by sha256 (`build_profile.json → inputs_pinned`). They are every bundle file the
previous build pinned whose bytes still match, which covers every mapping input, plus `data_7.js`.
The workbook isn't read: it's not a build input, and its bytes no longer match the hash the
previous build recorded for it. The mapper's `RUN_STATE.md` records the handoff and the build's
closure, and the open items there are carried here as directives.

## Architecture

```
Snowflake RAW.MAXIMUS_MOTOR (shredded EAV views)
        │
models/staging/maximus_motor/stg_mxm__*.sql    -- 1:1 casts, feeding and walked views
        ▼
models/automate_dv/standard/
  stitched/stitch_v<NN>_*.sql          -- THE CENTRAL VIEWS. Spine walks are joins and live here.
  staging/stg2_v<NN>_*.sql             -- automate_dv.stage() per view: every hub + link key
  staging/stg2_<satellite>.sql         -- automate_dv.stage() per satellite, read off its view
        ▼
  hubs/ · links/ · satellites/         -- hub() / link() / sat() / ma_sat()
models/automate_dv/augmented/{staging,satellites}   -- the proposals (SAT_AUG_*), not ratified
```

### Spine walks

There are two span types (BUILD_INSTRUCTIONS s1.2), both classified by operator and verified
against `shred.parent_table`.

- **`spine[…]` is a climb.** It is one LEFT JOIN per real level of the graph, whether the span
  names its start as `PARENT_KEY_HASH`, as the row's own view, or as
  `<view>.PARENT_KEY_HASH -> <view>.KEY_HASH -> …`. Hop names abbreviated by the map are resolved
  relative to the row's root.
- **`cross_via_root[… -> ROOT >> T]`** climbs to the root, then descends to `T`. The descended
  value is used only when exactly one distinct value exists; otherwise the row is rejected, never
  picked.

### Mapper directives applied

- **Empty key shells are refused**, including the declared keyless insured party on the CLM pivot.
  `'CUST:'` is never borrowed from a cousin view.
- **The three unruled `CLAIM_APPLICANT_*` rows are withheld** until a source answer exists.
- **A link leg must equal a key form of its hub on that view.** A leg that doesn't is withheld,
  never emitted non-joining.
- **`HUB_RISK_OBJECT` stays dual-grain.** Every satellite fed at interest grain carries a banner,
  and the two grains are never unified.
- **Writer decisions are stated in each satellite.** A `redundant_of` member is withheld in
  favour of its target. Where two writers of one attribute meet with no `redundant_of`, as the
  instructions require, they are merged in column-name order.
- **The vehicle ladder is emitted exactly as written.**

### Conventions

As in Partner, Travel and the other new builds:

- keys are `'{HUB|LNK}_X|' || bk`, hashed by `stage()`, as `<ENTITY>_HKEY`;
- `HASHDIFF` is bare, and child keys are `<LEG>_CK`;
- role satellites are off `HUB_PARTY` with a literal `ROLE_TYPE_CK`;
- `LOAD_DATETIME` is `'!CURRENT_TIMESTAMP()'`;
- the hub business-key column is `<HUB>_BK`.

## Setup

```
dbt deps
dbt debug                         # the 'motor_maximus_v2_dv' profile
```

`vars`: `maximus_motor_raw_database` / `maximus_motor_raw_schema`. Physical schemas are
`std_automate_dv_maximus_motor` and `aug_automate_dv_maximus_motor`.

**Before `dbt run`:** see `BUILD_STATUS.json → preconditions_before_dbt_run`. The ratified
`normalise()` must exist as a Snowflake function.

## Round 1 (2026-11-19): brought to the opus_motor_dv_dbt standard

Edited in place; the generators were not changed and are not to be run (they rewrite every model).
The sections above describe the tree as generated, before this round.

- Setup: `dbt_packages/` (automate_dv 0.11.5, dbt_utils) and `macros/` copied from `opus_partner_dv_dbt`;
  `packages.yml` uses the local copies (no `dbt deps`); `profiles.yml` (profile `motor_maximus_dbt`);
  `dbt_project.yml` rebuilt from the partner template (project `motor_maximus_dv_dbt`, every layer in
  `BGIL_DATA_MODEL`, tags, run-log hooks, `append_new_columns`). `models/automate_dv/` is now `models/raw_vault/`.
- Raw source: `BAGIC_PROD_MIRROR_DB.MAXI_RAW` (vars `maximus_motor_raw_*`), as maximus_partner and maximus_travel.
- stg1: `"REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at` in all 104 models, the maximus_partner cast.
- View markers, so nothing clashes in the shared schema: `stg2_*` -> `stg2_mxm__*`, `stg2_aug_*` ->
  `stg2_mxm_aug__*`, `stitch_*` -> `stitch_mxm__*`. Hub, link and satellite names are unchanged.
- LOAD_DATETIME, as in opus_motor_dv_dbt Round 3: every branch carries `t0.rec_refresh_at as REC_REFRESH_AT`
  (satellite values come only from t0; joined parents only supply hub/link keys); the 15 views output
  `REC_REFRESH_AT` and one `<PARENT>_BK__MA_LOAD_DATETIME` per view and parent key of the multi-active
  satellites. Hub/link and single-active stages use `REC_REFRESH_AT`, multi-active stages their parent key's
  column. The 184 `automate_dv.sat()` satellites set `meta={'apply_source_filter': true}`.
- Not changed: RECORD_SOURCE (still the view name), branch SQL, merges, keys, hubs, links.
- Augmented satellites renamed `sat_aug_<name>` -> `sat_motor_aug_<name>` (152), the same names as opus_motor_dv_dbt,
  so the two motor projects share those tables and nothing else does. Comments updated; no SQL changed.
- Business keys without md5 (3 views, 70 keys): `md5(normalise(X))` -> `nullif(trim(regexp_replace(X, '[[:space:]]+', ' ')), '')`;
  normalise() was undefined in Snowflake. AutomateDV hash keys and HASHDIFF still use MD5.
- RECORD_SOURCE carries the source system: `'!MAXIMUS_stitch_mxm__vNN_<entity>'` (opus motor: `'!OPUS_stitch_motor__...'`).
- Satellites compare only against maximus motor's own rows in shared tables: each satellite stage outputs
  `SOURCE_SYSTEM: '!MAXIMUS_MOTOR'` and all 279 satellites use `src_pk: ['<X>_HKEY', 'SOURCE_SYSTEM']`.
