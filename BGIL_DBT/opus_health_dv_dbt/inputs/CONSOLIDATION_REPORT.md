# OPUS Health — consolidated mapping

One mapping covering both OPUS health feeds, built 2026-10-05 by union of the two runs.
Every figure below states its **scope, unit and matcher**; recompute anything you rely on.

## 0. Provenance

| Half | Source artifact | Rows | Tables |
|---|---|---:|---:|
| `opus_health_legacy_v4` | `outputs/consolidation/health_applied_maps_v4.tgz` (md5 `3eee0740edc8a369ee698a67baba6003`), 81 per-table `04.json` | 2,817 | 81 |
| `opus_health_v2` | `OPUS Health/outputs/04_column_map.json` (md5 `e7d97eb63c5147b379383d4fe27792ae`), **CLOSED** | 860 | 34 |
| **consolidated** | `Health Consolidated/outputs/04_column_map.json` (md5 `f4820a70eb822a849be20cff3388a7f1`, 5,145,818 bytes) | **3,677** | **115** |

Model: `OPUS Health/data_7.js`, READ-ONLY, md5 `082b92d7650cf4e192b6e9bb931cdc7e`.

Neither closed run was modified. Digests verified unmoved at build time: OPUS Health
`e7d97eb63c5147b379383d4fe27792ae` (3,218,842 b); Maximus Health V3
`f3f1fd8284b4aac8f10ef216e3dcf87d` (7,325,889 b).

**The legacy half had no merged map.** It existed only as 81 per-table `04.json` inside a
tarball. `04_column_map.legacy_v4_merged.json` is now that half as a single artifact, so the
archive is no longer the only copy.

Every row carries `source_run`. Legacy rows also carry `legacy_no_resolved_key: true`, so the
absence of `resolved_key` on that half reads as an era marker rather than as a defect.

## 1. The union is conflict-free at column grain

    table overlap between the two runs : 0
    duplicate (table, column)          : 0

Scope = all rows of each map; unit = distinct `table_name` / `(table_name, column_name)`;
matcher = exact string. Zero table overlap is what makes this a union rather than a merge —
no column-level adjudication was required or performed.

Outcomes: mapped 2,573 · augmentation_needed 990 · unmapped 85 · needs_reanchor 29.

## 2. Where the two halves DO meet

    shared satellites                             : 48  (legacy-only 94, v2-only 39)
    shared anchors (hubs/links)                    : 15
    (satellite, attribute) written by BOTH runs    : 92
      on a SINGLE-ACTIVE satellite                : 62   (607 columns)
      on a multi-active satellite                 : 30   (338 columns)

Scope = all blocks (`target` **and** `augmentation`), home read across all three spellings
(`satellite` / `best_home_satellite` / `new_satellite`); unit = `(satellite, attribute)`;
matcher = exact. Scoping by `outcome == 'mapped'` would have been wrong — an augmentation row
carries a target and a key exactly like a mapped row.

> **Coincidence warning.** 62 cross-run `(satellite, attribute)` pairs and 62 vault TABLES
> built by both dbt projects are **different units that happen to share a number.** They must
> not be reconciled against each other.

## 3. Stage-9 gate: FAIL — this map is not handoff-ready

    blockers 171 · warn 1316 · info 833

    target_validity            141   100% opus_health_legacy_v4
    handoff_outcome_contract    29   100% opus_health_legacy_v4
    reanchor_escalated           1   global
    -------------------------------------------
    blockers from opus_health_v2   0

**The legacy half has never been through the modern gate.** 0 of its 2,817 rows carry
`resolved_key`; Stage 6 (child keys) and Stage 6.5 (re-anchor) never ran on it. The v2 half
contributes zero blockers — it was gated to PASS at its own closure and still is.

Union-manufactured violations are **0 by construction**: `check_collapse` groups by
`(table, satellite, attribute, instance, child_key)` and table overlap is zero, so the union
cannot create one. Verified by attribution rather than assumed.

Collapse gate on the consolidated map: `status=collapse_found`, 16 single-active fan-in
violations (43 columns), 29 augmentation fan-in groups (150 columns), 8 dangling
`redundant_of`. All attributable to legacy; all pre-existing in the **built** `health_dv_dbt`.

Two process notes, both recorded traps hit again on this run:
* `check_crossrun_vocabulary` reported 5 blockers and still **exited 0** — it reports in the
  body without moving `$?`.
* `check_collapse` showed `EXIT=0` through a pipe and `EXIT=1` unpiped. Read exit codes unpiped.

## 4. Findings that bear on the consolidated BUILD

**R8 — 62 single-active `(satellite, attribute)` pairs have writers in both halves (607
columns).** Largest: `SAT_PARTY_IDENTITY."Party Full Name"` 95/10,
`SAT_POLICY_HEADER."Risk Inception Date"` 27/1, `SAT_PARTY_IDENTITY."Date Of Birth"` 25/2,
`SAT_COMMON_ADDRESS."City"` 19/4. In two separate vaults this is invisible. In ONE vault it is
one row per hub key with two independent writers and two HASHDIFFs. Needs a per-feed satellite
split or a record-source discriminator — a build-structure decision. **No gate on the mapping
side can see it**, because every collapse check groups by table and table overlap is zero.

