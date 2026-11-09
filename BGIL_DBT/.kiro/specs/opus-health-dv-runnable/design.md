# Design Document

## Overview

This design makes `BGIL_DBT\opus_health_dv_dbt` (the **Health_Project**) a runnable dbt
project and reshapes its 46 numbered "central-view v4" (hcon4) stitched models into the
macro-based stitched form used by the fully runnable `BGIL_DBT\opus_partner_dv_dbt`
(the **Partner_Project**).

The work has exactly two deliverables:

1. **Scaffolding** — the non-model files/directories a dbt project needs to parse and
   run: `dbt_project.yml`, `packages.yml`, `profiles.yml`, vendored `dbt_packages/`,
   `macros/`, the standard empty dbt directories, and dbt `sources` definitions for the
   staging inputs the stitched models read.
2. **Stitched reshape** — rewrite each `models/stitched/stitch_NN_*.sql` from an
   inline-join central view into a thin model that declares `sources`, `output_columns`,
   `coalesce_rules`, and `hub_keys` as Jinja vars and emits its body through an extended
   `stitch_incremental_hcon` macro with a `target_sat`.

Everything is authored as SQL (dbt models + Jinja) and YAML/JSON (scaffolding). The
Partner_Project is the structural template; the `dv2-automatedv-dbt-builder` skill is the
conventions reference.

### Option C: hub-key preservation via an extended macro (authoritative)

An earlier revision reshaped onto the partner's `stitch_incremental` macro verbatim. That
macro has no slot for the central view's inline hub business keys, so the reshape dropped
them — and the untouched downstream `stage/`, `hub_feeds/`, and `vault/` layers, which read
those `HUB_*_BK` columns, would no longer compile. That end-to-end compile gap was the
feature's single largest risk.

**Option C closes the gap** by preserving the hub-key derivation instead of dropping it:

- `generators/` is **not edited** (Requirement 3.6 unchanged).
- `macros/stitch_incremental.sql` is copied verbatim from the Partner_Project and stays
  **unchanged**.
- A **new** macro `macros/stitch_incremental_hcon.sql` (macro name
  `stitch_incremental_hcon`) is created as a copy of `stitch_incremental` extended with a
  `hub_keys` parameter. It carries each contributing source's hub-key source expressions
  through the same CTE pipeline and evaluates the central view's hub business-key columns
  in the final `SELECT`, alongside `parent_bk`, the `output_columns`, `record_source`, and
  `inc_job_updated_at`.
- Reshaped health stitched models call `stitch_incremental_hcon` and pass `hub_keys`, so
  the inline `HUB_*_BK` derivation is **preserved**. The downstream `stage/`,
  `hub_feeds/`, and `vault/` layers keep compiling against those hub keys. The
  hub-key part of the compile gap (former Risk 1) is closed. **Correction:** the earlier
  claim that end-to-end compile is expected to succeed no longer holds for multi-satellite
  views, because of the one-stitch-per-satellite split (see "One stitch per satellite" and
  Risks). Hub keys are preserved, but `stage_NN_*` must still be repointed at the
  per-satellite stitches (recorded follow-up).

Scope is still deliberately narrow: the Downstream_Layers are **not modified** (they
simply keep working because the hub keys are preserved). The record-source value still
changes (independent of the hub-key fix) and remains a recorded follow-up. The
`generators/` code is not edited, and re-running it would overwrite the hand reshapes and
would not emit the new macro — also recorded.

### What was confirmed from the files (not assumed)

- **Partner `dbt_project.yml`**: `name: opus_partner_dv_dbt`, `profile: opus_partner_dbt`,
  vars `partner_raw_database` / `partner_raw_schema` (+ `_test_` variants), and a
  `models:` map keyed by layer under `staging` and `raw_vault.{standard,augmented}`.
- **Partner `packages.yml`**: two local packages, `dbt_packages/dbt_utils` and
  `dbt_packages/automate_dv`.
- **Partner `profiles.yml`**: profile `opus_partner_dbt`, `dev` and `prod` Snowflake
  outputs, with `account: "_"` and `user: "_"` placeholders in `dev`.
- **Partner macros present**: `stitch_incremental.sql`, `sat_multi_source.sql`,
  `ma_sat_multi_source.sql`, `hash.sql`, `location_address_key.sql`, `watermark.sql`,
  `get_run_date.sql`, `generate_schema_name.sql`.
- **Partner stitched form** (`stitch_common_classification.sql`): `config(materialized='view')`,
  then `sources` (list of dicts: `model`, `alias`, `key_column`, `ldts_column`,
  `columns[{src,tgt}]`, `source_tag`), `output_columns` (list), `coalesce_rules`
  (dict `col -> [alias,...]`), then `{{ stitch_incremental(..., unique_key='parent_bk',
  target_sat='sat_...') }}`.
- **`stitch_incremental` macro contract**: requires each source `source_tag` to be
  `<SYSTEM>_<TABLE>` (it splits on `_` and takes element 0 as the single source-system
  group); errors on a missing/malformed tag or on mixed prefixes. The group is used only
  to scope the incremental watermark (`RECORD_SOURCE LIKE '<group>_%'`). The emitted
  `record_source` column is a comma-joined list of the contributing `source_tag`s.
- **Health staging reality**: staging models are `config(materialized='view')`, cast every
  column to varchar, and read `{{ source('<run>', '<RAW_TABLE>') }}` where `<run>` is one
  of three runs — `opus_health_legacy_v4`, `opus_health_v2`, `opus_health_delta3` — and
  `<RAW_TABLE>` is the real upstream name (e.g. `BJAZ_POLICY_BASES_EXTN`). There is no
  `_health__sources.yml` yet.
- **Health record-source convention (critical)**: the Health_Project's existing downstream
  satellites set `RECORD_SOURCE` to the **stitch model-name literal**, e.g.
  `'stitch_31_policy__account_balance' as RECORD_SOURCE` in `sat_account_balance.sql` and
  `sat_account_definition.sql`. Health does **not** use an `OPUS_HEALTH_<TABLE>` string
  anywhere as a record source. This directly contradicts the partner `source_tag`
  convention and the macro's prefix contract, and drives a design decision below.
- **Health hashing**: the stitched view computes no hash; `stage_NN_*` is the single hash
  site and derives 19 `HUB_*_HK` values from `HUB_*_BK` columns the stitch produced
  inline (e.g. `md5(upper('HUB_POLICY|' || (HUB_POLICY_BK)))`). Because the extended
  macro preserves those `HUB_*_BK` columns on the reshaped stitch output, the stage hash
  site keeps resolving them.
- **Central-view final-SELECT column families** (confirmed from
  `stitch_01_policy__policy_header.sql`): the central view's terminal `SELECT` emits three
  families of columns:
  1. **Spine / merged hub BKs** — e.g.
     `coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, ...) as HUB_POLICY_BK`
     (stitch 01 has ~24 such merged `HUB_*_BK` columns).
  2. **Auxiliary per-source hub BKs** — e.g.
     `t4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE as T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`
     (stitch 01 has ~60 such `TN__HUB_*_BK__*` columns).
  3. **Satellite payload attributes** — e.g.
     `coalesce(...) as POLICY_STATUS` (these map to `output_columns` / `coalesce_rules`).
  Family 3 is already handled by `output_columns` / `coalesce_rules`. Families 1 and 2
  are exactly what the new `hub_keys` input carries: each `hub_keys` entry's `name` is the
  output column (`HUB_POLICY_BK`, `T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`, ...) and its
  `expr` is the `coalesce(...)` / `tN.col` expression transcribed verbatim from the
  central view.
