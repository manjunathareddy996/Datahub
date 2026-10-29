---
name: dv2-automatedv-dbt-builder
description: Build or extend a Data Vault 2.0 dbt project (AutomateDV/Datavault-UK package) on Snowflake from a source-to-target mapping workbook and a canonical data_N.js model. Covers hubs, links, satellites (incl. multi-active), stitch views, staging casts, augmented (build-side) tracks, and the mapper/modeler correspondence loop. Use when asked to build a new LOB's dbt vault, sync an existing one against a refreshed model/mapping, fix a satellite's child key, or investigate a "collapsed rows" / "data loss" report in a hub- or satellite-backed table.
---
 
# Data Vault 2.0 dbt builder (AutomateDV)

This skill has **two segments**:

- **Segment 1 — Build a brand-new LOB** (below): the end-to-end workflow to stand up a new LOB's
  dbt vault from scratch. Read this top to bottom when scaffolding a new project.
- **Segment 2 — Reference** (naming conventions, macro usage, known defect classes, checklists):
  the rules that apply to *all* work — both new builds and syncs/fixes on an existing build. Use
  Segment 1 for the sequence; reach into Segment 2 for the exact convention or macro call shape.

## When to use this skill

- **(Segment 1)** Standing up a new LOB's dbt project against a canonical `data_N.js` model and a
  `<LOB>_SourceToModel_Mapping.xlsx` workbook.
- **(Segment 2)** Applying a mapper/modeler reply or a model re-baseline (`data_6` → `data_7`,
  etc.) to an existing build.
- **(Segment 2)** Diagnosing "this satellite is losing rows" / "two entities collapsed onto one"
  reports — usually a missing or wrong multi-active child key.
- **(Segment 2)** Auditing an existing `sat()`/`ma_sat()` for the same defect class before it's
  reported.

