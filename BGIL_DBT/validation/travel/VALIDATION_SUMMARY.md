# Validation Results Summary (Travel LOB)

Build-readiness dashboard for the Travel LOB validation suite. Counts are
taken from the generated SQL under `BGIL_DBT/validation/travel/DM-*/*.sql`
(produced by `BGIL_DBT/validation/tools/gen_dm_{k,a,h,r,t}_travel.py`).
Per-section results (Pass / Fail / NA) are recorded in each `.docx` once
the queries have been executed against the vault.

Scope (model files under `models/raw_vault/`):
- OPUS Travel — 14 hubs, 0 links, 45 satellites (33 standard + 12 augmented)
- MAXIMUS Travel — 15 hubs, 4 links, 209 satellites (103 standard + 106 augmented)
- Combined — **29 hubs, 4 links, 254 satellites** plus 2 project summary tables
  (287 vault objects, 289 tables for DM-T).

---

## Build readiness

| Check     | Objects to run                                        | Queries to run | SQL lines | Status         |
|-----------|-------------------------------------------------------|---------------:|----------:|:---------------|
| DM-K1     | 29 hubs (15 MTV2 + 14 OPUS)                           |             29 |     2,836 | Ready to build |
| DM-K2     | 29 hubs                                               |             29 |     2,282 | Ready to build |
| DM-K3     | 29 hubs + null/blank sweep                            |             59 |     2,992 | Ready to build |
| DM-K4     | 18 shared hubs + 1 cross-hub                          |             19 |       337 | Ready to build |
| DM-K5     | 29 hubs                                               |             29 |     2,584 | Ready to build |
| DM-A1     | 254 satellites (209 MTV2 + 45 OPUS)                   |            260 |    69,254 | Ready to build |
| DM-A2     | 254 satellites                                        |            260 |    43,885 | Ready to build |
| DM-H1     | 254 satellites                                        |            224 |     6,234 | Ready to build |
| DM-H2     | 254 satellites                                        |            258 |     8,989 | Ready to build |
| DM-H3     | 254 satellites                                        |            270 |     8,122 | Ready to build |
| DM-H4     | 254 satellites                                        |            256 |    45,198 | Ready to build |
| DM-R1     | 254 satellites                                        |            263 |     9,828 | Ready to build |
| DM-R2     | 4 links (MTV2 only; OPUS has none)                    |             16 |     1,440 | Ready to build |
| DM-T1     | 289 tables (29 hubs + 4 links + 254 sats + 2 summary) |            289 |    12,843 | Ready to build |
| DM-T2     | 289 tables                                            |            289 |     4,907 | Ready to build |
| DM-AG1–AG3| —                                                     |              — |         — | NA             |
| **Total** | **29 hubs, 4 links, 254 satellites**                  |      **2,550** | **221,731** | **15 of 18 ready to build** |

---

## Result rollup — pending

Per-section results from each `.docx` will populate here once the queries
have been executed. Classification: any verdict containing "fail" (including
notes like `fail(due to source issue)`) counts as **fail**; `na` as **na**;
`pass` as **pass**; empty as **untested**. File status rule: **FAIL** if any
section failed; **PASS** if some passed and none failed; **PENDING** if
nothing recorded.

| File | Sections | M1 | M2 | M3 | pass | fail | na | untested | Status |
|------|---------:|---:|---:|---:|-----:|-----:|---:|---------:|:------:|
| DM-K1 | 29 | 10 | 10 | 9 | 0 | 0 | 0 | 29 | pending |
| DM-K2 | 29 | 10 | 10 | 9 | 0 | 0 | 0 | 29 | pending |
| DM-K3 | 30 | 10 | 10 | 10 | 0 | 0 | 0 | 30 | pending |
| DM-K4 | 19 | 7 | 6 | 6 | 0 | 0 | 0 | 19 | pending |
| DM-K5 | 29 | 10 | 10 | 9 | 0 | 0 | 0 | 29 | pending |
| DM-A1_OPUS | 46 | 16 | 15 | 15 | 0 | 0 | 0 | 46 | pending |
| DM-A1_MAXIMUS | 210 | 70 | 70 | 70 | 0 | 0 | 0 | 210 | pending |
| DM-A2_OPUS | 45 | 15 | 15 | 15 | 0 | 0 | 0 | 45 | pending |
| DM-A2_MAXIMUS | 209 | 70 | 70 | 69 | 0 | 0 | 0 | 209 | pending |
| DM-H1_OPUS | 48 | 16 | 16 | 16 | 0 | 0 | 0 | 48 | pending |
| DM-H1_MAXIMUS | 212 | 71 | 71 | 70 | 0 | 0 | 0 | 212 | pending |
| DM-H2_OPUS | 46 | 16 | 15 | 15 | 0 | 0 | 0 | 46 | pending |
| DM-H2_MAXIMUS | 210 | 70 | 70 | 70 | 0 | 0 | 0 | 210 | pending |
| DM-H3_OPUS | 47 | 16 | 16 | 15 | 0 | 0 | 0 | 47 | pending |
| DM-H3_MAXIMUS | 211 | 71 | 70 | 70 | 0 | 0 | 0 | 211 | pending |
| DM-H4_OPUS | 45 | 15 | 15 | 15 | 0 | 0 | 0 | 45 | pending |
| DM-H4_MAXIMUS | 209 | 70 | 70 | 69 | 0 | 0 | 0 | 209 | pending |
| DM-R1_OPUS | 46 | 16 | 15 | 15 | 0 | 0 | 0 | 46 | pending |
| DM-R1_MAXIMUS | 210 | 70 | 70 | 70 | 0 | 0 | 0 | 210 | pending |
| DM-R2_OPUS | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | pending |
| DM-R2_MAXIMUS | 12 | 4 | 4 | 4 | 0 | 0 | 0 | 12 | pending |
| DM-T1_OPUS | 60 | 20 | 20 | 20 | 0 | 0 | 0 | 60 | pending |
| DM-T1_MAXIMUS | 229 | 77 | 76 | 76 | 0 | 0 | 0 | 229 | pending |
| DM-T2_OPUS | 60 | 20 | 20 | 20 | 0 | 0 | 0 | 60 | pending |
| DM-T2_MAXIMUS | 229 | 77 | 76 | 76 | 0 | 0 | 0 | 229 | pending |
| DM-AG1–AG3 | — | — | — | — | — | — | — | — | NA |