- **Central-view source-level hub-key expressions** (confirmed): each `tN` CTE computes
  its hub-key source columns inline — bare `nullif(trim(...))`, prefix literals
  (`'LOANACC:'`, `'PRODUCT:'`, `'TXN:'`, `'CUSTID:'`, `'EMP:'`, `'PARTID:'`), and
  `md5(normalise(upper(...)))` address hashes. These are the alias-local columns the
  family-1/2 expressions reference (e.g. `t4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`), so they
  must be reproduced inside each source CTE for the `hub_keys[].expr` references to
  resolve.

## Architecture

### Directory layout — before

```
opus_health_dv_dbt/
  BUILDER_ASKS_HEALTH_V4.md
  build_artifacts/
  build_profile.json
  generators/                      # hcon4 family — DO NOT EDIT
  inputs/                          # pinned column maps + handoff facts
  models/
    staging/      stg_*.sql        # view, varchar casts, source('<run>','<RAW>')
    stitched/     stitch_NN_*.sql  # 46 inline-join central views (REShAPE TARGET)
    stage/        stage_NN_*.sql   # hash site (DOWNSTREAM — out of scope)
    hub_feeds/    hf_*.sql         # (DOWNSTREAM — out of scope)
    vault/
      hubs/ links/ satellites/     # (DOWNSTREAM — out of scope)
    augmented/
    assertions/
  # NO dbt_project.yml / packages.yml / profiles.yml / dbt_packages/ / macros/
  # NO analyses/ seeds/ snapshots/ tests/ docs/
  # NO sources yml for staging inputs
```

### Directory layout — after

```
opus_health_dv_dbt/
  dbt_project.yml                  # NEW — adapted from partner
  packages.yml                     # NEW — local dbt_utils + automate_dv
  profiles.yml                     # NEW — profile opus_health_dbt (dev/prod)
  dbt_packages/                    # NEW — vendored, copied from partner
    dbt_utils/
    automate_dv/
  macros/                          # NEW — copied from partner (+ one new macro)
    stitch_incremental.sql         # copied from partner, UNCHANGED
    stitch_incremental_hcon.sql    # NEW — copy of stitch_incremental + hub_keys param
    sat_multi_source.sql  ma_sat_multi_source.sql  hash.sql
    location_address_key.sql  watermark.sql  get_run_date.sql
    generate_schema_name.sql
  analyses/ seeds/ snapshots/ tests/ docs/   # NEW — standard empty dirs
  generators/                      # UNCHANGED
  inputs/ build_artifacts/ build_profile.json
  models/
    staging/
      _health__sources.yml         # NEW — 3 source runs, raw tables
      stg_*.sql                    # UNCHANGED
    stitched/
      stitch_NN_*.sql              # RESHAPED to partner form, one stitch per satellite
                                   # (45 original filenames reshaped; stitch_35 left as-is;
                                   #  plus additional stitch_NN_<spine>__<sat_tail>.sql files
                                   #  for every extra satellite a central view feeds)
    stage/ hub_feeds/ vault/ augmented/ assertions/   # UNCHANGED
```

### Model layers present in the Health_Project (for the `models:` map)

Confirmed from `models/`: `staging/`, `stitched/`, `stage/`, `hub_feeds/`,
`vault/{hubs,links,satellites}`, `augmented/`, `assertions/`. The Health_Project uses a
**flat** layer layout under `models/` (e.g. `models/stitched`, `models/stage`,
`models/vault/hubs`), unlike the Partner_Project's nested `raw_vault/standard/...`. The
`dbt_project.yml` `models:` map is therefore keyed to the Health_Project's own directory
names, using the canonical tag-and-materialization *form* from the partner (each layer
gets `+materialized` and `+tags`, incremental layers also get
`+on_schema_change: append_new_columns`), not the partner's directory names verbatim.

## Components and Interfaces

The deliverables are files, so the "components" are the artifacts produced and the
interfaces are the dbt/Jinja contracts between them.

### Component: Project configuration (`dbt_project.yml`, `packages.yml`, `profiles.yml`)

- **Responsibility**: make the project parseable and runnable — declare the project name,
  the profile binding, the raw-location vars, the per-layer materialization/tag map, the
  local package dependencies, and the Snowflake connection outputs.
- **Interface (consumed by dbt)**: `profile: opus_health_dbt` in `dbt_project.yml` must
  match the top-level key in `profiles.yml`. `vars.health_raw_database` /
  `health_raw_schema` are read by `_health__sources.yml`. The `models:` map keys must
  match directory names under `models/`. `packages.yml` `local:` paths must point at the
  vendored `dbt_packages/` subtrees.

### Component: Vendored dependencies (`dbt_packages/`, `macros/`)

- **Responsibility**: resolve the stitch macros and supporting macros and the
  `dbt_utils` / `automate_dv` packages locally, with no network install.
- **Interface (consumed by models)**: the reshaped stitched models call
  `stitch_incremental_hcon(sources, output_columns, coalesce_rules, hub_keys, unique_key, target_sat)`.
  The partner `stitch_incremental` macro is still vendored verbatim (unused by the health
  reshape but kept as the unmodified template); the health models use the extended macro.

### Component: Extended stitch macro (`macros/stitch_incremental_hcon.sql`)

- **Responsibility**: do everything `stitch_incremental` does (watermark windowing,
  affected-keys scoping, per-source de-dup, QUALIFY row-pick, payload COALESCE, record
  source, `inc_job_updated_at`) **and additionally** carry each source's hub-key source
  expressions through the CTE pipeline and emit the central view's hub business-key
  columns in the final `SELECT`. This preserves the inline `HUB_*_BK` derivation the
  downstream layers consume.
- **Derivation**: `stitch_incremental_hcon` is a copy of `stitch_incremental` with one new
  parameter, `hub_keys`, and a change to the per-source CTEs and the `final` CTE. The
  partner original is left byte-unchanged in `macros/stitch_incremental.sql`.