Not for: one-off SQL edits unrelated to the vault structure, non-AutomateDV dbt projects,
star-schema/mart work (that's a different skill).

---

# SEGMENT 1 — Build a brand-new LOB (end to end)

## Inputs you need before starting a new build

You need exactly four things. Get all four in hand before writing any SQL.

1. **Canonical model** — `data_N.js` (the modeler's target model). Parse it once into JSON so you
   can query it repeatedly: `sats` / `hubs` / `links` / `refs` arrays, each entry carrying
   `code` / `parent` / `childkey` / `attrs`. This tells you what hubs/links/sats to build and, per
   satellite, its parent and whether it's multi-active (non-empty `childkey`).
2. **Mapping workbook** — `<LOB>_SourceToModel_Mapping.xlsx` (source → target column mapping).
   Sheets: Summary, Source→Target, Target→Source, Augmentation, Review Flags. Extract Source→Target
   to JSON once. This is the source of truth for which source column lands on which target
   attribute — every `mapped` row must end up in a built column.
3. **Source schema snapshot** — a cached dump of owner/table/column/type/length for the raw tables,
   so you can resolve column types and key candidates directly instead of asking the mapper.
4. **Conventions for this project** — the handful of per-project choices from Segment 2's
   "Conventions checklist" (hash-key suffix, record-source prefix, folder layout, etc.). Confirm
   these from a sibling LOB before generating; don't assume defaults.

(When *syncing* an existing build instead of scaffolding, you also need that LOB's
`dbt_project.yml`, its `models/.../standard/{staging,stitched,hubs,links,satellites}`, and its
README — but that's Segment 2 territory, not a new build.)

## Build workflow (new LOB)

### 1. Scaffold (new LOB only)
`dbt_project.yml` + `packages.yml` (dbt_utils, automate_dv) → per-table **stg1** staging casts
(see §1a), one per source table, 1:1 trimmed/typed casts, key columns always cast to canonical
trimmed varchar for stable hashing regardless of native type.

### 1a. Stage-1 (`stg1`) per-table staging models — one file per source table

The stg1 layer is one model per **source table**, a flat 1:1 typed/trimmed cast of that table and
nothing else. It is distinct from the `stg2_*` raw-vault staging (hub/link/sat `automate_dv.stage()`
calls) — stg1 is the plain source cast that every stg2, stitch and satellite macro reads from via
`ref()`. Do not conflate the two layers.

- **File name: `stg_<lob>__<table>.sql`** — the `<lob>` segment is the project's **LOB name**
  (`partner`, `travel`, `health`), **not** the source system, and is followed by a **double
  underscore** then the lowercased source table name. Examples from the live builds:
  `stg_partner__azbj_partner_extn.sql`, `stg_travel__ba_trv_data_policy_dtls_mv.sql`,
  `stg_partner__bjaz_hm_member_dtls.sql`. One stg1 file per source table, named after the table
  it casts — never a `stg2_`/`hub`/`sat`/`rolesat` prefix here (those belong to the raw-vault
  staging layer).
- **Location:** `models/staging/<lob>/stg_<lob>__<table>.sql` where the LOB uses a per-LOB subfolder
  (travel, health), or `models/staging/stg_<lob>__<table>.sql` where it does not (partner). Follow
  the project's existing layout; don't introduce a subfolder a project doesn't already use.
- **Structure:** a single `with source as ( select <casts> from {{ source('<raw_source>', '<TABLE>') }} ) select * from source`.
  No joins, no derived columns, no hashing — those are stg2/stitch concerns. A leading header comment
  states the casting rules and, where types came from a supplied schema CSV, that they were read from
  it (not inferred).
- **Casting idioms (match the project):**
  - text → `nullif(trim("COL"::varchar), '')` (partner) or `nullif(trim(to_varchar("COL")), '')`
    (travel — safe when the native type isn't already a string); both collapse empty string to NULL.
  - number → `"COL"::number`; timestamp/date → `"COL"::timestamp_ntz`.
  - **Key columns** (any hub/link business-key component) → always canonical **trimmed varchar**
    regardless of native type, so the downstream `hash()` is stable across reloads and across
    tables that type the same key differently.
- **Output column names are lowercased** snake-case aliases of the source columns; the source
  column reference stays quoted/upper (`"PART_ID"`) because the raw tables are upper-cased.

**`inc_job_updated_at` is a mandatory column in every `stg_` model.** Every source table carries
an `inc_job_updated_at` column, so pull it through in every per-table staging cast without
exception — it is the load/CDC watermark the incremental layer downstream depends on (the
`ldts_column` for `stitch_incremental`, and the `src_ldts` the multi-source satellite macros
filter their T-1 window on). A staging model missing it is a defect, not an optional omission:
there is no fallback business date to substitute, so any downstream incremental filter silently
degrades. Treat its presence as a build-gate check in `verify_<lob>.py` — every `stg_` model must
select `inc_job_updated_at`.
 
### 2. Resolve hub/link/satellite keys from the mapping
For every hub/link, find its business key: an explicit `KEY:` row in the mapping, else the
`Primary_Key` field in the source-system reference file, else a column verified against real
sample data (never trust a plausible-looking composite key from schema shape alone — see
Known Defect Classes #2). For every satellite, get its parent and **child key** from the
canonical model — a non-empty child key means multi-active (`ma_sat()`), empty means
single-active (`sat()`). Get this right before writing any SQL; getting it wrong is the #1
recurring defect (see below).
 
### 2b. Mapping completeness is the contract — every mapped row must land

The mapping workbook is the source of truth. Every stage, stitch, union, hub, link and satellite
file is a **generated artifact** of it. Two rules follow:

- **Never hand-edit a generated file to fix a mapping defect.** A wrong column in a generated
  stage is not a file to patch — it is evidence the generator has a defect. Patching the file
  hides the defect, drifts the file from what the next generation run emits, and leaves the same
  bug alive in every sibling target with the same shape. Fix the generator or its mapping input,
  regenerate, re-verify.
- **Every row marked `mapped` in Source→Target must be traceable to a built column.** A mapped
  source column the build silently drops is data loss, not a simplification. A satellite's
  contributing-table count must be what the mapping asked for, not what the generator managed.

Three ways a mapped row silently fails to land. Handle all three in the generator:

**(a) Several source columns → one target attribute (fan-in).** One source table can map multiple
columns onto the same target attribute. Emitting only one of them turns N mapped rows into one
built column. Collapse **all** columns landing on that attribute into a single deterministic
`coalesce(...)`, ordered by the workbook's own row/column order (or an explicit priority column
if the sheet provides one) so the result is stable across regenerations. Record the full column
list in the generated file's header comment so the fan-in is auditable without re-reading the
workbook.

  Decide fan-in versus multi-active from the workbook's domain/rationale columns first. If the
  columns are fallbacks for one logical value ("whichever is populated"), `coalesce` is correct.
  If they are semantically distinct values meant to coexist, that is a multi-active satellite
  with one branch per column and a literal child key (§4) — defaulting to `coalesce` there is
  defect class #1.

**(b) Target grain key absent from the source (needs a bridge hop).** A source can map real
attributes to a target whose grain key it does not carry. A single-source `automate_dv.stage()`
pass then has no `*_HKEY` to emit, so the generator drops the table entirely. Detect the
condition — "attribute mapped, but the target's grain key is not a column of this source" — and
resolve the key through a bridge table carrying both the source's own key and the target grain
key, emitting a bridged stage generated from the same mapping config. Prefer the bridge the
project's existing link stages already treat as authoritative for that grain, so the resulting
hash key matches a real link row rather than a synthesized one.

  Two things to get right. The bridge is typically many-to-many, so the branch's row count is
  driven by the bridge, not the attribute table — the attribute legitimately lands on every
  parent the bridge resolves. And when **no** bridge exists, the table is a genuine unresolvable
  gap: record it explicitly with its reason (which key is absent, what was checked, why the
  candidates failed) and reconcile against that record. A documented gap is fine; a silent drop
  is not. When a report contradicts a recorded gap, establish whether new mapper input reopened
  it or the report is treating a closed decision as a miss — before building anything.

**(c) Contributing-table count drift.** When (a) or (b) drops something, a generated header
comment reports what was built, not what was mapped, so the loss is invisible in the file.
Derive that count from the mapping and fail when the built branch count disagrees.

**Reconciliation is a build gate, not an audit.** Extend `verify_<lob>.py` with a closed-loop
check that runs every round:

1. Per target attribute, count `mapped` source columns in the workbook.
2. Count what actually lands: source columns referenced across the generated per-table stage
   branches, plus that attribute's presence in the union/stitch column list.
3. Any shortfall fails the build, naming the target attribute, source table and dropped columns,
   classified as fan-in (a), missing-grain-key (b), or documented gap.
4. Any mapped table with **no** generated branch for its target fails the same way.

Both silent-drop modes are defect *classes*, not one-off bugs — they were first found by a hand
audit of a single attribute. Whenever either is fixed, sweep every target where the workbook fans
several columns into one attribute, and every source whose grain key needs a hop, across all
union and stitch families in the project.

### 3. Build the standard-model track
- `stg2_hub_<table>__<hub>.sql` / `stg2_sat_<table>__<sat>.sql` — `automate_dv.stage()` calls,
  `PARENT_BK`/`PARENT_NK` derived columns, `hash('{HUB_OR_LINK_CODE}|' || raw_key)` via the
  `*_NK` helper — **never** a bare `hash(raw_key)` (breaks cross-LOB/cross-table key
  namespacing).
- `stitch_<name>.sql` only for attribute-joined satellites (FULL OUTER JOIN + COALESCE across
  multiple tables sharing one key) — union-only tables skip the stitch and feed `hub()`/
  `link()`/`sat()` directly from their per-table stage. Once a stitch exceeds ~2 tables or the
  sources are large, generate it through the `stitch_incremental` macro instead of hand-writing
  the chained join (see Segment 2 §4b "Incremental stitch via macro").
- `hub_<name>.sql` / `link_<name>.sql` / `sat_<name>.sql` / union of per-branch stage models
  via `automate_dv.hub()`/`link()`/`sat()`/`ma_sat()`.
- **Satellite file naming: `sat_<name>.sql`** — do **not** prefix the satellite model name with the
  source/LOB segment (no `sat_<source>_<name>`, e.g. use `sat_party`, `sat_aug_location`, not
  `sat_partner_party`). The source/LOB is **not** carried in the model name; it is carried only in
  the `RECORD_SOURCE` value (see the record-source prefix rule below). When two projects share a
  tree and write the same physical satellite, they use the same un-prefixed model name — the
  per-source disambiguation lives entirely in `RECORD_SOURCE`, not the file name.
- **Multi-source satellites — prefer the custom `sat_multi_source` / `ma_sat_multi_source`
  macros over a hand-written union feeding `automate_dv.sat()`/`ma_sat()`.** When a satellite is
  fed by more than one per-table stg2 model, do **not** build a separate `stg2_union__<sat>` view
  and point `automate_dv.sat()` at it — call `sat_multi_source` (single-active) or
  `ma_sat_multi_source` (multi-active, non-empty child key) instead. These macros union the
  per-table sources *inside* the macro, align columns into a payload superset, cast every payload
  column to `VARCHAR` so mismatched source types don't break the `UNION ALL`, apply the T-1
  watermark window, and run the standard change detection. A single-string `source_model`
  delegates straight to `automate_dv.sat()`, so the macro is a safe drop-in even for the 1-source
  case. See Segment 2 §4d "Custom multi-source satellite macros" for call shape.
- A hub *can* have multiple contributing branches with entirely different key formulas from
  different source systems — that's normal (`HUB_PARTY` fed by demographics, intermediaries,
  claim-suppliers, etc. all differently). What's *not* fine is one satellite silently
  degenerating to a coarser hub than its canonical parent when a real per-table key exists —
  always check for a real key before falling back (see Known Defect Classes #4).
 
### 4. Multi-active satellites: get the child key right
When a multi-active satellite is fed by more than one source, build it with the custom
`ma_sat_multi_source` macro (see Segment 2 §4d "Custom multi-source satellite macros") — pass the child
key as `src_cdk`. The macro groups by `(src_pk, src_cdk, record_source)` so a late-arriving
source cannot create phantom versions in another source's group. Everything below about deriving
the child-key value still applies; the macro only handles the union + change detection, not the
choice of child key.

For every satellite with a non-empty `childkey`:
- If the workbook gives an explicit `[ck:...]` bracket or `Instance/Child` column value, use
  that literal verbatim.
- If nothing is given, derive a literal from the source column's own name/semantics — one
  branch per distinct source column feeding the same generic payload slot (the
  `SAT_POLICY_TAX_HEAD` / `SAT_COVERAGE_MEMBER_BENEFIT` pattern: 30+ branches, one per column,
  literal `'!<Concept Name>'` as the `_CK` derived column).
- If the child key is itself data-driven (a real `*_TYPE`/`*_DESC` column already
  distinguishing rows), use the real column value as the `_CK`, not a literal.
- Every payload column not populated by a given branch still needs a `cast(null as <type>)`
  placeholder in that branch's `derived_columns` — match the type of the column where it *is*
  populated elsewhere (varchar vs. number), or the union across branches breaks.
- When degenerating to a coarser or synthetic key (no real business key available), fold every
  dimension the coarser key doesn't capture (typically "member") into the child key itself —
  otherwise you've just relocated the collision bug one level down.
 
### 5. Augmented (build-side) track
Columns flagged by the modeler's own Augmentation sheet, where the source table already
carries a verified key to the target hub — build directly, kept in a structurally separate
`models/automate_dv/augmented/` tree, not mixed into the mapper-confirmed standard model. Only
key/grain changes, shared reference masters, or cross-LOB-needed attributes go back to the
mapper; everything else is build-side by default (confirm this policy per-project — it was an
explicit mapper decision here, not a universal default).
 
### 6. Verify — every round, no exceptions
A small script per project (`verify_<lob>.py`), re-run after every batch of changes:
1. **Dependency-resolution sweep** — every `ref()`/`source_model` string resolves to a real
   `.sql` file. Catches dangling refs from renames/typos.
2. **`src_pk` vs `hashed_columns` cross-check** — every hub/link/satellite's declared `src_pk`
   appears in its source stage's `hashed_columns` keys. This is the exact check that catches
   naming-convention drift (e.g. `_HK` vs `_HKEY`) before it silently breaks 14 hubs.
3. **Mapping reconciliation gate** — the closed-loop count from §2b: every `mapped` source column
   in the workbook is traceable to a built column, and every mapped table has a generated branch
   for its target. Non-negotiable, and the only check that catches a *silently dropped* mapping —
   checks #1/#2 pass happily on a model that simply omits a column it was asked to build.
4. **Semantic key cross-check** (do this manually when a satellite was just repointed to a
   different/new hub) — diff the `PARENT_BK` expression string between the hub's stage file(s)
   and every satellite branch that's supposed to key on it. Structural checks #1/#2 don't catch
   a hub and satellite computing *different* formulas that both happen to reference real
   columns — that only shows up as silently orphaned rows at query time.
5. **Staging watermark presence** — every `stg_<lob>__<table>.sql` selects `inc_job_updated_at`
   (§1). Every source table carries it, so a `stg_` model without it is a defect that silently
   breaks the T-1 incremental window downstream. Fail the build naming any staging model missing
   it.
 
Cross-LOB work: if multiple LOB projects share a directory tree, verify the untouched ones are
still untouched (`find <other_lob>_dv_dbt -newer <marker-file> -type f`) after every round —
easy to touch a shared file by accident.
 
### 7. README + mapper correspondence
Keep one README per LOB project, one "Round N" section per sync/reply cycle, append-only
(don't rewrite history, mark superseded sections as superseded). Write a mapper follow-up note
**only when there's a genuinely unresolved question** — not as a routine per-round deliverable.
Resolve "please confirm" questions directly against cached schema/sample data first; only
escalate what can't be resolved that way. When the mapper's reply corrects something, apply it
precisely and re-verify — don't assume a single corrected example generalizes without checking
each remaining table individually (see Known Defect Classes #4).
 
---

# SEGMENT 2 — Reference (conventions, macros, defect classes)

Applies to all work — new builds and syncs/fixes alike. Segment 1 referenced these sections for
the exact macro call shapes and per-project conventions; the detail lives here.

## Project config files — `dbt_project.yml`, `packages.yml`, `profiles.yml`

Every LOB project uses the **same three project-config files with the same structure**. Use the
`opus_partner_dv_dbt` project as the template — a new LOB differs only in the project/profile name,
the `vars` (raw database/schema), and the warehouse/role/database in `profiles.yml`. The folder→
materialization→**tag** mapping under `models:` is identical across projects and must be preserved
exactly, because the `+tags` are what `dbt run --select tag:<tag>` and the verify scripts select on.

### `packages.yml`
Two local packages, vendored under `dbt_packages/` (not hub installs), so every project resolves
the same pinned AutomateDV / dbt_utils:
```yaml
packages:
  - local: dbt_packages/dbt_utils
  - local: dbt_packages/automate_dv
```

**`dbt deps` does not work in the Snowflake Workspace environment — vendor `dbt_packages/`
manually.** The Snowflake Workspace (where these projects run) has no outbound access to dbt Hub /
git to resolve packages, so `dbt deps` cannot download them. Instead the package *source trees* are
committed directly under each project's `dbt_packages/` directory and referenced with `- local:`
(not `- package:` / `- git:`). When standing up a new LOB, **copy the `dbt_packages/dbt_utils` and
`dbt_packages/automate_dv` folders from an existing project** (e.g. `opus_partner_dv_dbt`) rather
than running `dbt deps`. Keep the versions identical across all LOBs so macro behaviour matches.

Pinned versions currently vendored in `opus_partner_dv_dbt` (use these for new LOBs):
- **automate_dv `0.11.5`** (`dbt_packages/automate_dv/dbt_project.yml` → `version: 0.11.5`)
- **dbt_utils** — copy the vendored folder as-is; match the folder, don't try to re-resolve via
  `dbt deps`.

### `profiles.yml`
One profile named `<project>_dbt` (e.g. `opus_partner_dbt`), `target: dev`, with `dev` and `prod`
Snowflake outputs. `account`/`user` are placeholders (`"_"`) overwritten by the Snowflake CLI
connection (env vars) at deploy time — do not hard-code credentials. Keep `schema: BGIL_DATA_MODEL`
and the warehouse/role as the project requires:
```yaml
<project>_dbt:
  target: dev            # default
  outputs:
    dev:
      type: snowflake
      account: "_"       # overwritten by Snowflake CLI connection (env var) at deploy time
      user: "_"          # overwritten by Snowflake CLI connection (env var) at deploy time
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

### `dbt_project.yml`
Standard dbt path block, `profile: '<project>_dbt'`, a `vars:` block for the raw source
database/schema (prod + preprod/test pairs), and the shared **run-log pre/post-hook** (writes
`RUNNING`/`SUCCESS` rows into `...UTILS.MAXI_RAW_DBT_MODEL_RUN_LOG` on the `dev` target only). The
`models:` tree below is the **canonical layer → materialization → tag** map; replicate it verbatim
for a new LOB (only the top-level project key name changes):

```yaml
name: '<project>_dv_dbt'
version: '1.0.0'
profile: '<project>_dbt'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets: ["target", "dbt_packages"]

vars:
  <lob>_raw_database: <RAW_DB>
  <lob>_raw_schema: <RAW_SCHEMA>
  <lob>_test_raw_database: <TEST_RAW_DB>
  <lob>_test_raw_schema: <TEST_RAW_SCHEMA>

models:
  <project>_dv_dbt:
    +pre-hook:   # dev-only run-log INSERT (RUNNING) into MAXI_RAW_DBT_MODEL_RUN_LOG
    +post-hook:  # dev-only run-log UPDATE (SUCCESS)
    staging:                       # stg1 per-table casts (Segment 1 §1a)
      +materialized: view
      +schema: BGIL_DATA_MODEL
      +tags: ["stg1"]
    raw_vault:
      standard:
        +schema: BGIL_DATA_MODEL
        stitched:
          +materialized: view
          +tags: ["stitch"]
        staging:                   # stg2_* automate_dv.stage() calls
          +materialized: view
          +tags: ["standard_stg2"]
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
          +tags: ["standard_sat"]
          +on_schema_change: append_new_columns
        references:
          +materialized: view
          +tags: ["ref"]
      augmented:                   # build-side track (Segment 1 §5)
        +schema: BGIL_DATA_MODEL
        +tags: ["aug"]
        staging:
          +materialized: view
          +tags: ["aug_stg2"]
        satellites:
          +materialized: incremental
          +tags: ["aug_sat"]
          +on_schema_change: append_new_columns
```

**Tag map (memorize — these drive `--select tag:<tag>` and verification):**

| Folder | Materialized | Tag |
|--------|--------------|-----|
| `staging/` (stg1) | view | `stg1` |
| `raw_vault/standard/stitched/` | view | `stitch` |
| `raw_vault/standard/staging/` (stg2) | view | `standard_stg2` |
| `raw_vault/standard/hubs/` | incremental | `hub` |
| `raw_vault/standard/links/` | incremental | `lnk` |
| `raw_vault/standard/satellites/` | incremental | `standard_sat` |
| `raw_vault/standard/references/` | view | `ref` |
| `raw_vault/augmented/` (whole tree) | — | `aug` |
| `raw_vault/augmented/staging/` | view | `aug_stg2` |
| `raw_vault/augmented/satellites/` | incremental | `aug_sat` |

Notes:
- **Incremental layers** (hubs, links, both satellite folders) carry `+on_schema_change: append_new_columns`
  so a new payload/superset column appends instead of erroring on re-run — this is the config the
  `sat_multi_source` superset growth (§4d) relies on. Views (stg1, stg2, stitched, references) do not.
- `+schema: BGIL_DATA_MODEL` is set at every layer so all objects land in one schema regardless of
  nesting depth.
- The `augmented` subtree mirrors `standard` but with its own `aug*` tags, keeping the build-side
  track selectable/auditable separately from the mapper-confirmed standard model (§5).

### 4b. Incremental stitch via macro (`stitch_incremental`)

A hand-written stitch does a chained `FULL OUTER JOIN` over every contributing table at full
volume on every evaluation. With N tables of M rows each that is an M^N-shaped cross-product
even when only a handful of source rows changed. Use `macros/stitch_incremental.sql` to generate
a T-1 delta-driven equivalent instead. It produces **bit-identical output** to the hand-written
stitch for the affected keys — the coalesce priority ladder is unchanged, only the row
population shrinks.

**Two-phase logic the macro emits:**
1. `affected_keys` — `UNION` of `DISTINCT key_column` from every source. Without `target_sat` the
   filter is the legacy T-1 `ldts_column >= DATEADD(DAY, -1, CURRENT_DATE())`; with `target_sat` it
   is the parameterized window `from_date < ldts_column <= to_date` (see "Watermark is scoped per
   source system" below). Small, partition-pruned scans.
2. Per-table CTEs (`t0`, `t1`, …) — each source read **at full history** but constrained by
   `key_column IN (SELECT <unique_key> FROM affected_keys)`. Full history matters: a key that
   changed only in `t0` today may hold its `segmentcode` in a `t3` row loaded weeks ago, so
   delta-to-delta joining would silently lose attributes. The `IN` clause becomes a semi-join
   pushdown, so no table is ever fully scanned.
3. One chained `FULL OUTER JOIN` across the key-filtered slices, then the original
   `COALESCE` ladder and `ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(...))` record_source.

**Do not** generate one driver pass per table UNION'd together (`pass_t0 UNION ALL pass_t1 …`).
That was tried and is *slower* than the original full outer join — each pass re-references the
full CTEs, and Snowflake re-materializes them per reference, so a 5-table stitch scans each
source ~6 times. Collapse all deltas into a single `affected_keys` set and do exactly one join
pass.

**Watermark is scoped per source system (when `target_sat` is passed).** A stitch is
single-system by design — every `source_tag` in one stitch shares the same `<SYSTEM>_` prefix
(`OPUS_AZBJ_...`, `OPUS_BJAZ_...` → system `OPUS`). The macro derives that group as the text
before the first `_` in `source_tag`, **validates every source shares it** (mixed prefixes or a
malformed `source_tag` raise a compile error), and scopes the `from_date` watermark query to that
system's rows in the shared target sat:
```sql
SELECT COALESCE(MAX(DBT_RUN_TS), TO_TIMESTAMP_NTZ('1900-01-01')) AS mx
FROM {{ target_sat }}
WHERE RECORD_SOURCE LIKE '<GROUP>_%'
```
This matters because the target sat is written by **multiple** stitches (one per system) through
`sat_multi_source`. Without the `LIKE '<GROUP>_%'` filter, an OPUS stitch's `MAX(DBT_RUN_TS)` would
pick up a more-recent MAXIMUS load into the same sat and wrongly conclude OPUS is caught up,
skipping its own new source rows. The filter keeps each stitch reading only its own system's
high-water mark. No new parameter is needed — the group comes from the `source_tag` you already
pass. This pairs with the `sat_multi_source` change that **stopped re-prepending** the group to
`RECORD_SOURCE` (the value already carries the system prefix, so stored values are `OPUS_<TABLE>`,
not `OPUS_OPUS_<TABLE>`), so both layers' `LIKE '<GROUP>_%'` filters match the stored values.

> Open item (deferred): `sat_multi_source` re-applies a `LOAD_DATETIME` window on top of the one
> the stitch already applied. For a steady-state stitch input that time window is largely
> redundant, but it is still needed generically for direct (non-stitched) sources, mixed inputs,
> and first-run sources; the sat-level **hashdiff change detection** is always required regardless.
> `ma_sat_multi_source` now carries the same per-source-group watermark scoping (`src_record_source_map`
> is required and the `MAX(DBT_RUN_TS)` lookup is filtered `WHERE RECORD_SOURCE LIKE '<GROUP>_%'`).

**Config shape (per calling model):**
```
sources        - list of dicts: model, alias, key_column, ldts_column, columns[{src,tgt}], source_tag
output_columns - list of target attribute names (excludes parent_bk and record_source)
coalesce_rules - dict: target column -> ordered list of aliases (the priority ladder)
unique_key     - join/output key, default 'parent_bk'
```
The macro is grain- and count-agnostic: 2 tables or 22, differing `key_column` names per table
(`part_id` / `partner_id` / `intermediary_id`), differing watermark columns per table. Only the
`sources` list and `coalesce_rules` change between stitches.

**Jinja/SQL pitfalls that will bite when writing a new one:**
- **Single-source columns**: a `coalesce_rules` entry with one alias (e.g. `buildingname: ['t0']`)
  must emit `t0.buildingname`, *not* `COALESCE(t0.buildingname)` — Snowflake rejects a 1-arg
  `COALESCE` (`not enough arguments for function [COALESCE(...)], expected 2, got 1`). The macro
  branches on `| length == 1`; preserve that when editing.
- **First join in the chain**: emit `ON t0.pk = t1.pk`, not `ON COALESCE(t0.pk) = t1.pk` — same
  1-arg `COALESCE` failure. Subsequent joins use `COALESCE(t0.pk, t1.pk, …)` as the original does.
- **Whitespace trimming**: `{%- ... -%}` on the macro declaration and on the model's final
  `{% set %}` block collapses the newline dbt needs between its generated
  `CREATE OR REPLACE VIEW … AS` and the macro's leading `WITH`. Symptom is a nonsense error like
  `unexpected 't0_delta'` at the first CTE, or a mangled view name (`..._incras`). Leave the last
  `set` block closing with plain `%}` and let the macro output start with a newline + `WITH`.
- **Nested `WITH`**: the macro emits a complete `WITH … SELECT`. Do not wrap the call in
  `WITH some_branch AS ( {{ stitch_incremental(...) }} )` — Snowflake has no nested-CTE support.
  If a stitch needs extra branches, `UNION ALL` them *after* the macro call at the top level.
- **Missing watermark column**: not every staging model exposes `gg_change_date`
  (`stg_partner__bjaz_sh_mem_dtls_extn` has only business dates: `effetive_date`, `expiry_date`,
  `inception_date`). Grep each source for the watermark column *before* writing the config; a
  table without one either sits outside the macro (no T-1 filter, contributes in full) or needs
  a load timestamp added to its staging model.

**Composite / content-hash branches stay hand-written.** `stitch_common_address` has a
`code_branch` (6 tables joined on a real location id — macro handles this) plus a
`composite_branch` of 6 contributions keyed on a content hash of the normalized address parts
(defect class #5). Those are `UNION ALL`'d independent selects with no joins between them, so
they have no cross-product problem and gain nothing from the macro — filter each one directly
on its own watermark and `UNION ALL` onto the macro output.

**Materialization tradeoff.** As a `view` the stitch is re-evaluated on every downstream query,
so it can never beat the original on read cost alone — the win is that the delta filter makes
each evaluation cheap. If read latency is the real constraint, materialize the stitch as
`incremental` with `unique_key=<pk>`, `incremental_strategy='merge'`, tracking its own
`_stitch_ldts` as the watermark; downstream satellites then read a pre-computed table. Keep it a
view when the requirement is "stitch must only ever show T-1 data" and the downstream satellite
already handles incrementality.

**Validate every new stitch against the original before switching downstream refs.** Keep the
hand-written view in place, build the `_incr` alongside, and confirm:
```sql
-- must return 0 rows
SELECT i.parent_bk FROM stitch_<name>_incr i
JOIN stitch_<name> o ON i.parent_bk = o.parent_bk
WHERE i.<attr> != o.<attr> OR i.record_source != o.record_source;

-- must return 0 rows
SELECT parent_bk, COUNT(*) FROM stitch_<name>_incr
GROUP BY parent_bk HAVING COUNT(*) > 1;
```
Then trace one real key end-to-end: confirm it appears in each table its `record_source` claims,
and that at least one of those rows has `ldts_column >= T-1` (proving it was picked up by the
delta, not by accident). Expect the `_incr` view to have *fewer* keys than the original — keys
whose every contributing row landed today only appear once today becomes T-1.

### 4c. Stitch layer usage example (`stitch_incremental` macro call)

```sql
{{ config(materialized='view') }}

{%- set sources = [
    {
        'model': 'stg_<lob>__<source_table_1>',
        'alias': 't0',
        'key_column': '<key_col_in_source_1>',
        'ldts_column': '<watermark_col>',
        'columns': [
            {'src': '<raw_col_a>', 'tgt': '<target_attr_a>'},
            {'src': '<raw_col_b>', 'tgt': '<target_attr_b>'}
        ],
        'source_tag': '<SOURCE_TABLE_1>'
    },
    {
        'model': 'stg_<lob>__<source_table_2>',
        'alias': 't1',
        'key_column': '<key_col_in_source_2>',
        'ldts_column': '<watermark_col>',
        'columns': [
            {'src': '<raw_col_c>', 'tgt': '<target_attr_b>'}
        ],
        'source_tag': '<SOURCE_TABLE_2>'
    }
] -%}

{%- set output_columns = ['<target_attr_a>', '<target_attr_b>'] -%}

{%- set coalesce_rules = {
    '<target_attr_a>': ['t0'],
    '<target_attr_b>': ['t0', 't1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='<target_satellite_name>'
) }}
```

**Config fields explained:**

| Field | Purpose |
|-------|---------|
| `model` | The stg1 model name (ref'd by the macro) |
| `alias` | CTE alias used in COALESCE and JOIN (t0, t1, ...) |
| `key_column` | Column in stg1 that maps to the hub business key (becomes `parent_bk`) |
| `ldts_column` | Watermark column for incremental filtering (e.g. `inc_job_updated_at`, `gg_change_date`) |
| `columns` | List of `{src, tgt}` — source column name → target attribute name |
| `source_tag` | Literal for RECORD_SOURCE (audit trail) |
| `output_columns` | Final SELECT columns (excludes `parent_bk` and `record_source`, added automatically) |
| `coalesce_rules` | Priority ladder per column: `{'col': ['t0', 't1']}` = t0 wins, t1 fallback |
| `unique_key` | Output key column name (default `parent_bk`) |
| `target_sat` | Downstream satellite name — macro reads `MAX(DBT_RUN_TS)` from it for watermark |

**What the macro generates at runtime:**

```sql
WITH affected_keys AS (
    -- UNION of keys from each source where ldts > from_date AND ldts <= to_date
),
t0 AS (
    -- DISTINCT key + columns from source 1 (full history, filtered by affected_keys)
),
t1 AS (
    -- DISTINCT key + columns from source 2 (same)
),
final AS (
    SELECT
        ak.parent_bk,
        t0.<target_attr_a> AS <target_attr_a>,
        COALESCE(t0.<target_attr_b>, t1.<target_attr_b>) AS <target_attr_b>,
        ARRAY_TO_STRING(ARRAY_CONSTRUCT_COMPACT(...)) AS record_source
    FROM affected_keys ak
    LEFT JOIN t0 ON t0.parent_bk = ak.parent_bk
    LEFT JOIN t1 ON t1.parent_bk = ak.parent_bk
    QUALIFY ROW_NUMBER() OVER (PARTITION BY ak.parent_bk ORDER BY ...) = 1
)
SELECT parent_bk, <target_attr_a>, <target_attr_b>, record_source FROM final
```

**Downstream stg2 pattern** (adds hash + DBT_RUN_TS):

```sql
{%- set run_ts_utc = run_started_at.strftime('%Y-%m-%d %H:%M:%S') -%}
{%- if var('to_date', none) is not none -%}
    {%- set dbt_run_ts_expr = "CAST('" ~ var('to_date') ~ "' AS TIMESTAMP_NTZ)" -%}
{%- else -%}
    {%- set dbt_run_ts_expr = "CAST(CONVERT_TIMEZONE('UTC','Asia/Kolkata', '" ~ run_ts_utc ~ "'::timestamp_ntz) AS TIMESTAMP_NTZ)" -%}
{%- endif -%}

SELECT staged.*, {{ dbt_run_ts_expr }} AS DBT_RUN_TS
FROM (
    {{ automate_dv.stage(include_source_columns=true,
                          source_model='stitch_<name>',
                          hashed_columns=...,
                          derived_columns=...) }}
) AS staged
```

**Run command (stitch + all downstream):**
```bash
dbt run --select stitch_<name>+
```

### 4d. Custom multi-source satellite macros (`sat_multi_source` / `ma_sat_multi_source`)

`macros/sat_multi_source.sql` and `macros/ma_sat_multi_source.sql` are project-local macros that
replace the "hand-written union view → `automate_dv.sat()`/`ma_sat()`" pattern for any satellite
fed by more than one source table. They exist because a satellite that unions N per-table stg2
models otherwise needs a separate `stg2_union__<sat>` (or stitch) artifact just to align columns
before the standard `sat()` call — that extra file is one more generated artifact to keep in sync
and one more place for the fan-in / dropped-column defects (§2b, defect classes #9/#10) to hide.
These macros fold the union in.

**Scope — satellites only, multi-source only.** These macros exist for the one case where a
**satellite** is fed by **more than one source table**. Two hard boundaries:
- **Satellites only.** Never use them for hubs or links — `automate_dv.hub()`/`link()` keep the
  per-branch stage union. The macros emit satellite-shaped change detection (hashdiff / group
  membership), not hub/link dedupe.
- **Multiple sources only.** When a satellite has exactly one source, call `automate_dv.sat()` /
  `automate_dv.ma_sat()` directly. The single-string `source_model` path exists purely as a safe
  delegation hatch (e.g. a 2-source sat that drops to 1 after a `_HIST` removal, defect class #13),
  **not** as the default for a genuinely single-source satellite. Don't reach for the multi-source
  macro when one source is all the mapping ever asked for.

**When to use which (once multi-source is established):**
- `sat_multi_source` — single-active satellite (empty canonical `childkey`), two or more sources.
  A single-string `source_model` delegates verbatim to `automate_dv.sat()` (the delegation hatch
  above); a list triggers the union path.
- `ma_sat_multi_source` — multi-active satellite (non-empty `childkey`), two or more sources. Pass
  the child key as `src_cdk` (string or list). Grouping is by `(src_pk, src_cdk, record_source)`.

**What the macro does for you (so you don't hand-build it):**
- Unions every `source_model` with `UNION ALL`, casting each payload column to `VARCHAR` so a
  column that is `NUMBER` in one source and masked `VARCHAR` in another does not fail the union.
- Builds a payload **superset** from `src_payload` (authoritative when given) and pads any column
  a given source lacks with `CAST(NULL AS VARCHAR)`, so every branch is column-aligned.
- Applies the same T-1 watermark window as `stitch_incremental` (`var('to_date')`/`var('from_date')`
  overrides, else `MAX(DBT_RUN_TS)` from the target sat via `{{ this }}`, else `1900-01-01`
  sentinel) and stamps `DBT_RUN_TS`. The `MAX(DBT_RUN_TS)` watermark is now computed **per logical
  source system** (the `src_record_source_map` group), not once across the whole sat — each group's
  window is read with `WHERE RECORD_SOURCE LIKE '<GROUP>_%'`, so a lagging source re-loads from its
  own last run rather than from another system's newer watermark.
- Runs change detection: per-row hashdiff (LAG over `(src_pk, record_source)`) for
  `sat_multi_source`, per-**group** (member-set + count, over `(src_pk, record_source)`) for
  `ma_sat_multi_source`.
- (`sat_multi_source` only) Optionally renames the source hashdiff to a shared output name via
  `src_hashdiff_alias`, so two projects writing the same physical sat from differently-suffixed
  source hashdiffs still agree on the stored column name.

**OBJECT branch (`sat_multi_source` + `src_object_columns`).** Normally each source table
contributes its own rows to the sat (one row per `(src_pk, record_source)`). When several source
tables each hold *one logical value* of the same attribute for a party and you want them folded
into a single row keyed by source table rather than fanned out as separate record-source rows,
pass those payload columns as `src_object_columns`. The macro then:
- regroups to one row per `(src_pk, source group)` (record source becomes `'<GROUP>_MULTI'`),
- first collapses each `(src_pk, group, source_table)` to one value (`MAX`) so `OBJECT_AGG` never
  sees a duplicate key,
- emits each object column as `OBJECT_AGG(source_table, TO_VARIANT(value))` — a map from
  contributing source table to its value — with non-object payload columns reduced by `MAX`,
- hashes the row over `TO_JSON(object_col)` + the plain columns for change detection.
Use this only when the per-source-table breakdown is the thing you want to preserve *inside* one
row; the default row-per-source behaviour is correct for ordinary multi-source sats.

**`src_column_map` is how you avoid the fan-in / dropped-column defects.** When sources expose
different subsets of the payload, pass an explicit `src_column_map` (`model → [columns it
provides]`). Without it the macro introspects each relation and assumes any not-yet-materialised
source provides the full `src_payload`. Deriving the map from the mapping workbook (not from
whatever columns happen to exist) is what keeps the §2b reconciliation gate honest.

**`src_record_source_map` is now REQUIRED for `sat_multi_source` whenever `source_model` is a list.**
It maps each source model to its logical source-system group (`model → 'OPUS'` / `'MAXIMUS'` / …).
The macro uses it to
(a) compute the per-source-system `MAX(DBT_RUN_TS)` watermark (see above) and (b) prefix the emitted
`RECORD_SOURCE` as `'<GROUP>_' || <source's RECORD_SOURCE>`. The map must cover every entry in
`source_model` with a non-empty value or the macro raises a compile error. Derive the group from the
source's `RECORD_SOURCE` literal in its stg2 model (`!OPUS_...` → `'OPUS'`, `!MAXIMUS_...` →
`'MAXIMUS'`). A single-string `source_model` (the `automate_dv.sat()` delegation path) does not need
it. **`ma_sat_multi_source` requires it too** — it is always a list path, and the macro raises the
same compile error if the map is missing or does not cover every source; it drives the per-source-
group watermark scope identically.

Also set **`on_schema_change='append_new_columns'`** in the config so new payload columns added to
the superset over time are appended to the target table rather than erroring on re-run.

**Config shape (single-active):**
```sql
{{
    config(materialized='incremental', incremental_strategy='merge',
           on_schema_change='append_new_columns',
           unique_key=['<HUB>_HKEY', 'HASHDIFF', 'RECORD_SOURCE'])
}}
{%- set yaml_metadata -%}
source_model:
  - 'stg2_..._a'
  - 'stg2_..._b'
src_pk: '<HUB>_HKEY'
src_payload: ['ATTR_A', 'ATTR_B']
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_..._a: 'OPUS'
  stg2_..._b: 'OPUS'
{%- endset -%}
{% set metadata_dict = fromyaml(yaml_metadata) %}
{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_..._a': ['ATTR_A'],
                        'stg2_..._b': ['ATTR_B']
                    }) }}
```

**Multi-active** is identical plus `src_cdk` in both the metadata and the call, and the child key
in `unique_key`:
```sql
config(... unique_key=['<HUB>_HKEY', 'MEMBER_SEQUENCE', 'HASHDIFF', 'RECORD_SOURCE'])
...
src_cdk: ['MEMBER_SEQUENCE']
...
{{ ma_sat_multi_source(src_pk=..., src_cdk=metadata_dict['src_cdk'], src_payload=...,
                       src_hashdiff=..., src_ldts=..., src_source=...,
                       source_model=..., src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={...}) }}
```
(`ma_sat_multi_source` **requires** `src_record_source_map` too — it raises a compile error if it
is missing or not a mapping — and uses it to scope the per-source-group `MAX(DBT_RUN_TS)` watermark
(`WHERE RECORD_SOURCE LIKE '<GROUP>_%'`), exactly as `sat_multi_source` does. It does **not** take
`src_object_columns` / `src_hashdiff_alias` / `on_schema_change` / `src_eff` — those are
`sat_multi_source`-only. Change detection is per-**group** over `(src_pk, src_cdk, record_source)`.)

**Parameters:**

| Param | Required | Purpose |
|-------|----------|---------|
| `src_pk` | yes | Parent hub/link hash key column (`unique_key`'s grain key) |
| `src_cdk` | `ma_` only | Child key (string or list) — the multi-active grain |
| `src_payload` | yes | Authoritative payload superset (the columns the satellite carries) |
| `src_hashdiff` | yes | Hashdiff column, usually `'HASHDIFF'` |
| `src_ldts` | yes | Load-datetime / watermark column on each source, usually `'LOAD_DATETIME'` |
| `src_source` | yes | Record-source column, usually `'RECORD_SOURCE'` |
| `source_model` | yes | String (→ delegates to `automate_dv.sat()`) or list of stg2 model names |
| `src_record_source_map` | yes (both macros) | `model → source-system group` (`'OPUS'`/`'MAXIMUS'`/…); drives the per-source-system watermark (`LIKE '<GROUP>_%'`) and, for `sat_multi_source`, the `RECORD_SOURCE` prefix. Required for `sat_multi_source`'s list path and **always** for `ma_sat_multi_source` |
| `src_column_map` | recommended | `model → [columns it provides]`; skips per-source introspection and is how §2b fan-in is made explicit |
| `src_extra_columns` | no | Extra non-payload columns to carry through |
| `src_eff` | `sat_` only | Effective-from column if the satellite is effectivity-tracked |
| `src_object_columns` | `sat_` only, no | Payload columns to collapse into a per-source-table `OBJECT_AGG` instead of unioning as rows — see OBJECT branch below. Each named column must be in `src_payload`. Changes the grain to one row per `(src_pk, source group)` |
| `src_hashdiff_alias` | `sat_` only, no | Output name to WRITE the source hashdiff under. Lets a source exposing a suffixed hashdiff (e.g. `HASHDIFF_COMMON_CONTACT` in a wide view) land in the shared table under a common name (e.g. `HASHDIFF`) so sibling projects share one hashdiff column. Defaults to `src_hashdiff` (no rename) |
| `src_run_ts` | no | Watermark/stamp column name, default `'DBT_RUN_TS'` |

**Pitfalls:**
- The macro reads its own watermark from `{{ this }}`; the target must be materialized
  `incremental` with `merge` (as in the config blocks above) or the `MAX(DBT_RUN_TS)` lookup has
  nothing to read on re-runs.
- `unique_key` must include `RECORD_SOURCE` for the multi-source path (change detection is
  per-source-group), unlike a plain single-source `automate_dv.sat()`.
- `src_record_source_map` must map **every** list entry to a non-empty group, or the macro raises a
  compile error. The group value must match the `RECORD_SOURCE` literal prefix in the source's stg2
  model (`!OPUS_...` → `'OPUS'`), because the watermark lookup filters `RECORD_SOURCE LIKE '<GROUP>_%'` —
  a mismatched group silently reads a `1900-01-01` watermark and reprocesses everything each run.
- Keep `src_payload` the authoritative superset and let `src_column_map` say who provides what —
  don't rely on relation introspection for the source-of-truth column set, or a mapped column that
  simply isn't in the current relation gets silently dropped (defect class #9).

## Known defect classes (checked for every satellite, every round)
 
1. **Silent multi-active collision** — a satellite that should be `ma_sat()` (or should have a
   richer child key) is built as `sat()`/blank-CDK `ma_sat()`, and multiple source rows sharing
   a blank/shared literal child key collapse via hashdiff-based upsert. Symptom: fewer rows
   than expected, or one concept's value silently overwritten by another's. Fix: distinct
   literal or real column per branch/concept.
2. **Composite key built from an unstable surrogate** — a column that *looks* like a good
   composite-key component from the PK-file/schema shape alone, but real sample data shows it's
   a large internal surrogate unstable across reloads (or too sparse to be real). Always check
   real sample values before trusting a "discovered" key, not just schema metadata.
3. **`_HK` vs `_HKEY` (or any naming-convention drift)** — different LOB projects may use
   different short/long hash-key suffixes; picking the wrong one for a given project breaks
   every downstream `src_pk` match. Caught structurally by verify step #2 — but only if the
   convention is applied *consistently* within a project from the start.
4. **Wrong fallback grain when a real key exists** — degenerating a satellite to a coarser hub
   (e.g. policy-level) when the canonical model wants a finer one, without first exhaustively
   checking every contributing table for a real key. Especially dangerous for **single-active**
   satellites (no child key to fall back on) — a wrong fallback there isn't a simplification,
   it's silent data loss (multiple real rows collapse to one). Multi-active satellites are more
   forgiving (the child key can absorb some of the lost grain) but still lose real mapped data
   if the fallback merges what should've been distinct branches.
5. **Weak/bare address or location key** — keying `HUB_LOCATION` on a bare pincode or single
   address line when the satellite carrying the address attributes is single-active; distinct
   real addresses collapse onto one row. Needs the content hash of the full normalized address,
   or a real location-id column.
6. **Mapper prose imprecision on a key name** — a reply describing a formula in words
   (`"keyed X → HUB_Y"`) can name the wrong exact column even when the *intent* is right (e.g.
   naming a table's nearby ID column instead of the one its existing hub branch actually
   computes on). Always cross-check a reply's stated key against what the existing, working
   build already uses for that same table — silently orphans rows otherwise.
7. **Delta-to-delta stitch join** — filtering *every* table in a stitch to the delta window and
   joining those slices together. Attributes for a changed key that live in another table's
   *unchanged* history are silently dropped, so the row is emitted with NULLs where the
   hand-written stitch had values. The delta window may only drive key *discovery*; attribute
   resolution must read full history constrained by those keys. Caught by the "0 rows differ"
   diff against the original stitch — which is why that diff is mandatory before switching
   downstream refs.
8. **Per-driver UNION stitch (performance regression)** — generating one join pass per source
   table and UNION-ing them. Correct output, but each pass re-references the full per-table CTEs
   and Snowflake re-materializes them per reference, so total scans go *up* versus the original
   full outer join. Symptom: the "optimized" stitch is slower than the one it replaced. Fix:
   single `affected_keys` set, single join pass.
9. **Dropped fan-in (several mapped columns → one attribute)** — the workbook maps multiple
   columns of one source table onto a single target attribute and the generator emits only one.
   Symptom: the attribute is NULL for rows where a non-picked column held the value; the workbook
   shows N mapped rows where the model has 1. Fix: deterministic `coalesce` over all mapped
   columns, or a multi-active branch per column when the values are meant to coexist (§2b(a)).
10. **Dropped source: target grain key not in the source** — a source maps real attributes to a
    target whose grain key it does not carry, so the stage pass has no hash key to emit and the
    generator skips the table. Symptom: contributing-table count below the mapping's, no error
    anywhere. Fix: resolve the key through a bridge carrying both keys, or record a documented
    unresolvable gap — never a silent drop (§2b(b)).
11. **Hand-patched generated file** — fixing a mapping defect by editing a generated stage,
    stitch or union file directly. The next generation run reverts it, the defect stays live in
    every sibling target, and the file no longer matches its generator. Symptom: a file whose
    content cannot be reproduced from the mapping. Fix: change the generator or its mapping
    input, regenerate, re-verify.
12. **Record-source prefix drift (missing source-system prefix)** — a `RECORD_SOURCE` (`!`-derived
    column in `stg2` stages) or `source_tag` (stitch source dicts) literal built without the
    project's standard source-system prefix, e.g. `!CP_PARTNERS` instead of `!OPUS_CP_PARTNERS`.
    Every record-source literal in a project must carry the **same** prefix (`OPUS_` here — the
    source system feeding the raw layer); one un-prefixed value pollutes lineage/audit and breaks
    any downstream filter or dedupe keyed on record source. It passes every structural check
    silently because the value is still a valid string. Fix: normalize to the project's prefix.
    Confirm the prefix per project (it's the raw-ingestion source system, not a universal
    constant) and add it as a build-gate: the distinct set of record-source literals across
    `stg2_*` (`RECORD_SOURCE:`) and stitch (`'source_tag':`) files must all begin with that one
    prefix — any literal without it fails the build, naming the file.
13. **Redundant `_HIST` source built alongside its current counterpart** — a source table exists
    in both a current form and a history form (`BJAZ_CP_PART_HIST` vs `CP_PARTNERS`,
    `BJAZ_AZBJ_PART_EXT_HIST` vs `AZBJ_PARTNER_EXTN`, `BJAZ_INTERMEDIARY_HIST` vs
    `BJAZ_INTERMEDIARY`, `BJAZ_CP_ADD_HIST` vs `CP_ADDRESSES`), and the build stages **both**. The
    `_HIST` variant is a redundant history snapshot of the same rows the current table already
    carries — feeding it into a hub/link/sat/stitch just double-loads the same business keys with
    an older `RECORD_SOURCE`, inflating row counts and muddying lineage without adding a single new
    key or attribute. Symptom: a satellite/hub with a `*_HIST`-tagged source alongside its current
    twin, both keyed identically. Fix: **do not build `_HIST` source tables when a non-`_HIST`
    current counterpart exists** — drop the `_HIST` source declaration, its `stg_`/`stg2_` models,
    and strip its entries from every downstream multi-source list, stitch source dict, and
    `src_column_map` (leaving the current-table entry in place). If removing it leaves a
    multi-source satellite with a single remaining source, switch it back to `automate_dv.sat()`
    with a string `source_model` rather than keeping `sat_multi_source` on one source. Before
    dropping, confirm the current twin exists for **every** `_HIST` table (map each
    `..._hist` model name to its de-`hist` counterpart and verify the file is present) — a `_HIST`
    with no current counterpart is a real source and must be kept.
 
## Conventions checklist (per project, confirm before generating)
 
- Hash-key suffix: `_HK` vs `_HKEY` — check the project's existing hubs, don't assume.
- Parent business-key column naming: `PARENT_BK`/`PARENT_NK` vs project-specific naming.
- Satellite file naming: `sat_<name>.sql` (NO source/LOB prefix, e.g. `sat_party` not `sat_partner_party`). The source/LOB is carried only in `RECORD_SOURCE`, never in the model name.
- Namespaced hashing formula: `hash('{CODE}|' || raw_key)`.
- Record-source prefix: every `RECORD_SOURCE` literal (`stg2` stages) and `source_tag` (stitch
  source dicts) must carry the project's source-system prefix (`OPUS_` here — the raw-ingestion
  source system, `!OPUS_<TABLE>` in stages / `OPUS_<TABLE>` in stitch tags). One un-prefixed
  literal breaks record-source lineage silently (defect class #12). Confirm the prefix from the
  project's existing stages and gate that the distinct set of record-source literals all share it.
- `_HIST` vs current source: when a source table exists in both a history (`*_HIST`) and a current
  form, **do not build the `_HIST` table** — it is a redundant snapshot of the same keys the
  current table carries (defect class #13). Map every `_HIST` source to its de-`hist` counterpart,
  confirm the counterpart exists, then skip the `_HIST` source (declaration + `stg_`/`stg2_` models)
  and strip its entries from every downstream multi-source list / stitch dict / `src_column_map`.
  Keep a `_HIST` only if it has no current counterpart.
- Materializations: staging/stitched/stage views, hub/link/satellite incremental tables (or
  whatever the project's `dbt_project.yml` already establishes).
- Null-placeholder convention for absent payload columns in a branch: `cast(null as <type>)`,
  type-matched to the populated branches (hand-written unions only — `sat_multi_source` /
  `ma_sat_multi_source` pad absent columns with `CAST(NULL AS VARCHAR)` automatically).
- Multi-source satellites **only**: use the custom `sat_multi_source` / `ma_sat_multi_source` macros
  with an explicit `src_column_map` and `src_record_source_map`, not a hand-written union view feeding
  `automate_dv.sat()`/`ma_sat()`. Use them **only for satellites fed by two or more sources** — never
  for hubs/links, and not for a genuinely single-source satellite (call `automate_dv.sat()`/`ma_sat()`
  directly there; the single-string `source_model` delegation is a drop-to-one hatch, not the default).
  `sat_multi_source` also offers `src_object_columns` (fold per-source-table values into one
  `OBJECT_AGG` row) and `src_hashdiff_alias` (write the source hashdiff under a shared name).
- Mandatory staging column: `inc_job_updated_at` is present on every source table and must be
  pulled through in every `stg_` model — it is the load/CDC watermark the incremental layer and
  the multi-source satellite macros filter on. No fallback; a `stg_` model without it is a defect.
  **The column name is per-project** — confirm from a sibling LOB's `stg_` files before writing
  new ones. Observed per-project names:
    - `opus_partner_dv_dbt`, `opus_travel_dv_dbt`:   `inc_job_updated_at`
    - `maximus_travel_dv_dbt`:                    `rec_refresh_at`
  Whichever name the project uses, every `stg_` model must select it and every stg2 derived
  column must wire it as the `LOAD_DATETIME` (see next bullet).
- **`LOAD_DATETIME` in every `stg2_*` must reference the project's CDC watermark column, not
  `!CURRENT_TIMESTAMP()`.** `automate_dv.stage()` reads `LOAD_DATETIME` as a derived column; the
  `!` prefix tells `stage()` to insert the string **verbatim**, so `'!CURRENT_TIMESTAMP()'`
  stores the literal text `CURRENT_TIMESTAMP()` as a VARCHAR, not the function result — the
  downstream `src_ldts` filter then has no real timestamp to compare against, and the T-1
  incremental window silently degrades to "load everything each run". Point `LOAD_DATETIME` at
  the project's CDC column instead (no `!` prefix, so `stage()` resolves it as a column
  reference). Observed project settings:
    - `opus_partner_dv_dbt`, `opus_travel_dv_dbt`:   `LOAD_DATETIME: 'INC_JOB_UPDATED_AT'`
    - `maximus_travel_dv_dbt`:                    `LOAD_DATETIME: 'REC_REFRESH_AT'`
  This is the stg2-layer counterpart of the stg1 mandatory-column rule: the two must line up
  (same column flowing through both layers), or the watermark breaks on the join.
- Stitch watermark column: `gg_change_date` here (a CDC timestamp from the replication tool, not
  a business date). Confirm the project's column name and that *every* intended source exposes
  it before configuring `stitch_incremental`.
- Delta window semantics: `>= DATEADD(DAY, -1, CURRENT_DATE())` for key discovery. If the
  requirement is instead "stitch shows only T-1 and older", that's a `<=` cutoff on the attribute
  CTEs — a different thing from the delta filter. Clarify which is meant; they were conflated
  once already.
 
## Generator scripts, not hand-written files, past ~5 branches
 
Any satellite needing more than a handful of near-identical per-column branches (seen up to
~55 branches in one satellite this session) should be generated by a small Python script with
a data table of `(table, column, target_attr, literal/derivation, member_expr)` tuples, not
written by hand file-by-file — faster, and eliminates copy-paste drift across branches.

