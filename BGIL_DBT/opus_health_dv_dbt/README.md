# Health (consolidated) Data Vault — dbt project, v5

Data Vault 2.0 build for the consolidated Health line of business (the legacy v4, OPUS v2 and
delta 3 runs), on Snowflake, using [AutomateDV](https://automate-dv.readthedocs.io/)
(`Datavault-UK/automate_dv`). It follows [`partner_dv_dbt/`](../partner_dv_dbt/README.md) and
[`travel_dv_dbt/`](../travel_dv_dbt/README.md) exactly: the same directory layout, the same
macros and the same key conventions. It is written from scratch, with no code carried over from
earlier health builds.

**Status: not yet `dbt deps`'d or run against Snowflake.** Every model is generated and verified
statically. Model counts, coverage, verification outcomes and the tree digest are in
`build_artifacts/BUILD_STATUS.json`; no document here states them.

## Why v5 exists

The earlier consolidated health builds (`opus_health_v2_dv_dbt` onwards) dropped AutomateDV and
hand-wrote every hub, link, satellite and hash. They also lost the macros' incremental loading
in the process: those models were declared incremental but had no incremental logic. v5 puts the
vault back on the macros and in the reference layout, while keeping the governing central-view
rule.

## Source documents

These are exactly the inputs the previous health build used. Each is read in place from the
mapper's bundle (read-only), and its md5 is asserted first (`build_profile.json → inputs_pinned`):

- `SourceMapping_Skill/Health Consolidated/outputs/04_column_map.json` — the legacy v4 + OPUS v2
  map
- `SourceMapping_Skill/OPUS Health Delta 3/outputs/04_column_map.json` (+ its `00_tables_index`
  and `08_handoff_facts`) — the delta 3 map
- `data_7.js` — the canonical model. Satellite grain, child keys and attributes are read from
  here, never from the map.
- `health_dv_dbt/` — read-only. The legacy half carries no resolved key in the map; its
  business-key expressions exist only in this project's emitted AutomateDV stages and stitched
  views, and are read from there. Only the expressions are reused, never the hashes.

## Architecture

Same layers as Partner and Travel:

```
Snowflake RAW.HEALTH (source tables)
        │
models/staging/health/stg_health__*.sql   -- 1:1 casts, one view per source table a central view reads
        ▼
models/automate_dv/standard/
  stitched/stitch_v<NN>_*.sql             -- THE CENTRAL VIEWS (the governing rule, below). Plain SQL,
        │                                    no hashing.
  staging/stg2_v<NN>_*.sql                -- automate_dv.stage() per central view: every hub key and
        │                                    link key on that view
  staging/stg2_<satellite>.sql            -- automate_dv.stage() per satellite: its pk, payload,
        │                                    child keys and HASHDIFF, read off ITS central view
        ▼
  hubs/*.sql · links/*.sql · satellites/*.sql
                                          -- hub() / link() / sat() / ma_sat() calls
models/automate_dv/augmented/{staging,satellites}
                                          -- the augmentation track (SAT_AUG_*), same mechanics,
                                             read off the same central views
```

### The central views (the governing rule)

> we create a central view from source tables (by joining them, max upto 10). The join are
> selected so that it can feed sat as a whole … we do not split sat across these views.
> Restriction of 10 can be broken if a sat needs more than source tables to build. If a view has
> less source tables join, we add more tables to it efficiently so that new sats can be built …
> the views will have hub keys … so hub has to come from there, 2nd the links will also be from
> same view.

Where each part of the rule is applied:

- **Grouping** (`generators/v5_plan.py`): every satellite sits whole on exactly one view. A view
  joins at most 10 tables, unless a single satellite on it needs more (rule 3), and then it has
  exactly that satellite's tables. Under-filled views absorb each other when they share a table or
  an anchor hub. Every rule is re-asserted against the finished plan.
- **Joining**: each table contributes branches carrying its hub business keys and the satellite
  attributes it feeds. Each satellite attribute is then merged across the view's tables on that
  satellite's own key, with `FIRST_VALUE … IGNORE NULLS` in source precedence (v2, then legacy,
  then delta 3). This keyed merge cannot fan out the way a multi-way FULL OUTER JOIN does, and it
  keeps every link pair at the grain of the source row that carries both legs.
