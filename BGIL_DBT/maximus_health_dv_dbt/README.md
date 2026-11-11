# Maximus Health Data Vault — dbt project, v4

Data Vault 2.0 build for Maximus Health (the shredded EAV UWR and CLM feeds), on Snowflake, using
[AutomateDV](https://automate-dv.readthedocs.io/) (`Datavault-UK/automate_dv`). It follows
[`partner_dv_dbt/`](../partner_dv_dbt/README.md) and [`travel_dv_dbt/`](../travel_dv_dbt/README.md)
exactly, in the same layout as [`health_consolidated_v5_dv_dbt/`](../health_consolidated_v5_dv_dbt/README.md).
It is built from **exactly the mapping `maximus_health_v3_dv_dbt` was built from**.

**Status: not yet `dbt deps`'d or run against Snowflake.** Every model is generated and verified
statically. Model counts, coverage, verification outcomes and the tree digest are in
`build_artifacts/BUILD_STATUS.json`.

## Why v4 exists

`maximus_health_v3_dv_dbt` calibrated on `opus_health_v2_dv_dbt` and inherited its hand-written
SQL. It called no AutomateDV macro, declared no packages, and its incremental models had no
incremental logic. The earlier Maximus Health builds had used AutomateDV. v4 puts the vault back
on the macros, in the reference layout, under the governing central-view rule.

## Source documents

These are read in place from `SourceMapping_Skill/Maximum Health Mapping V3/outputs/` (read-only),
each by md5 (`build_profile.json → inputs_pinned`):

- `04_column_map.pre_r1fix1.json` — **v3's map**. The bundle's live `04_column_map.json` is the
  mapper's later revision and is not read.
- `00_tables_index.json` — the shred graph (`shred.parent_table_candidate`) and every view's
  columns.
- `KEY_FUNCTIONS.pre_r1fix4.md`, `BUILD_INSTRUCTIONS_HEALTH_V3.pre_r1fix2.md` — the v3-vintage
  rules, applied as typed fields of the map.
- `data_7.js` — the canonical model. Satellite grain and child keys come from here.

## Architecture

```
Snowflake RAW.MAXIMUS_HEALTH (shredded EAV views)
        │
models/staging/maximus_health/stg_mxh__*.sql   -- 1:1 casts: every view a central view reads,
        │                                         feeding or walked
models/automate_dv/standard/
  stitched/stitch_v<NN>_*.sql                  -- THE CENTRAL VIEWS. Spine walks are joins, so
        │                                         they are resolved here. Plain SQL, no hashing.
  staging/stg2_v<NN>_*.sql                     -- automate_dv.stage() per view: every hub + link key
  staging/stg2_<satellite>.sql                 -- automate_dv.stage() per satellite, read off its view
        ▼
  hubs/ · links/ · satellites/                 -- hub() / link() / sat() / ma_sat()
models/automate_dv/augmented/{staging,satellites}
```

**No resolver, hop-view, unpivot, hub-feed or reject-log layer.** v3 carried those as extra
directories. Here:

- a spine walk is a chain of LEFT JOINs inside the central-view branch that needs it;
- an EAV column-as-instance child key is its own branch carrying the literal;
- a rejected key is a NULL key, which AutomateDV skips.

### Spine walks

- `spine[PARENT_KEY_HASH -> A -> B].COL` climbs one join per **real** level of the shred graph,
  `child.PARENT_KEY_HASH = parent.KEY_HASH`. The named hops are waypoints, and the levels they
  skip are expanded from the graph.
- `>> T.COL` descends into a sibling branch through a subquery grouped by the ancestor's
  `KEY_HASH`. The value is used **only when exactly one distinct value exists**, so a 1:N descend
  rejects the row rather than picking a value.
- Direction is always read from the graph, never from the arrow.

### Central views

These are the same rules as health v5. Every satellite sits whole on one view. A view has up to
the rule's table limit of **feeding** tables, unless one satellite needs more. Hubs and links read
only view-level stages. Ancestor and sibling tables joined only to resolve a key are listed in
each view's header as walk tables and don't count toward the limit.

### Directives applied (typed fields, never prose)

- Shred-surrogate child keys (`leg_backing == 'surrogate'`) are quarantined, never loaded as
  histories.
- `do_not_build` is honoured at both block and component scope.
- `reference_decode` rows that carry `build_directive` are refused.
- `hard_stop` preconditions are refused until the data check has been run.
- Keys are guarded against their own `degenerate_value`, and population namespaces are kept
  verbatim.
- `'spine:'` display operands are executed only when the row's own `resolved_key` walks to the
  same column.

### Conventions

As in Partner, Travel and health v5:

- keys are `'{HUB|LNK}_X|' || bk`, hashed by `stage()`, with the `_HKEY` suffix;
- `HASHDIFF` is bare, and child keys are `<LEG>_CK`;
- role satellites are off `HUB_PARTY` with a literal `ROLE_TYPE_CK`;
- `LOAD_DATETIME` is `'!CURRENT_TIMESTAMP()'`;
- the hub business-key column is `<HUB>_BK`, as in health v5.

## Setup

```
dbt deps
dbt debug                         # the 'maximus_health_v4_dv' profile
```

`vars`: `maximus_raw_database` / `maximus_raw_schema`. Physical schemas are
`std_automate_dv_maximus_health` and `aug_automate_dv_maximus_health`, separate from every other
build.

**Before `dbt run`:** see `BUILD_STATUS.json → preconditions_before_dbt_run`. In particular, the
map's ratified `normalise()` must exist as a Snowflake function.
