# Validation Results Summary

Consolidated roll-up of the per-section results recorded in each check `.docx`.
Results are read from each section's `Result (Pass / Fail / NA)` field (and, for files
that use the single summary table, from its `Result` column). Counts are taken directly
from the docx (not re-run here).

Classification: any verdict containing "fail" (including notes like
`fail(due to source issue)`) counts as **fail**; `na` as **na**; `pass` as **pass**;
empty as **untested**.

File status rule: **FAIL** if any section failed; **PASS** if some passed and none
failed; **PENDING** if nothing recorded.

---

## DM-A — Attribute / payload checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-A1_OPUS | 60 | 41 | 5 | 14 | 0 | FAIL |
| DM-A1_MAXIMUS | 99 | 26 | 63 | 10 | 0 | FAIL |
| DM-A2_OPUS | 59 | 50 | 9 | 0 | 0 | FAIL |
| DM-A2_MAXIMUS | 98 | 27 | 51 | 7 | 13 | FAIL |

Category total: 144 pass · 128 fail · 31 na · 13 untested.

---

## DM-H — History checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-H1_OPUS | 35 | 19 | 3 | 0 | 13 | FAIL |
| DM-H1_MAXIMUS | 29 | 4 | 6 | 0 | 19 | FAIL |
| DM-H2_OPUS | 33 | 20 | 11 | 0 | 2 | FAIL |
| DM-H2_MAXIMUS | 27 | 9 | 10 | 0 | 8 | FAIL |
| DM-H3_OPUS | 7 | 3 | 2 | 0 | 2 | FAIL |
| DM-H3_MAXIMUS | 7 | 0 | 0 | 0 | 7 | PENDING |
| DM-H4_OPUS | 32 | 13 | 6 | 0 | 13 | FAIL |
| DM-H4_MAXIMUS | 26 | 10 | 9 | 0 | 7 | FAIL |

Category total: 78 pass · 47 fail · 0 na · 71 untested.

---

## DM-R — Referential / relationship checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-R1_OPUS | 60 | 35 | 21 | 3 | 1 | FAIL |
| DM-R1_MAXIMUS | 99 | 20 | 77 | 0 | 2 | FAIL |
| DM-R2_OPUS | 9 | 4 | 5 | 0 | 0 | FAIL |
| DM-R2_MAXIMUS | 9 | 2 | 6 | 0 | 1 | FAIL |

Category total: 61 pass · 109 fail · 3 na · 4 untested.

---

## DM-T — Transformation / type checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-T1_OPUS | 74 | 46 | 12 | 0 | 16 | FAIL |
| DM-T1_MAXIMUS | 112 | 38 | 63 | 0 | 11 | FAIL |
| DM-T2_OPUS | 74 | 45 | 5 | 0 | 24 | FAIL |
| DM-T2_MAXIMUS | 112 | 37 | 58 | 0 | 17 | FAIL |

Category total: 166 pass · 138 fail · 0 na · 68 untested.

---

## Grand totals

| Category | pass | fail | na | untested | Status |
|----------|-----:|-----:|---:|---------:|:------:|
| DM-A | 144 | 128 | 31 | 13 | FAIL |
| DM-H | 78 | 47 | 0 | 71 | FAIL |
| DM-R | 61 | 109 | 3 | 4 | FAIL |
| DM-T | 166 | 138 | 0 | 68 | FAIL |
| **All** | **449** | **422** | **34** | **156** | **FAIL** |

Notes
- Many failures carry a recorded cause: `fail(due to source issue)`, `fail(due to
  source mapping)`, `fail(due to source grain)`, `fail(due to source null)`. A large
  share of DM-R/DM-T MAXIMUS failures are attributed to source-side issues.
- DM-H3_MAXIMUS is the only file with no results recorded yet (PENDING).
- MAXIMUS consistently shows more failures than OPUS across every category.