- **Interface (the fixed boundary every reshaped model must satisfy)**:
  - `sources`: list of
    `{model, alias, key_column, ldts_column, columns:[{src,tgt}], hub_key_columns:[{src_expr,tgt}], source_tag}`
    — `hub_key_columns` is a **new, parallel** list: `src_expr` is a raw SQL expression
    (bare column, prefix literal, or `md5(normalise(upper(...)))`) transcribed from the
    source's `tN` CTE in the central view, and `tgt` is the alias-local hub-key column
    name it is aliased to (e.g. `HUB_POLICY_BK__CONTRACT_ID`).
  - `output_columns`: list of satellite payload attribute names (unchanged from partner).
  - `coalesce_rules`: dict `attr -> [alias, ...]` in precedence order (unchanged).
  - `hub_keys`: **new** — an ordered list of `{name, expr}` where `name` is the hub-key
    output column (`HUB_POLICY_BK`, `T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`, ...) and
    `expr` is the raw SQL expression that reproduces the central view's hub-key column
    (a `COALESCE(...)` across `alias.tgt` references, or a single `alias.tgt`),
    transcribed verbatim from the central view's final `SELECT`.
  - `unique_key`: grain key column name (fixed to `'parent_bk'`).
  - `target_sat`: satellite name (enables the parameterized watermark path, unchanged).
    Exactly one satellite per stitch model (see "One stitch per satellite").
  - **`key_column` alias resolution (macro fix, already implemented in
    `macros/stitch_incremental_hcon.sql`)**: staging models contain only raw columns, so a
    `sources[].key_column` such as `HUB_POLICY_BK__CONTRACT_ID` does not exist on the
    staging relation. By convention `key_column` is an **alias equal to the `tgt` of one of
    that source's `hub_key_columns` entries**. The macro builds a `key_exprs` dict keyed by
    `src.alias`, mapping each source to the `src_expr` of the `hub_key_columns` entry whose
    `tgt` equals its `key_column`. It uses `key_exprs[src.alias]` in two places: the
    `affected_keys` UNION (SELECT and WHERE of each source) and each per-source CTE
    (`<expr> AS unique_key` in SELECT, and the `IS NOT NULL` / window WHERE). If no
    `hub_key_columns` entry matches, the macro falls back to using `key_column` unchanged
    (partner-compatible behavior for sources where `key_column` is a real column).
    Reshaped models therefore must declare, on every source, a `hub_key_columns` entry whose
    `tgt` is that source's `key_column`.
  - `source_tag` per source must match `^<SYSTEM>_<TABLE>$`; all sources in one stitch
    must share the `<SYSTEM>` segment (text before the first `_`) — unchanged.
- **How hub keys are threaded (the one structural change vs the partner macro)**:
  1. **Per-source CTE** (`{{ src.alias }} AS (...)`): in addition to the existing
     `key_column AS unique_key`, the `NULLIF(TRIM(TO_VARCHAR(col.src))) AS col.tgt`
     payload columns, and `ldts_column`, the CTE also selects each
     `hub_key_columns[]` entry as `{{ hk.src_expr }} AS {{ hk.tgt }}`. This makes every
     alias-local hub-key column (e.g. `t4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`) available on
     that alias, exactly as the central view's `tN` CTE produced it.
  2. **`final` CTE**: after the payload-column COALESCE block and before `record_source`,
     the macro emits one column per `hub_keys` entry:
     `{{ hk.expr }} AS {{ hk.name }}`. Because `hk.expr` references `alias.tgt` and those
     aliases are LEFT JOINed to `affected_keys` on `unique_key`, the expression resolves
     against the same row set the payload COALESCEs see.
  3. **Terminal `SELECT`**: the final projection lists `unique_key`, then each
     `output_columns` entry, then **each `hub_keys[].name`**, then `record_source` and
     `inc_job_updated_at`.
- **Grain note**: the macro's grain remains one row per `unique_key` (the satellite's hub
  grain), scoped by `affected_keys` and the single QUALIFY row-pick — it is **not** the
  central view's N-way FULL OUTER spine. The hub-key expressions are evaluated on the
  LEFT-JOINed alias row chosen by the QUALIFY, so a given hub key is populated only when
  the contributing alias survives the row-pick for that `parent_bk`. This is an
  intentional, documented deviation from the central view's FULL OUTER spine (see
  Stitched Reshape Approach → grain deviation).

### Component: Source declarations (`models/staging/_health__sources.yml`)

- **Responsibility**: declare the three source runs and their raw tables so `source()`
  calls in the staging models resolve.
- **Interface**: `source('<run>', '<RAW_TABLE>')` — the `(run, table)` pairs must exactly
  cover what the staging models request; `database`/`schema` come from the vars.

### Component: Reshaped stitched models (`models/stitched/stitch_NN_*.sql`)

- **Responsibility**: merge attributes from the contributing staging sources at one hub
  grain, reproduce the central view's hub business keys, and feed **exactly one
  satellite**, via the extended macro. A central view that feeds several satellites is
  expressed as several such models (see "One stitch per satellite").
- **Interface (produced for downstream)**: a `view` whose columns are `parent_bk`, the
  `output_columns`, **the hub-key columns (families 1 and 2)**, `record_source`, and
  `inc_job_updated_at`. Under Option C the hub-key columns are **preserved**, so the
  stitch output still carries every `HUB_*_BK` / `TN__HUB_*_BK__*` column the downstream
  `stage/` hash site reads. Interface differences from the pre-reshape central view: the
  `record_source` value (recorded follow-up), and, for multi-satellite views, each
  per-satellite stitch exposes only **its own** satellite's payload columns, so a single
  `ref()` no longer carries every satellite's payload (see Risks, downstream consequence).

### Component boundary (unchanged): Downstream layers

- `stage/`, `hub_feeds/`, `vault/{hubs,links,satellites}` are not modified. The reshaped
  stitches preserve the hub-key columns they consume, but `stage_NN_*` models read ONE
  `ref('stitch_NN_...')` and compute every satellite hashdiff from it. After the
  per-satellite split, that single ref no longer carries the other satellites' payload, so
  `stage_NN_*` for multi-satellite views will fail to compile until it is pointed at the
  per-satellite stitches. This is a known, recorded follow-up, not fixed in this scope.

## Data Models

The data flowing through the reshaped layer, and the declarative shapes the design
authors.

### Declarative inputs authored per reshaped stitched model (Jinja)

```
sources: list of
  {
    model:           str   # dbt ref name, e.g. 'stg_hcp_pol_mst'
    alias:           str   # 't0', 't1', ...
    key_column:      str   # grain key at the satellite's hub grain
    ldts_column:     str   # load timestamp, 'inc_job_updated_at'
    columns:         list of { src: str, tgt: str }   # raw col -> canonical payload attr
    hub_key_columns: list of { src_expr: str, tgt: str }  # NEW — raw SQL hub-key expr -> alias-local hub-key col
    source_tag:      str   # '<SYSTEM>_<TABLE>', e.g. 'OPUS_HEALTH_DELTA3_BJAZ_POLICY_BASES_EXTN'
  }
output_columns: list[str]                 # lower-cased satellite payload attrs
coalesce_rules: dict[str, list[str]]       # attr -> [alias, ...] in precedence order
hub_keys:       list of { name: str, expr: str }   # NEW — hub-key output col -> raw SQL expr over alias.tgt
target_sat:     str                        # 'sat_<name>'
unique_key:     str                        # 'parent_bk'
```

`hub_key_columns[].src_expr` is the raw expression from the source's `tN` CTE in the
central view (bare `nullif(trim(...))`, a prefix-literal expr like
`nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')`, or an
`md5(normalise(upper(...)))` address hash); `tgt` is the alias-local hub-key column name
(`HUB_POLICY_BK__CONTRACT_ID`, `HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`, ...).

`hub_keys[].expr` is the raw expression from the central view's final `SELECT`, either a
`COALESCE(...)` over `alias.tgt` references (family 1, the merged spine BKs) or a single
`alias.tgt` (family 2, the auxiliary per-source BKs); `name` is the exact output column
the central view aliased it to (`HUB_POLICY_BK`, `T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE`).

### Stitched view output row (produced by the extended macro)

```
parent_bk:            <grain key>          # the merged hub business key (unique_key)
<output_columns...>:  varchar (NULLIF/TRIM'd)  # one column per output attribute
<hub_keys[].name...>: varchar              # one column per hub key (families 1 and 2)
record_source:        varchar              # comma-joined contributing source_tag(s)
inc_job_updated_at:   timestamp_ntz         # GREATEST_IGNORE_NULLS of source ldts
```