**R6 — child-key vocabulary divergence on two shared multi-active satellites.** Settled by the
model, not by style preference:

| satellite | model `childkey` | legacy writes | v2 writes | conformant |
|---|---|---|---|---|
| `SAT_POLICY_DISCOUNT_LOADING_APPLIED` | `Item Code` | `Family Discount`, `Underwriting Loading`, `Special Discount` | `DISCOUNT_FAMILY`, `UW_LOADING`, `SPECIAL_DISCOUNT` | **v2** — the model asks for a *Code* |
| `SAT_COMMON_CONTACT` | `Contact Point Type + Contact Priority Order` | `email`, `mobile`, `landline`, `alt-email` | `EMAIL`, `MOBILE`, `LANDLINE`, `EMAIL_CORPORATE` | **v2** |

A child key is a MODEL property, so divergence across feeds of one satellite is a defect, never
a legitimate source difference. Unconsolidated, one discount type becomes two child rows.

**R7 — `SAT_COMMON_CONTACT` is under-keyed in legacy.** The model declares a TWO-leg child key.
Legacy resolves ONE leg on all 89 blocks; v2 resolves both on 4. Every legacy contact of one
type collides on the missing leg — `child_key_legs_complete` realised in a shipped build.

**R4 — legacy hub-key forms are not recoverable from the mapping.** No legacy row carries
`resolved_key`, so its key expressions exist only in `health_dv_dbt`'s emitted SQL. For the 15
shared anchors — `HUB_PARTY` above all — the consolidated build needs one key expression per
hub, and **the build is the authority, not this map.** A map-reading check can only confirm
that the map says what it meant to say. Routed to the builder.

## 5. Reader defects committed while measuring this, recorded

* An exact-match scan of v2 child-key values returned a **uniform zero**. v2 writes child keys
  as named-leg templates (`Contact Point Type = EMAIL`), which the cross-run gate normalises and
  my matcher did not. A uniform zero is evidence about the reader, not the data — and it would
  have read as "v2 does not key this satellite", the opposite of the truth.
* Attribution of the 8 `dangling_redundant_of` entries came back `?` for all 8 — those entries
  do not carry the field my lookup keyed on. **Not reported**, rather than reported as unknown
  defects of legacy.
* The summary carried into this run said the legacy half was **129 tables**. Measured, the v4
  archive holds **81**. The 129 is not reproduced here and is not used; it may belong to a
  different unit (source tables before classification) but that was not established.

## 6. Artifacts

| File | Purpose |
|---|---|
| `04_column_map.json` | the consolidated map, 3,677 rows, `source_run` on every row |
| `04_column_map.legacy_v4_merged.json` | legacy half as one artifact for the first time |
| `03_column_anchor_mapping.json` | merged Stage-3 feed; 3,677 `required-for-mapping` == 3,677 map rows (funnel exact) |
| `09_validation_report.json` + `VALIDATION_REPORT_OPUS_Health_Consolidated.md` | Stage-9 gate, 2,320 findings |
| `crossrun_vocabulary.json` | cross-run child-key divergence, 5 blockers / 10 synonym candidates |
| `CROSSRUN_SHARED_ATTRIBUTES.json` | the 92 cross-run `(satellite, attribute)` pairs |
| `OPUS_Health_Consolidated_Mapping.xlsx` | 7-sheet workbook (md5 `b7eb326351e1d397642b837e1e7cfbab`) |

The workbook is **not** the standard 8-sheet handoff book. `build_deliverables.py` refuses to
emit unless the Stage-9 gate PASSed, and it has not — emitting the standard book anyway would
present a failed map in the shape of a passed one. Sheet 1 states the gate result; sheet 7 is
the remediation backlog R1–R9.

## 7. Remediation backlog (mapper work, not yet done)

| ID | Sev | Half | Needs |
|---|---|---|---|
| R1 | BLOCKER | legacy | 141 rows with `anchor != parent(satellite)`, mostly `BJAZ_WS_FAMILY_DTLS_BANDHAN` `MEMBER1..8` |
| R2 | BLOCKER | legacy | 29 `needs_reanchor` rows, all reference masters (ICD/PCS/DIAGNOSIS/DISEASE/ROOM/CHARGE) — likely `REF_*` model gaps |
| R3 | BLOCKER | — | `modeler_feedback.json` absent; every surviving `needs_reanchor` needs a written escalation |
| R4 | WARN | legacy | 316 `key_provenance`; `resolved_key` absent on all 2,817 rows → routed to builder |
| R5 | WARN | legacy | 644 unresolved child keys. **Until Stage 6 runs, the legacy collapse count is a LOWER BOUND, not a clean bill** |
| R6 | BLOCKER-eq | both | normalise legacy child-key vocabulary to the model-conformant codes |
| R7 | BLOCKER-eq | legacy | resolve the second leg of `SAT_COMMON_CONTACT`'s child key |
| R8 | DESIGN | both | 62 cross-run single-active writers — build-structure decision |
| R9 | INFO | legacy | 16 + 29 + 8 collapse findings, pre-existing in the built project |
