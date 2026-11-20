# OPUS Motor Data Vault — dbt project, v3

Data Vault 2.0 build for OPUS Motor, on Snowflake, using
[AutomateDV](https://automate-dv.readthedocs.io/) (`Datavault-UK/automate_dv`). It follows
[`partner_dv_dbt/`](../partner_dv_dbt/README.md) and [`travel_dv_dbt/`](../travel_dv_dbt/README.md)
exactly, in the same layout as health v5 and Maximus Health v4. It is built from **exactly the
mapping `opus_motor_v2_dv_dbt` was built from**.

**Status: not yet `dbt deps`'d or run against Snowflake.** Every model is generated and verified
statically. Model counts, coverage, verification outcomes and the tree digest are in
`build_artifacts/BUILD_STATUS.json`.

## Why v3 exists

`opus_motor_v2_dv_dbt` hand-wrote every hub, link, satellite and hash. It called no AutomateDV
macro and declared no packages, and its incremental models carried no incremental logic. v3 puts
the vault on the macros, in the reference layout, under the governing central-view rule.
`opus_motor_v2_dv_dbt` is left untouched.

## Source documents

These are read in place from `SourceMapping_Skill/OPUS Motor New V2/outputs/` (frozen, read-only).
They are the same files v2 pinned, asserted by sha256 (`build_profile.json → inputs_pinned`),
plus `data_7.js`. The mapper's run-closure files in the bundle root were read for errata E-7 and
E-8; neither changes what is built.

## Architecture

> Paths superseded by Round 1: the vault folder is now `models/raw_vault/`, and stg1 is
> `models/staging/motor/stg_motor__*.sql`.

```
Snowflake RAW.OPUS_MOTOR (flat relational source tables)
        │
models/staging/opus_motor/stg_opus_motor__*.sql   -- 1:1 casts
        ▼
models/automate_dv/standard/
  stitched/stitch_v<NN>_*.sql        -- THE CENTRAL VIEWS (the governing rule). Plain SQL, no hashing.
  staging/stg2_v<NN>_*.sql           -- automate_dv.stage() per view: every hub + link key
  staging/stg2_<satellite>.sql       -- automate_dv.stage() per satellite, read off its view
        ▼
  hubs/ · links/ · satellites/       -- hub() / link() / sat() / ma_sat()
models/automate_dv/augmented/{staging,satellites}
```

It works the same way as health v5. Every satellite is fed whole by one central view. A view has
at most the rule's table limit, unless one satellite needs more. Each attribute is merged across
the view's tables on its satellite's own key, and hubs and links read only view-level stages.
This is a flat source, so every key is an on-view expression, and any walk notation is refused.

### Mapper directives applied

- **E-7**: a `resolved_key` object with no expression (an empty shell) is refused, never keyed on
  a bare prefix.
- **G-3**: for each single-active group of several writers, the member carrying `redundant_of` is
  withheld and its target is emitted. Each group's decision is written into its satellite's SQL
  and into `BUILD_STATUS.json`, because `redundant_of` has no representation in SQL. A check fails
  if any group still has two writers.
- **P-2**: satellites whose self-named child-key blocks write several attributes of one entity are
  emitted as the map states and stamped `GRAIN_UNRATIFIED` in their SQL.
- **P-11**: the four `HUB_RISK_OBJECT` key spaces are emitted exactly as the map states. No
  unifying key is invented, and `OBJECT_ID` is never stamped onto an empty key.
- **F-2**: the frozen map carries the ratified fix: `CLM_LANDLINE_NO` is unmapped and
  `CUST_TELEPHONE` is the sole writer.
- **Scope**: the out-of-scope OEM and SER tables are matched by equality, never containment. The
  map carries none, and this is verified.

### Conventions

As in Partner, Travel, health v5 and Maximus v4:

- keys are `'{HUB|LNK}_X|' || bk`, hashed by `stage()`, as `<ENTITY>_HKEY`;
- `HASHDIFF` is bare, and child keys are `<LEG>_CK`;
- role satellites are off `HUB_PARTY` with a literal `ROLE_TYPE_CK`;
- `LOAD_DATETIME` is `'!CURRENT_TIMESTAMP()'`;
- the hub business-key column is `<HUB>_BK`.

`motor_dv_dbt`, the earlier AutomateDV motor build, prefixes its key names with the entity
(`HUB_ASSESSMENT_HKEY`). v3 follows Partner and Travel instead.

## Setup

> Superseded by Round 1: packages are vendored under `dbt_packages/`, so `dbt deps` is not used.
> The profile is `opus_motor_dbt` and the vars are `motor_raw_database` / `motor_raw_schema`.

```
dbt deps
dbt debug                         # the 'opus_motor_v3_dv' profile
```

`vars`: `opus_motor_raw_database` / `opus_motor_raw_schema`. The physical schemas,
`std_automate_dv_opus_motor` and `aug_automate_dv_opus_motor`, are separate from every other
build.

**Before `dbt run`:** see `BUILD_STATUS.json → preconditions_before_dbt_run`. `normalise()` must
exist as a Snowflake function.

## Round 1 (2026-11-16): runnable scaffolding and stg1, following `utils/skill.md`

The files were edited in place. The generators were not changed and cannot run here, because their
pinned inputs are not in this workspace. The models below therefore no longer match what the
generators would emit.

### Project setup (skill.md Segment 2, "Project config files")

- `dbt_packages/` (automate_dv 0.11.5 and dbt_utils) and `macros/` were copied unchanged from
  `opus_partner_dv_dbt`. `packages.yml` points at the local copies, so `dbt deps` is not used.
- `profiles.yml` was added from the skill.md template, with the profile `opus_motor_dbt`.
- `dbt_project.yml` was rebuilt from the partner file: project `opus_motor_dv_dbt`, the same tags,
  run-log hooks and `append_new_columns`. Only the name, profile, vars and schemas differ.
- *(Superseded by Round 2: every layer is now in `BGIL_DATA_MODEL`.)* The schemas stay
  `stg_opus_motor`, `std_automate_dv_opus_motor` and `aug_automate_dv_opus_motor` rather than the
  template's shared `BGIL_DATA_MODEL`. 111 motor stg2 view names already exist in
  `opus_health_dv_dbt` or `opus_partner_dv_dbt`, so in the shared schema a motor run would replace
  those projects' views.
- `models/automate_dv/` moved to `models/raw_vault/`. Empty `analyses/`, `seeds/`, `snapshots/` and
  `tests/` folders were added.
- The raw source vars are `motor_raw_database` / `motor_raw_schema`, set to the replica that partner
  and travel point their `*_raw` sources at (`BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE`). This is not
  yet confirmed for the motor tables: run `analyses/round1_raw_source_check.sql`.

### stg1 (skill.md section 1a)

- The models are now `models/staging/motor/stg_motor__<table>.sql` (previously
  `staging/opus_motor/stg_opus_motor__<table>.sql`) and read the source `motor_raw`. The 838 refs to
  them in the 26 central views were updated.
- `"INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at` was added to all 93 models.
- Not done, typed casts: there is no schema snapshot of the motor raw tables. Query 2 of
  `analyses/round1_raw_source_check.sql` produces one.
- Not done, dropping `BJAZ_MOT_RENEWAL_HIST` (defect class #13): it has 41 columns that its current
  twin `BJAZ_MOT_RENEWAL` lacks, and 37 of them are mapped (for example `chassis_no`, `engine_no`,
  `registration_no`, `vehicle_make`). It feeds 24 satellites through 11 central views, so dropping
  it would lose mapped data.

### Do not run the generators

- `generators/run_om3_build.py` deletes every `.sql` and `.yml` file under `models/` before it reads
  the pinned inputs. Here the inputs are missing, so it would delete the models and then fail.
- `om3_verify.py` and `om3_status.py` still read `models/automate_dv/`, and `build_artifacts/`
  describes the tree as it was before Round 1.

### Still open before `dbt run`

- `LOAD_DATETIME` is still `'!CURRENT_TIMESTAMP()'` and `RECORD_SOURCE` is still the view name
  (plan point 4).
- The `normalise()` Snowflake function, and the raw source location above.

## Round 2 (2026-11-16): shared schema `BGIL_DATA_MODEL`

- By decision, every layer now lands in `BGIL_DATA_MODEL`, as in the partner template. Hubs, links
  and satellites with the same name as another project's are one physical table, so never
  `--full-refresh` them.
- So that a motor run cannot replace a sibling project's view, motor's view layers carry a motor
  marker. This follows the `mt` / `mp` infixes in the maximus projects:

  | Layer | Before | After |
  |---|---|---|
  | stg2, standard (155) | `stg2_<name>` | `stg2_motor__<name>` |
  | stg2, augmented (117) | `stg2_aug_<name>` | `stg2_motor_aug__<name>` |
  | Central views (26) | `stitch_v<NN>_<entity>` | `stitch_motor__v<NN>_<entity>` |

  Every reference was rewritten, including the `!stitch_...` `RECORD_SOURCE` literals that plan
  point 4 replaces. Hub, link and satellite names are unchanged, because those tables are meant to
  be shared.
- Open, for plan point 4: motor's hubs name their business-key column `<HUB>_BK` (as
  `opus_health_dv_dbt` does). Partner, travel and the maximus projects write `PARENT_BK` to the same
  hub tables.
  *(Decided 2026-11-16: keep `<HUB>_BK`, e.g. `PARTY_BK`. Consequence: the DM-T2 hash-key audit
  recomputes hub keys from `PARENT_BK` only, so it will skip motor's hub rows until its generator
  also reads `<HUB>_BK`.)*
- Deferred: the stitch design for satellites (plan point 3), and with it the satellites'
  `RECORD_SOURCE` and `LOAD_DATETIME` (plan point 4). The 26 central views stay as they are.

## Round 3 (2026-11-18): real source times in LOAD_DATETIME

- Every branch of the 26 central views carries its table's `inc_job_updated_at` as `INC_JOB_UPDATED_AT`,
  just before `__PREC` (the same position in every branch: the branches match columns by position).
  Each final select now reads `from merged m` and outputs:
  - `INC_JOB_UPDATED_AT`, the row's own source time, and
  - for each of the 95 multi-active satellites, `<SAT>__LOAD_DATETIME` =
    `max(INC_JOB_UPDATED_AT) over (partition by <parent key>)` over the rows that carry that satellite's data.
    `ma_sat()` takes a parent's latest set to be its rows with the highest `LOAD_DATETIME`, so all child rows
    of one parent must share one time; per-row times would re-insert the whole set on every run.
- Stages: `LOAD_DATETIME: '!CURRENT_TIMESTAMP()'` (which AutomateDV stores as the text `CURRENT_TIMESTAMP()`)
  is replaced in all 272: `'INC_JOB_UPDATED_AT'` for the 26 hub/link stages and 151 single-active satellite
  stages, `'<SAT>__LOAD_DATETIME'` for the 95 multi-active satellite stages.
- The 151 `automate_dv.sat()` satellites set `meta={'apply_source_filter': true}`: only rows whose
  `LOAD_DATETIME` is later than the satellite's latest stored row for that key reach the HASHDIFF check.
  `ma_sat()` has no such option, so the 95 multi-active satellites are unchanged.
- Not changed: `RECORD_SOURCE` (still `'!stitch_motor__...'`), the branch SQL, the merges, the keys, macros.
- Before `dbt run`: the raw tables must have `INC_JOB_UPDATED_AT`; `normalise()` must exist; in tables another
  project created first with a text `LOAD_DATETIME`, the time filter does not compare real times.

## Round 4 (2026-11-19): LOB in augmented satellite names

- The 117 augmented satellites are renamed `sat_aug_<name>` -> `sat_motor_aug_<name>` (rule: `sat_<lob>_aug_<name>`),
  so motor's augmented tables no longer share a physical table with health, travel or partner. maximus_motor_dv_dbt
  uses the same names, so the two motor projects share them. Comments naming the satellites were updated; no SQL changed
  (nothing refs a satellite). Standard satellites, hubs and links keep their shared names. build_artifacts/ still shows
  the generated names. Recorded in .kiro/steering/modeller-learnings.md (overrides utils/skill.md's no-LOB rule).

## Round 5 (2026-11-19): business keys without md5; normalise() no longer needed

- `normalise()` (undefined in Snowflake; 12 views failed with "Unknown functions NORMALISE") and the `md5` around it
  are replaced in all 300 content keys: `md5(normalise(X))` -> `nullif(trim(regexp_replace(X, '[[:space:]]+', ' ')), '')`.
  Snowflake has no built-in NORMALIZE; trim plus whitespace-collapse is done with built-ins, so no function must exist.
- The business keys (e.g. PARTY_BK, LOCATION_BK) are now the normalised text itself, as partner's address keys are.
  The hash keys are unchanged in kind: AutomateDV still builds every *_HKEY and HASHDIFF with MD5.
- Consequence: names, phone numbers, addresses etc. that form those keys are stored as plain text in the BK columns
  of the views and the shared hubs (HUB_PARTY, HUB_LOCATION, ...).
- The "normalise() must exist" precondition above (and in build_artifacts/) no longer applies.

## Round 6 (2026-11-19): source system in RECORD_SOURCE

- All 272 stages: `RECORD_SOURCE: '!stitch_motor__vNN_<entity>'` -> `'!OPUS_stitch_motor__vNN_<entity>'`: the view
  name is kept and the source system is prefixed (maximus_motor_dv_dbt uses `'!MAXIMUS_stitch_mxm__vNN_...'`), so opus
  and maximus rows are told apart and validation filters on `OPUS_` / `MAXIMUS_` include motor.
- Rows loaded before this keep the old value (hubs/links insert only new keys):
  analyses/cleanup_old_record_source.sql counts and deletes motor's own old rows, then re-run the layer.

## Round 7 (2026-11-19): satellites compare only against motor's own rows

- Shared satellite tables hold rows from several LOBs, and AutomateDV `sat()` / `ma_sat()` pick the latest stored row
  per key from ANY project. Each satellite stage now outputs `SOURCE_SYSTEM: '!OPUS_MOTOR'` and every satellite uses
  `src_pk: ['<X>_HKEY', 'SOURCE_SYSTEM']` (AutomateDV's composite-key support, no new macro). The latest-row lookup,
  apply_source_filter and the HASHDIFF comparison then run per (key, SOURCE_SYSTEM). Other projects' rows have
  SOURCE_SYSTEM NULL and are never matched. maximus_motor_dv_dbt uses '!MAXIMUS_MOTOR'.
- Not `RECORD_SOURCE` itself: it is already src_source, and listing it twice makes AutomateDV emit a trailing comma.
- Hubs and links are unchanged. Satellites loaded before this need motor's rows deleted and reloaded.