The hub-key columns sit between the payload attributes and `record_source`, preserving the
set of `HUB_*_BK` / `TN__HUB_*_BK__*` columns the downstream stage hash site reads.

### Source declaration row (YAML)

```
source.name:        str   # run: opus_health_legacy_v4 | opus_health_v2 | opus_health_delta3
source.database:    str   # var('health_raw_database', 'RAW')
source.schema:      str   # var('health_raw_schema', 'GG_DWHSTAGE')
source.tables[].name: str # RAW upstream table name
```

### Config values (recorded, Req 4.5)

```
project:  opus_health_dv_dbt
profile:  opus_health_dbt
vars:     health_raw_database, health_raw_schema   # from Health build inputs
```

## Scaffolding Approach

Two operations: **copy verbatim** (files/dirs that carry no project-specific value) and
**adapt** (files that name the project/profile/vars).

### Copy verbatim

- `dbt_packages/` — copy the whole vendored tree from partner (`dbt_utils`, `automate_dv`).
- `macros/` — copy all eight partner macros listed above (including
  `stitch_incremental.sql` unchanged) plus `.gitkeep`. These are project-agnostic (the
  stitch macro resolves relations via `this.database`/`this.schema` at run time), so no
  edits are needed. **Then add one new macro**, `stitch_incremental_hcon.sql` — a copy of
  `stitch_incremental` extended with the `hub_keys` parameter and the per-source
  `hub_key_columns` threading described under Components. The original
  `stitch_incremental.sql` is left byte-unchanged; the health reshape calls the extended
  macro.
- `analyses/`, `seeds/`, `snapshots/`, `tests/`, `docs/` — create empty (carry a
  `.gitkeep` if the partner's do).

### Adapt — `dbt_project.yml`

Start from the partner file and change exactly these values:

| Key | Partner value | Health value |
|---|---|---|
| `name` | `opus_partner_dv_dbt` | `opus_health_dv_dbt` |
| `profile` | `opus_partner_dbt` | `opus_health_dbt` |
| `vars.partner_raw_database` | `BAGIC_PROD_MIRROR_DB` | rename to `health_raw_database`, value from Health build inputs |
| `vars.partner_raw_schema` | `OPUS_GG_DWHSTAGE` | rename to `health_raw_schema`, value from Health build inputs |

`model-paths`, `analysis-paths`, `test-paths`, `seed-paths`, `macro-paths`,
`snapshot-paths`, `target-path`, and `clean-targets` are copied unchanged.

The `models:` map is rebuilt against the Health_Project's directory names while preserving
the partner's canonical form (pre/post-hook run-log pair may be retained under the project
key, or dropped if it references a partner-only log table — see Risks). Canonical map:

```yaml
models:
  opus_health_dv_dbt:
    staging:
      +materialized: view
      +tags: ["stg1"]
    stitched:
      +materialized: view
      +tags: ["stitch"]
    stage:
      +materialized: view
      +tags: ["stage"]
    hub_feeds:
      +materialized: view
      +tags: ["hub_feed"]
    vault:
      hubs:
        +materialized: incremental
        +tags: ["hub"]
        +on_schema_change: append_new_columns
      links:
        +materialized: incremental
        +tags: ["lnk"]
        +on_schema_change: append_new_columns
      satellites:
        +materialized: incremental
        +tags: ["sat"]
        +on_schema_change: append_new_columns
    augmented:
      +materialized: view
      +tags: ["aug"]
    assertions:
      +materialized: view
      +tags: ["assertion"]
```

Materializations are inferred from how the Health_Project's own models are written
(stitched/stage/hub_feeds are `view`; hubs/links/satellites are incremental loaders).
Any uncertainty on a downstream layer's intended materialization is a follow-up finding,
not a guess baked into a load-bearing layer.

### Adapt — `packages.yml`

Identical to partner (both packages are vendored locally under `dbt_packages/`):

```yaml
packages:
  - local: dbt_packages/dbt_utils
  - local: dbt_packages/automate_dv
```

### Adapt — `profiles.yml`

Copy the partner profile and rename the top-level key to `opus_health_dbt`. Keep both
`dev` and `prod` Snowflake outputs. Per Requirement 1.7, keep `account: "_"` and
`user: "_"` placeholders in `dev` (overwritten by the Snowflake CLI connection at deploy
time). `role`, `warehouse`, `database`, `schema`, and `threads` are carried from the
partner unless the Health build inputs specify different Snowflake targets (if they do,
those values are used and recorded under Requirement 4.5).

```yaml
opus_health_dbt:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "_"   # overwritten by Snowflake CLI connection at deploy time
      user: "_"      # overwritten by Snowflake CLI connection at deploy time
      role: INGESTION_PREPROD_ROLE
      warehouse: BAGIC_DPM_MAXI_RAW_WH
      database: BAGIC_PREPROD_CURATED_DB
      schema: BGIL_DATA_MODEL
      threads: 7
    prod:
      type: snowflake
      role: EMPOWER_FOUNDATION_ROLE
      warehouse: BAGIC_DPM_MAXI_RAW_WH
      database: BAGIC_PREPROD_CURATED_DB
      schema: BGIL_DATA_MODEL
      account: 'not needed'
      user: 'not needed'
      threads: 4
```

## Source Definition Strategy

The reshaped stitched models (and the existing staging models) must resolve dbt `source()`
calls. The staging models already reference three distinct source runs, so one sources
file covers them all.

`models/staging/_health__sources.yml` declares one `source` per run, each with the real
upstream table names, database/schema driven by vars with a safe default:

```yaml
version: 2
sources:
  - name: opus_health_legacy_v4
    database: "{{ var('health_raw_database', 'RAW') }}"
    schema: "{{ var('health_raw_schema', 'GG_DWHSTAGE') }}"
    tables:
      - name: BA_CCP_SUB_MATER_DTLS
      - name: BJAZ_CARD_DTLS
      # ... every RAW table read by a stg_*.sql whose "source run" is legacy_v4
  - name: opus_health_v2
    database: "{{ var('health_raw_database', 'RAW') }}"
    schema: "{{ var('health_raw_schema', 'GG_DWHSTAGE') }}"
    tables:
      - name: BJAZ_CTNGY_GC_CONTROL
      # ... every RAW table whose "source run" is v2
  - name: opus_health_delta3
    database: "{{ var('health_raw_database', 'RAW') }}"
    schema: "{{ var('health_raw_schema', 'GG_DWHSTAGE') }}"
    tables:
      - name: BJAZ_POLICY_BASES_EXTN
      # ... every RAW table whose "source run" is delta3
```

The authoritative `(run, RAW_TABLE)` pairs are harvested directly from the staging models:
each `stg_*.sql` names its run in the generated header comment (`source run : <run>`) and
its table in the `from {{ source('<run>', '<RAW>') }}` line. The build generates the table
list by scanning those `source(...)` calls, so the sources file matches what dbt will
actually request — no table is invented and none is dropped. Database/schema are a single
pair of vars because all three runs land in the same raw location in the confirmed
staging models; if the Health build inputs show a per-run split, the design adds per-run
`health_raw_*` vars instead. One source run per table holds in this map
(`table_overlap_between_runs: 0` in `build_profile.json`), so there is no ambiguity about
which run owns a table.

## Stitched Reshape Approach

### From central view to partner form

