---
name: dv2-automatedv-dbt-builder
description: Build or extend a Data Vault 2.0 dbt project (AutomateDV/Datavault-UK package) on Snowflake from a source-to-target mapping workbook and a canonical data_N.js model. Covers hubs, links, satellites (incl. multi-active), stitch views, staging casts, augmented (build-side) tracks, and the mapper/modeler correspondence loop. Use when asked to build a new LOB's dbt vault, sync an existing one against a refreshed model/mapping, fix a satellite's child key, or investigate a "collapsed rows" / "data loss" report in a hub- or satellite-backed table.
---
 
# Data Vault 2.0 dbt builder (AutomateDV)
 
## When to use this skill
 
- Standing up a new LOB's dbt project against a canonical `data_N.js` model and a
  `<LOB>_SourceToModel_Mapping.xlsx` workbook.
- Applying a mapper/modeler reply or a model re-baseline (`data_6` → `data_7`, etc.) to an
  existing build.
- Diagnosing "this satellite is losing rows" or "two entities collapsed onto one" reports —
  usually a missing or wrong multi-active child key.
- Auditing an existing `sat()`/`ma_sat()` for the same defect class before it's reported.
 
Not for: one-off SQL edits unrelated to the vault structure, non-AutomateDV dbt projects,
star-schema/mart work (that's a different skill).
 
## Inputs you need before starting
 
1. **Canonical model** — `data_N.js`, parsed once into JSON (`sats`/`hubs`/`links`/`refs`
   arrays with `code`/`parent`/`childkey`/`attrs` fields) for repeated querying. Always diff
   against the previous `data_*.js` before trusting a "current model" claim — prose summaries
   have been wrong about the extent of a model change more than once.
2. **Mapping workbook** — `<LOB>_SourceToModel_Mapping.xlsx`, sheets: Summary, Source→Target,
   Target→Source, Augmentation (modeler), Review Flags. Extract Source→Target to JSON once
   (table/column/domain/outcome/model-target/key-grain-join/instance-child/confidence/
   rationale columns) rather than re-reading the workbook every query.
3. **Source schema** — a cached full-schema snapshot (owner/table/column/type/length) if
   available, so column-type and key-candidate questions can be resolved directly instead of
   round-tripping to the mapper.
4. **Existing build** (if syncing, not scaffolding) — the LOB's `dbt_project.yml`,
   `models/automate_dv/standard/{staging,stitched,hubs,links,satellites}`, and its README.
 
## Workflow
 
### 1. Scaffold (new LOB only)
`dbt_project.yml` + `packages.yml` (dbt_utils, automate_dv) → per-table staging casts
(`models/staging/<lob>/stg_<lob>__<table>.sql`, 1:1 trimmed/typed casts, key columns always
cast to canonical trimmed varchar for stable hashing regardless of native type).
 
### 2. Resolve hub/link/satellite keys from the mapping
For every hub/link, find its business key: an explicit `KEY:` row in the mapping, else the
`Primary_Key` field in the source-system reference file, else a column verified against real
sample data (never trust a plausible-looking composite key from schema shape alone — see
Known Defect Classes #2). For every satellite, get its parent and **child key** from the
canonical model — a non-empty child key means multi-active (`ma_sat()`), empty means
single-active (`sat()`). Get this right before writing any SQL; getting it wrong is the #1
recurring defect (see below).
 
### 3. Build the standard-model track
- `stg2_hub_<table>__<hub>.sql` / `stg2_sat_<table>__<sat>.sql` — `automate_dv.stage()` calls,
  `PARENT_BK`/`PARENT_NK` derived columns, `hash('{HUB_OR_LINK_CODE}|' || raw_key)` via the
  `*_NK` helper — **never** a bare `hash(raw_key)` (breaks cross-LOB/cross-table key
  namespacing).
- `stitch_<name>.sql` only for attribute-joined satellites (FULL OUTER JOIN + COALESCE across
  multiple tables sharing one key) — union-only tables skip the stitch and feed `hub()`/
  `link()`/`sat()` directly from their per-table stage.
- `hub_<name>.sql` / `link_<name>.sql` / `sat_<name>.sql` / union of per-branch stage models
  via `automate_dv.hub()`/`link()`/`sat()`/`ma_sat()`.
- A hub *can* have multiple contributing branches with entirely different key formulas from
  different source systems — that's normal (`HUB_PARTY` fed by demographics, intermediaries,
  claim-suppliers, etc. all differently). What's *not* fine is one satellite silently
  degenerating to a coarser hub than its canonical parent when a real per-table key exists —
  always check for a real key before falling back (see Known Defect Classes #4).
 
### 4. Multi-active satellites: get the child key right
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
3. **Semantic key cross-check** (do this manually when a satellite was just repointed to a
   different/new hub) — diff the `PARENT_BK` expression string between the hub's stage file(s)
   and every satellite branch that's supposed to key on it. Structural checks #1/#2 don't catch
   a hub and satellite computing *different* formulas that both happen to reference real
   columns — that only shows up as silently orphaned rows at query time.
 
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
 
## Conventions checklist (per project, confirm before generating)
 
- Hash-key suffix: `_HK` vs `_HKEY` — check the project's existing hubs, don't assume.
- Parent business-key column naming: `PARENT_BK`/`PARENT_NK` vs project-specific naming.
- Namespaced hashing formula: `hash('{CODE}|' || raw_key)`.
- Materializations: staging/stitched/stage views, hub/link/satellite incremental tables (or
  whatever the project's `dbt_project.yml` already establishes).
- Null-placeholder convention for absent payload columns in a branch: `cast(null as <type>)`,
  type-matched to the populated branches.
 
## Generator scripts, not hand-written files, past ~5 branches
 
Any satellite needing more than a handful of near-identical per-column branches (seen up to
~55 branches in one satellite this session) should be generated by a small Python script with
a data table of `(table, column, target_attr, literal/derivation, member_expr)` tuples, not
written by hand file-by-file — faster, and eliminates copy-paste drift across branches.