- **Hubs and links come from the views.** Each hub's and link's `source_model` list contains only
  view-level stages.

### Why a stage per satellite as well as per view

`automate_dv.sat()` takes no filter. A view also carries keys from tables that don't feed every
satellite on it, and a `sat()` over a view-wide stage would load an all-NULL row for each of those
keys. Each satellite's own stage NULLs its key wherever it has no payload, and `sat()` skips NULL
keys. Model count is still held down by the central views: each satellite has one stage, and each
hub and link reads one stage per view rather than one per source table.

### Hash key convention

As in Partner and Travel: every key is `hash('{HUB_OR_LINK_CODE}|' || business_key)`, built as a
derived `*_NK` column and hashed by `automate_dv.stage()`. `_HKEY` suffix everywhere. Link keys
join their legs' business keys in hub-code order. Role satellites (`SAT_LNK_ROLE_*`) use the
ratified role-special pattern: off `HUB_PARTY` with a literal `ROLE_TYPE_CK`. `LOAD_DATETIME`
is `'!CURRENT_TIMESTAMP()'`, exactly as the reference projects write it.

**One naming deviation from the reference projects.** The hub business-key column is
`<HUB>_BK`, not `PARENT_BK`. One view-level stage carries several hubs, so a single `PARENT_BK`
can't serve them all. The alternative, and its cost in extra models, is in `BUILD_STATUS.json →
shared_gate_triage`. Which one to use is the user's call.

## Folder structure

```
health_consolidated_v5_dv_dbt/
  models/
    staging/health/             1:1 casts + _health__sources.yml
    automate_dv/
      standard/
        stitched/               the central views
        staging/                stage() per view and per satellite
        hubs/
        links/
        satellites/
        references/             (empty -- the map targets no reference satellite)
      augmented/
        staging/
        satellites/
  macros/                       (empty, as in partner)
  docs/                         BUILDER_ASKS_HEALTH_V5.md -- what goes back, and to whom
  generators/                   the Python that writes every model (see generators/README.md)
  build_artifacts/              BUILD_STATUS.json and reports/ -- what the build says about itself
  build_profile.json            every per-project fact the generators read
  packages.yml                  dbt-labs/dbt_utils, Datavault-UK/automate_dv
  dbt_project.yml
```

## Setup

```
dbt deps                          # installs dbt_utils + automate_dv per packages.yml
dbt debug                         # confirm the 'health_consolidated_v5_dv' profile connects
```

`vars` in `dbt_project.yml`: `health_raw_database` / `health_raw_schema` point staging at the
source tables. Staging, stitched and stage models are views; hubs, links and satellites are
incremental tables, using the plain AutomateDV defaults.

## What is verified, and what is not

Verified statically on every build (`generators/v5_verify.py`):

- every hub, link and satellite is an AutomateDV macro call, and every hash is computed by
  `stage()`;
- every column contract holds end to end: satellite → stage → central view → staging;
- the central-view rule holds;
- every mapped satellite row is accounted for (landed, refused with a reason, or a declared dedup);
- the build reproduces byte-identically after `models/` is deleted;
- no file outside this project changed.

The shared `vault_tools` gates run unmodified. Each of their findings is measured and classified
in `BUILD_STATUS.json → shared_gate_triage`.

**Not verified:** nothing has been compiled or run, so start with `dbt deps && dbt compile`. The
staging casts are all trimmed varchar, because the pinned inputs carry no type catalogue for the
legacy and v2 halves. Row filters (for example `TOP_INDICATOR='Y'`) appear only in the mapper's
prose, so none is applied; `build_profile.json → row_filters` takes them once they're confirmed.