A Health_Central_View (e.g. `stitch_01_policy__policy_header.sql`) is a set of `tN` CTEs,
one per contributing staging model, each selecting that source's attributes plus inline
hub business-key expressions (`... as HUB_POLICY_BK__CONTRACT_ID`), de-duplicated by a
`qualify row_number()`, then FULL OUTER joined into one wide view whose final `SELECT`
emits the three column families (merged spine BKs, auxiliary per-source BKs, satellite
payload). The reshape replaces that machinery with declarative inputs consumed by
`stitch_incremental_hcon`, carrying all three families through the macro.

Mapping, per reshaped model:

| Central-view element | Partner-form target |
|---|---|
| each `tN` CTE's `from {{ ref('stg_x') }}` | a `sources[]` entry with `model: 'stg_x'`, `alias: 'tN'` |
| the single business key the satellite joins on | `key_column` (the stitch grain / `unique_key` column) |
| the source's load-timestamp column | `ldts_column` (partner uses `inc_job_updated_at`) |
| each payload attribute carried by that source (family 3) | a `columns[]` entry `{src: <raw col>, tgt: <canonical attr>}` |
| the payload attribute precedence (family 3 COALESCE merge order) | `coalesce_rules[tgt] = ['tN', ...]` in precedence order |
| the set of payload output attribute names | `output_columns = [...]` |
| each hub-key source expression inside a `tN` CTE | a `hub_key_columns[]` entry `{src_expr: <raw SQL>, tgt: <alias-local hub col>}` on that source |
| each merged spine BK / auxiliary per-source BK in the final SELECT (families 1 and 2) | a `hub_keys[]` entry `{name: <output BK col>, expr: <raw SQL over alias.tgt>}` |
| the satellite the view feeds | `target_sat = 'sat_<name>'` |
| the source identity string | `source_tag` (see record-source decision) |

The reshaped body is:

```sql
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_ba_ccp_sub_mater_dtls',
        'alias': 't0',
        'key_column': 'HUB_POLICY_BK__CONTRACT_ID',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'customer_comm', 'tgt': 'customer_communication_text'},
            {'src': 'remarks',       'tgt': 'policy_remarks'},
            -- ... remaining family-3 payload columns this source carries
        ],
        'hub_key_columns': [
            {'src_expr': "nullif(trim(CONTRACT_ID),'')", 'tgt': 'HUB_POLICY_BK__CONTRACT_ID'},
            {'src_expr': "nullif('LOANACC:' || nullif(trim(LOAN_ACC_NUMBER),''), 'LOANACC:')",
             'tgt': 'HUB_RISK_OBJECT_BK__LOANACC_LOAN_ACC_NUMBER'},
        ],
        'source_tag': 'OPUS_HEALTH_LEGACY_V4_BA_CCP_SUB_MATER_DTLS',
    },
    -- ... one entry per contributing tN source
] -%}

{%- set output_columns = [ 'policy_status', 'risk_inception_date', ... ] -%}

{%- set coalesce_rules = {
    'policy_status': ['t1', 't10', 't12', 't35'],
    -- ... family-3 precedence per payload attribute
} %}

{%- set hub_keys = [
    -- family 1: merged spine BKs (COALESCE over contributing aliases)
    {'name': 'HUB_POLICY_BK',
     'expr': 'coalesce(t0.HUB_POLICY_BK__CONTRACT_ID, t1.HUB_POLICY_BK__CONTRACT_ID, ... )'},
    {'name': 'HUB_PARTY_BK',
     'expr': 'coalesce(t1.HUB_PARTY_BK__USER_ID, t8.HUB_PARTY_BK__EMP_CODE, ... )'},
    -- family 2: auxiliary per-source BKs (single alias.tgt)
    {'name': 'T4__HUB_PARTY_BK__PD_BAGIC_RM_E_CODE',
     'expr': 't4.HUB_PARTY_BK__PD_BAGIC_RM_E_CODE'},
    -- ... every family-1 and family-2 column from the central view's final SELECT
] -%}

{{ stitch_incremental_hcon(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    hub_keys=hub_keys,
    unique_key='parent_bk',
    target_sat='sat_policy_header'
) }}
```

The `src_expr` and `hub_keys[].expr` strings are transcribed **verbatim** from the central
view (preserving prefix literals, `md5(normalise(upper(...)))` hashing, and COALESCE order)
so the reshaped hub keys are byte-equivalent to the ones the downstream layers already
hash.

### One stitch per satellite (authoritative; supersedes the first reshape pass)

The Partner_Project uses one thin stitch per target satellite
(`opus_partner_dv_dbt/models/raw_vault/standard/stitched`, e.g.
`stitch_common_classification` feeds `sat_common_classification`). The Health_Project
follows the same rule.

**Discovery.** Many health central views (`stitch_NN`) feed several satellites: the
matching `stage_NN_*` model hashes several `SAT_*_HASHDIFF` values from the one view. The
first reshape pass carried only the satellite named in the filename and dropped the other
satellites' payload. That is wrong and is replaced by the following.

**Rule.** For every central view, emit one reshaped stitch model per satellite it feeds.
Each per-satellite stitch has:

- its own `target_sat`;
- its own `output_columns` = that satellite's hashdiff payload list taken from `stage_NN_*`;
- its own `coalesce_rules`, restricted to that satellite's payload;
- only the `sources` that either contribute that satellite's payload columns or are needed
  to resolve the `hub_keys` for its grain (a source with no payload for this satellite is
  kept only if a `hub_keys` expression or its `key_column` depends on it).

**Naming convention.**

- The existing filename is kept for the satellite it is named for
  (`stitch_01_policy__policy_header.sql` stays, feeding `sat_policy_header`).
- Each additional satellite gets `stitch_NN_<spine>__<sat_tail>.sql`, where `<spine>` is the
  spine segment of the existing filename and `<sat_tail>` is the satellite name without the
  `sat_` prefix (e.g. an extra satellite `SAT_POLICY_CONTACT` fed by stitch 01 becomes
  `stitch_01_policy__policy_contact.sql`).
- If a satellite's tail already matches the existing filename's tail, no extra file is
  created for it.

**`hub_keys` handling: full set per stitch (chosen).** Each per-satellite stitch carries
the **full** `hub_keys` set (families 1 and 2) from the original central view, not a
per-grain subset. Reasons: it is the simplest mechanical rule; it keeps the hub-key
fidelity check identical for every file (names and expressions diffed against the same
central view); and the stage hash site reads whichever `HUB_*_BK` columns it needs without
a per-satellite audit. The cost is that `hub_keys` expressions may reference aliases that
are not otherwise needed for payload, so those sources are retained in `sources` (with
`hub_key_columns` and no `columns`). Where an alias referenced by an expression is not
present in the trimmed source set, the source is added back rather than the expression
edited, so expressions stay verbatim.

**stitch_35 is left UNRESHAPED (open follow-up).** The central view for
`stitch_35` names `SAT_CASE_EXTERNAL_REF`, which does not exist in the project, while
`stage_35_claim` hashes six other satellites. The correct satellite set and file names are
undecided, so `stitch_35` stays in its original central-view form and is recorded as an
open follow-up.

**Status of the 46 original files.**

