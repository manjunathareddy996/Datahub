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
  the chained join (see "Incremental stitch via macro" below).
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
 
### 4b. Incremental stitch via macro (`stitch_incremental`)

A hand-written stitch does a chained `FULL OUTER JOIN` over every contributing table at full
volume on every evaluation. With N tables of M rows each that is an M^N-shaped cross-product
even when only a handful of source rows changed. Use `macros/stitch_incremental.sql` to generate
a T-1 delta-driven equivalent instead. It produces **bit-identical output** to the hand-written
stitch for the affected keys — the coalesce priority ladder is unchanged, only the row
population shrinks.

**Two-phase logic the macro emits:**
1. `affected_keys` — `UNION` of `DISTINCT key_column` from every source where
   `ldts_column >= DATEADD(DAY, -1, CURRENT_DATE())`. Small, partition-pruned scans.
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
 
## Conventions checklist (per project, confirm before generating)
 
- Hash-key suffix: `_HK` vs `_HKEY` — check the project's existing hubs, don't assume.
- Parent business-key column naming: `PARENT_BK`/`PARENT_NK` vs project-specific naming.
- Namespaced hashing formula: `hash('{CODE}|' || raw_key)`.
- Materializations: staging/stitched/stage views, hub/link/satellite incremental tables (or
  whatever the project's `dbt_project.yml` already establishes).
- Null-placeholder convention for absent payload columns in a branch: `cast(null as <type>)`,
  type-matched to the populated branches.
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