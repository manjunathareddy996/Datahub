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

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-K1 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K2 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K3 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K4 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K5 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H3_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H3_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H4_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H4_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-AG1–AG3 | — | — | — | — | — | NA |

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
- No DM-H member plan yet for travel; the DM-H files cover every satellite
  in the project. Trim once a plan is agreed.