| Files | Status |
|---|---|
| `stitch_00`, `01`-`09`, `11`-`19`, `30`-`34`, `36`-`39`, `40`-`42`, `44`, `45` | Reshaped in the first pass for the filename satellite only. Must be revisited to add the missing per-satellite stitches (and to verify the existing file's `output_columns` is restricted to its own satellite). |
| `stitch_20`-`29` | Not yet reshaped. Reshape directly in the per-satellite form. |
| `stitch_10`, `stitch_43` | Link-feeding; not reshapable with the satellite macro (Risk 6). |
| `stitch_35` | Left unreshaped (open follow-up above). |

### Deriving `target_sat`

Each central view declares the satellite(s) it feeds in its generated header
(`satellites : SAT_POLICY_HEADER` for stitch 01) and the stage hash site names the same
satellites (`SAT_POLICY_HEADER_HASHDIFF` in `stage_01_policy.sql`). Each per-satellite
stitch's `target_sat` is the lower-cased name of the one satellite it feeds
(`sat_policy_header`). The design cross-checks the header, the stage hashdiff names, and
the filename tail; the set of per-satellite stitches for a view is the set of satellites
the stage model hashes. Any disagreement (as in stitch 35) is a follow-up finding.

### Deriving `output_columns` and `coalesce_rules`

`output_columns` is the **one** satellite's payload attribute set: the columns the stage
hashdiff lists for that satellite (e.g. `stage_01_policy.sql` enumerates
`RISK_INCEPTION_DATE, RISK_EXPIRY_DATE, POLICY_STATUS, ...` inside
`SAT_POLICY_HEADER_HASHDIFF`), lower-cased to match the partner form. `coalesce_rules`
encodes the central view's documented R8 source precedence (its "merge order" header note:
`v2 > legacy > delta3`): for each output column, list the source aliases that carry it in
precedence order. Where only one source carries a column, the rule is a single-element
list (the macro emits a bare column reference, not a COALESCE), matching partner behavior.

### `key_column`, grain, and the preserved inline hub keys