---

Notes
- Validation SQL + DOCX are regenerable from
  `BGIL_DBT/validation/tools/gen_dm_{k,a,h,r,t}_travel.py`. The DM-AG family
  (aggregate / cross-check rollups) is not yet planned for travel — shown as
  NA.
- Shared vault: travel row scopes use the RECORD_SOURCE value set parsed
  from each project's own feeds (not the MAXIMUS_ / OPUS_ prefix, which the
  partner build also writes).
- First-cut limitations carry a short note on the DM-K / DM-A sections:
  stg2 columns that resolve via a `resolved_mt__` walk column or a
  plain-join (non-macro) stitch are reported as unresolved rather than
  inlined into the sampled queries.
- Sections in every `DM-*/*.sql` and `DM-*/*.docx` are split into contiguous
  thirds M1 / M2 / M3 by `BGIL_DBT/validation/tools/tag_travel_members.py`.
  See the member split table below.

---

## Member split (M1 / M2 / M3)

Each file's sections are allocated to three team members in contiguous
thirds (M1 first, M2 next, M3 last). Run
`python3 BGIL_DBT/validation/tools/tag_travel_members.py` to (re)apply
tags idempotently.

| File | Sections | M1 | M2 | M3 |
|------|---------:|---:|---:|---:|
| DM-A/DM-A1_MAXIMUS | 210 | 70 | 70 | 70 |
| DM-A/DM-A1_OPUS | 46 | 16 | 15 | 15 |
| DM-A/DM-A2_MAXIMUS | 209 | 70 | 70 | 69 |
| DM-A/DM-A2_OPUS | 45 | 15 | 15 | 15 |
| DM-H/DM-H1_MAXIMUS | 212 | 71 | 71 | 70 |
| DM-H/DM-H1_OPUS | 48 | 16 | 16 | 16 |
| DM-H/DM-H2_MAXIMUS | 210 | 70 | 70 | 70 |
| DM-H/DM-H2_OPUS | 46 | 16 | 15 | 15 |
| DM-H/DM-H3_MAXIMUS | 211 | 71 | 70 | 70 |
| DM-H/DM-H3_OPUS | 47 | 16 | 16 | 15 |
| DM-H/DM-H4_MAXIMUS | 209 | 70 | 70 | 69 |
| DM-H/DM-H4_OPUS | 45 | 15 | 15 | 15 |
| DM-K/DM-K1 | 29 | 10 | 10 | 9 |
| DM-K/DM-K2 | 29 | 10 | 10 | 9 |
| DM-K/DM-K3 | 30 | 10 | 10 | 10 |
| DM-K/DM-K4 | 19 | 7 | 6 | 6 |
| DM-K/DM-K5 | 29 | 10 | 10 | 9 |
| DM-R/DM-R1_MAXIMUS | 210 | 70 | 70 | 70 |
| DM-R/DM-R1_OPUS | 46 | 16 | 15 | 15 |
| DM-R/DM-R2_MAXIMUS | 12 | 4 | 4 | 4 |
| DM-R/DM-R2_OPUS | 1 | 1 | 0 | 0 |
| DM-T/DM-T1_MAXIMUS | 229 | 77 | 76 | 76 |
| DM-T/DM-T1_OPUS | 60 | 20 | 20 | 20 |
| DM-T/DM-T2_MAXIMUS | 229 | 77 | 76 | 76 |
| DM-T/DM-T2_OPUS | 60 | 20 | 20 | 20 |