The macro merges at a **single** hub grain (`unique_key='parent_bk'`, one `key_column` per
source). The Health_Central_View, by contrast, derives **many** hub BKs inline (stitch 01
lists ~24 merged spine BKs plus ~60 auxiliary per-source BKs) and feeds a satellite that
the downstream stage layer hashes against all of them. Under Option C those inline
`HUB_*_BK` derivations are **preserved**, not dropped: each source's hub-key source
expressions move into its `hub_key_columns[]` list (reproduced inside the macro's per-source
CTE), and each family-1/family-2 output column moves into `hub_keys[]` (evaluated in the
macro's final `SELECT`). The stage layer's `HUB_*_BK` references therefore keep resolving.

**Grain deviation (documented).** The central view joins its sources with an N-way FULL
OUTER spine, so a row can exist for a key present on only one side and every alias's
hub-key column is visible on that row. The macro instead builds `affected_keys` (a UNION
of each source's `key_column` within the watermark window), LEFT JOINs each alias on
`unique_key`, and picks one row per `parent_bk` via `QUALIFY ROW_NUMBER() = 1`. The hub-key
expressions are evaluated on that single picked row. Consequences:

- A hub key sourced from an alias that did not survive the row-pick for a given
  `parent_bk` will be NULL on that row, whereas the FULL OUTER spine might have surfaced
  it on a sibling row. For the satellite grain (one row per `parent_bk`) this matches the
  stage layer's expectation of one hub-key set per key, but it is **not** a row-for-row
  reproduction of the central view's spine.
- The `hub_keys[].expr` COALESCE order is preserved verbatim, so where multiple aliases
  are present on the picked row the merged BK value is identical to the central view's.

Two further grain deviations are recorded: (a) sources with no spine-hub key keep their
real join key as `key_column` (via a `hub_key_columns` entry for that key), so their rows
join at a different grain than the spine; (b) the macro emits one column per alias per
target, so when two payload attributes map to the same `tgt` on one alias only one survives
(see Risks).

This deviation is recorded (it is the shape the macro supports), and the per-file
hub-key fidelity check (Testing Strategy) verifies the reshaped `hub_keys` names and
expressions match the central view's final-SELECT hub-BK columns exactly.

### Record-source decision (`source_tag`)

Two conventions collide and the design must honor both constraints without inventing a
third:

- The `stitch_incremental` macro **requires** `source_tag = '<SYSTEM>_<TABLE>'` and
  derives the watermark group from the text before the first `_`. It also emits that tag
  as the `record_source` column value.
- The Health_Project's existing downstream **uses the stitch model-name literal** as
  `RECORD_SOURCE` (confirmed: `'stitch_31_policy__account_balance'`), and uses **no**
  `OPUS_HEALTH_*` literal anywhere.

Resolution: `source_tag` is set from the **health source run** that owns each contributing
staging model, in the macro's required `<SYSTEM>_<TABLE>` shape, using the run as the
system segment — e.g. a source read from `opus_health_legacy_v4` becomes
`OPUS_HEALTH_LEGACY_V4_<RAWTABLE>`, `opus_health_v2` becomes `OPUS_HEALTH_V2_<RAWTABLE>`,
`opus_health_delta3` becomes `OPUS_HEALTH_DELTA3_<RAWTABLE>`. The run → system segment
mapping is read from each staging model's `source run :` header and its `source()` call,
so the tag is grounded in the existing project, not assumed.

Important consequence to record: the macro splits on the **first** `_`, so all three runs
collapse to the single system group `OPUS`. That satisfies the macro's single-system
assertion (every source shares prefix `OPUS`), but it means two things the design flags
rather than hides:

1. The macro's emitted `record_source` will be the `source_tag`(s), **not** the stitch
   model-name literal the Health downstream expects. The reshaped stitched layer's
   `record_source` therefore differs from the pre-reshape convention — a follow-up finding
   (Requirement 4.3), not something patched into the downstream layers. This divergence is
   **independent of the hub-key fix**: preserving the hub keys does not change the
   `record_source` value the macro emits.
2. A stitch cannot mix the macro's notion of systems; since all health runs share `OPUS`,
   a single stitch may legitimately combine legacy/v2/delta3 sources without tripping the
   mixed-prefix error. This is confirmed safe against the macro contract.

The design does **not** choose to rewrite the macro or the downstream satellites to
reconcile the two record-source conventions — that reconciliation is explicitly out of
scope and is surfaced as a follow-up.

## Handling 46 Files Consistently

The 46 central views share one shape, so the reshape is a single repeatable procedure
applied view-by-view, in numeric order (`stitch_00` → `stitch_45`), producing one stitch
file per satellite fed (so more than 46 output files). `stitch_35` is skipped (open
follow-up). The procedure runs once per (view, satellite) pair:

1. Read the central view's header block to capture: spine hub, contributing `stg_*`
   models, the satellites fed, and the documented merge order (precedence).
2. Read the matching `stage_NN_*` model to capture every satellite it hashes. For the
   satellite being emitted, take its hashdiff column list → `output_columns` and its name →
   `target_sat`. Name the file per the naming convention.
3. For each `tN` CTE that contributes this satellite's payload or is needed by `hub_keys`,
   record `model` (the `ref`), `alias`, the grain `key_column` (an alias equal to a
   `hub_key_columns[].tgt` on the same source), the
   `ldts_column`, the `{src,tgt}` payload column pairs it contributes (family 3), and the
   `{src_expr,tgt}` hub-key source expressions it computes inline → `hub_key_columns[]`.
4. Build `coalesce_rules` from the payload pairs and the documented precedence.
5. From the central view's final `SELECT`, transcribe every family-1 (merged spine BK) and
   family-2 (auxiliary per-source BK) column verbatim into `hub_keys[]` as `{name, expr}`.
6. Derive each `source_tag` from the staging model's source run (record-source decision).
7. Emit the thin partner-form model (config + four Jinja vars + one macro call to
   `stitch_incremental_hcon`).
8. Validate consistency per file: every `output_columns` entry appears in at least one
   `coalesce_rules` value; every alias used in `coalesce_rules` exists in `sources`; every
   `alias.tgt` referenced by a `hub_keys[].expr` is declared as a `hub_key_columns[].tgt`
   on that alias's source; every source has a non-empty `<SYSTEM>_<TABLE>` tag;
   `target_sat` matches the stage/header.
9. **Hub-key fidelity check**: the set of `hub_keys[].name` equals the set of family-1 +
   family-2 column names in the central view's final `SELECT`, and each `hub_keys[].expr`
   matches the central view's expression for that column verbatim (prefix literals, hash
   expressions, and COALESCE order all identical).

To keep 46 files uniform, the design fixes these invariants across all of them:
`unique_key='parent_bk'`, `ldts_column='inc_job_updated_at'` (partner convention; if a
Health source lacks that column the per-file step records it), lower-cased
`output_columns`/`target_sat`, and alias names `t0..tN` preserved from the central view so
diffs stay legible. Models whose central view feeds a **link** rather than a satellite
(the filenames carrying `lnk_`, e.g. `stitch_10_..._lnk_role_nominee_beneficiary`,
`stitch_43_..._lnk_party_role_core`) do not fit the satellite-merge macro shape; these are
flagged per-file as not mechanically reshapable and handled as follow-up findings rather
than forced into `target_sat`.

The reshape edits the `.sql` files directly; `generators/` is never touched (Requirement
3.6).

## Error Handling

- **Macro contract violations** (missing/malformed `source_tag`, mixed system prefixes)
  surface at `dbt parse`/`compile` time as compiler errors raised by `stitch_incremental`.
  The per-file validation step (above) catches these before compile so each reshaped file
  is self-consistent.
- **Missing source attribute**: if a central view carries a payload column no staging
  model actually exposes, the per-file step records it rather than emitting a column that
  would fail to compile.
- **Hub-key transcription error**: because `hub_key_columns[].src_expr` and
  `hub_keys[].expr` are hand-transcribed from the central view, a mistranscription would
  change a BK value or break a reference. The per-file hub-key fidelity check (step 9
  above) catches a name/expr divergence before compile; an unresolved `alias.tgt`
  reference surfaces at compile as a column-not-found error from `stitch_incremental_hcon`.
- **Downstream compile (will NOT succeed for multi-satellite views)**: the reshaped
  stitches preserve the `HUB_*_BK` columns, but each stitch now carries only one
  satellite's payload. `stage_NN_*` reads a single `ref('stitch_NN_...')` and computes all
  satellite hashdiffs from it, so for views feeding more than one satellite the stage model
  will fail with column-not-found until it is pointed at the per-satellite stitches.
  Single-satellite views are expected to compile. Downstream layers are out of scope, so
  this is recorded, not fixed.
- **Not yet executed**: `dbt parse` and `dbt compile` have not been run because dbt is not
  installed in the authoring environment. The user will run them; all compile expectations
  in this document are unverified until then.
- **Source resolution failure**: handled by `_health__sources.yml` covering every
  `(run, RAW_TABLE)` pair the staging models request; the vars carry safe defaults so
  `dbt parse` resolves even before Snowflake targets are set.

## Testing Strategy

This feature adapts fixed configuration files and reshapes a fixed, enumerable set of 46
dbt models by hand against a known template. There is no varying input space to sample and
no pure function to exercise, so verification is **example / inspection / compile-based**,
not property-based (see Correctness Properties below for why no PBT applies).

Verification steps, mapped to requirements:

- **`dbt parse`** (Req 1, 2, 2.5): the project parses end-to-end — the profile
  `opus_health_dbt` resolves, the two local packages resolve from the vendored
  `dbt_packages/` tree, the eight macros are discoverable, and every `(run, RAW_TABLE)`
  the staging models request is declared in `_health__sources.yml`.
- **Static inspection of config identity** (Req 1.1–1.4, 1.7, 4.5): confirm `name`,
  `profile`, `vars`, the `models:` map, and the `dev` `account: "_"` / `user: "_"`
  placeholders carry the confirmed Health values.
- **Per-file reshape inspection** (Req 3.1–3.6): each reshaped model is
  `config(materialized='view')`, declares `sources` / `output_columns` / `coalesce_rules` /
  `hub_keys`, calls `stitch_incremental_hcon(..., target_sat=...)`, sets each `source_tag`
  from the confirmed health run, and leaves `generators/` unchanged. Plus the per-file
  invariant checks listed under "Handling 46 Files Consistently".
- **Per-file hub-key fidelity check** (Req 4.2): for each reshaped model, the set of
  `hub_keys[].name` and each `hub_keys[].expr` is diffed against the central view's
  family-1 + family-2 hub-BK columns; they must match verbatim (names, prefix literals,
  hash expressions, and COALESCE order). This is the primary guard on the hand
  transcription that Option C relies on.
- **`dbt compile` of the stitched layer** (Req 3): each reshaped stitch compiles against
  the staging sources and the extended macro (self-consistent `sources` /
  `coalesce_rules` / `output_columns` / `hub_keys`).
- **`dbt compile` end-to-end (known to fail for multi-satellite views until follow-up)**
  (Req 4.3): the hub keys are preserved, but `stage_NN_*` for multi-satellite views will
  not compile until it is repointed at the per-satellite stitches. The verification target
  for this feature is the stitched layer plus single-satellite downstream chains; the
  multi-satellite stage failures are expected and listed as the follow-up.
- **Per-satellite split check**: for each view, the set of emitted stitch files' `target_sat`
  values equals the set of `SAT_*_HASHDIFF` satellites in `stage_NN_*`, and each file's
  `output_columns` equals that satellite's hashdiff list.
- **Scope-boundary check** (Req 4.1, 4.4): downstream `stage/`, `hub_feeds/`, `vault/`
  files and `generators/` are byte-unchanged; the record-source divergence and the
  generator-overwrite risk (now also covering the new macro) are recorded as follow-up
  findings rather than patched.

Edge cases the per-file procedure must cover: a source whose load-timestamp column is not
`inc_job_updated_at`; an `output_columns` entry no source carries; a hub-key expression
referencing an alias whose `hub_key_columns` entry is missing; a `lnk_`-feeding stitch
that does not fit the satellite-merge macro; a column carried by multiple sources (COALESCE
precedence) versus one source (bare reference).

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid
executions of a system — essentially, a formal statement about what the system should do.
Properties serve as the bridge between human-readable specifications and machine-verifiable
correctness guarantees.*

This feature is a project-scaffolding and model-reshape task — adapting configuration
files and rewriting declarative dbt models by hand against fixed templates. The acceptance
criteria assert the presence and shape of specific files and config values (verified by
parse/compile and by inspection), and record scope-boundary facts. They are not universal
"for all inputs X, P(X)" statements over a varying input space, and the reshape is applied
to a fixed, enumerable set of 46 files rather than generated inputs. Per the workflow's own
guidance (scaffolding/config and one-shot structural edits are not PBT-appropriate; use
example/inspection and compile checks), there are **no property-based tests** for this
feature. All verification is example/inspection/compile-based and is described in the
Testing Strategy section above.

## Risks and Follow-ups

1. **Dropped inline hub-key derivation — RESOLVED / CLOSED** (Req 4.2). An earlier design
   reshaped onto the partner `stitch_incremental` macro, which has no slot for the central
   view's inline `HUB_*_BK` columns, so the reshape dropped them. Option C **closes this
   gap**: the extended `stitch_incremental_hcon` macro carries the hub-key source
   expressions through its per-source CTEs (`hub_key_columns`) and emits every merged and
   auxiliary hub BK in its final `SELECT` (`hub_keys`). The reshaped stitch now emits the
   same `HUB_*_BK` / `TN__HUB_*_BK__*` columns the central view did. **No follow-up
   needed** beyond the fidelity check below.

2. **Record-source convention divergence** (Req 4.3) — still open, independent of the
   hub-key fix. The macro emits `record_source` from the per-source `source_tag`
   (`OPUS_HEALTH_<RUN>_<TABLE>`), while the existing Health downstream satellites write the
   stitch model-name literal (`'stitch_NN_...'`). After reshape the two disagree.
   Preserving the hub keys does **not** change this — `record_source` and the hub-key
   columns are separate parts of the stitch output. This does not break downstream
   *compilation* (the sat loaders set their own `RECORD_SOURCE` literal), but it is a
   semantic divergence in what the stitch's own `record_source` column carries.
   **Follow-up**: reconcile the record-source contract (adjust downstream or the macro) —
   explicitly out of scope; surfaced, not patched.

3. **Downstream compile mismatch from the per-satellite split — OPEN** (Req 4.3). This
   corrects the earlier claim that end-to-end compile is expected to succeed. `stage_NN_*`
   models read ONE `ref('stitch_NN_...')` and compute all satellite hashdiffs from it.
   With one stitch per satellite, that ref no longer carries the other satellites' columns,
   so for multi-satellite views `dbt compile` of `stage_NN_*` (and everything downstream of
   it) will fail until `stage_NN_*` is updated to read the per-satellite stitches.
   **Follow-up**: repoint/refactor the stage models (out of scope here; downstream layers
   stay unmodified).

3a. **stitch_35 unreshaped — OPEN**. `SAT_CASE_EXTERNAL_REF` does not exist in the project
   and `stage_35_claim` hashes six other satellites. Left in original form; decide the
   satellite set and emit per-satellite stitches later.

3b. **Same-alias payload drops — NEW RISK**. The macro emits one column per alias per
   target. If two payload attributes on one source map to the same `tgt` (or one source
   feeds a `tgt` twice), only one survives. **Mitigation**: the per-file check flags any
   duplicate `tgt` within a source; affected cases are recorded as findings.

3c. **Grain deviations — NEW RISK**. Sources with no spine-hub key keep their real join key
   as `key_column`, so they merge at a different grain than the spine, and the macro grain
   is not the central view's FULL OUTER spine. Hub keys may be NULL where the contributing
   alias is not picked. **Mitigation**: documented per file; reviewed in the hub-key
   fidelity check.

3d. **dbt not run — NEW RISK**. dbt is not installed in the authoring environment, so
   `dbt parse` and `dbt compile` have not been executed on any reshaped file or on the macro
   fix. The user will run them. Nothing in this design should be read as compile-verified.

4. **Hub-key transcription fidelity — NEW RISK** (Req 4.2). The `hub_key_columns[].src_expr`
   and `hub_keys[].expr` strings are **hand-transcribed** from each central view's `tN`
   CTEs and final `SELECT`. A transcription error (a wrong prefix literal, a dropped
   COALESCE term, a mistyped `md5(normalise(upper(...)))` hash, or a misspelled
   `alias.tgt`) would silently change a hub business key or fail to compile. **Mitigation**:
   the per-file hub-key fidelity check (Testing Strategy) diffs the reshaped `hub_keys`
   name set and each expression against the central view's hub-BK columns verbatim; this
   check is mandatory per file.

5. **Generator overwrite** (Req 4.4). The stitched models are machine-generated
   (`GENERATED by gen_hcon4_stitched.py -- models are generated, never hand-edited`).
   Re-running the hcon4 stitched generator would overwrite every hand reshape. The hand
   edits live only in the `.sql` files; there is no change in `generators/` to make the
   generator emit the new form. Additionally, the new `stitch_incremental_hcon.sql` macro
   is **not** emitted by `generators/` either — it is a hand-authored file outside the
   generator's output, so a regeneration would both revert the reshaped models and leave
   the new macro unreferenced.

6. **Link-named stitches 10 and 43 — premise CORRECTED.** `stitch_10_policy__lnk_role_nominee_beneficiary`
   and `stitch_43_policy__lnk_party_role_core` were earlier flagged as link-feeding and
   left as-is (Tasks 5.2, 9.2). Their headers show `links: (none)`: stitch_10 feeds
   `SAT_LNK_ROLE_NOMINEE_BENEFICIARY`; stitch_43 feeds `SAT_LNK_PARTY_ROLE_CORE` and
   `SAT_PARTY_CLAIM_HISTORY`. They are satellite-feeding and misnamed, so they are now
   reshaped one stitch per satellite in Tasks 12.2 and 12.5. They have no first pass, so
   they are reshaped from the git HEAD original. Only `stitch_35` stays excluded.

10. **Scope extension: health staging edited by hand for the load timestamp.** Every
   reshaped stitch uses `ldts_column='inc_job_updated_at'`, but the 109 health staging
   models (`models/staging/stg_*.sql`, generated by `gen_hcon4_staging.py`) do not select
   it (partner staging passes it through as `"INC_JOB_UPDATED_AT"::timestamp_ntz as
   inc_job_updated_at`). Decision (user): hand-edit each `stg_*.sql` to append
   `cast(inc_job_updated_at as timestamp_ntz) as inc_job_updated_at` as the last select
   item, matching the health staging style (unquoted lower-case names, `cast(x as ...)`).
   Consequences: (a) the staging files are now hand-edited, so re-running
   `gen_hcon4_staging.py` would overwrite the change; the generator itself is NOT edited;
   (b) the raw tables are **assumed but NOT confirmed** to have `INC_JOB_UPDATED_AT`; the
   user must verify this in Snowflake, otherwise runs fail on a missing column;
   (c) `_health__sources.yml` content is unchanged.

7. **`models:` materialization inference for untouched layers.** The `dbt_project.yml` map
   must name downstream layers to parse, and their materializations are inferred from the
   existing models. Any layer whose intended materialization is ambiguous is recorded; the
   inference is chosen to match the models as written, not to change their behavior.

8. **Pre/post-hook run-log.** The partner `dbt_project.yml` carries dev-only pre/post hooks
   that write to `BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_MODEL_RUN_LOG`. If that log
   table is partner-specific, carrying the hooks verbatim into Health could log under the
   wrong project or fail; the design either retains them (shared log) or omits them and
   records the choice. Confirm against the Health build inputs before enabling.

9. **Snowflake connection values.** `profiles.yml` carries partner role/warehouse/database
   unless the Health build inputs specify otherwise. If Health targets a different
   warehouse/database, those values are substituted and recorded under Req 4.5.
