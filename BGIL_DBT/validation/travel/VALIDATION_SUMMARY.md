# Validation Results Summary (Travel LOB)

Template for the Travel LOB validation suite. Mirrors the partner summary
shape; results are **pending** until each per-check `.docx` has its
`Result (Pass / Fail / NA)` fields filled in by the test runs.

Classification: any verdict containing "fail" (including notes like
`fail(due to source issue)`) counts as **fail**; `na` as **na**; `pass`
as **pass**; empty as **untested**.

File status rule: **FAIL** if any section failed; **PASS** if some
passed and none failed; **PENDING** if nothing recorded.

---

## DM-A — Attribute / payload checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-A1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-A2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |

Category total: pending.

---

## DM-H — History checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-H1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H3_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H3_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H4_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-H4_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |

Category total: pending.

---

## DM-K — Key checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-K1 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K2 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K3 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K4 | tbd | 0 | 0 | 0 | tbd | pending |
| DM-K5 | tbd | 0 | 0 | 0 | tbd | pending |

Category total: pending.

---

## DM-R — Referential / relationship checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-R1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-R2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |

Category total: pending.

---

## DM-T — Transformation / type checks

| File | Sections | pass | fail | na | untested | Status |
|------|---------:|-----:|-----:|---:|---------:|:------:|
| DM-T1_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T1_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T2_OPUS | tbd | 0 | 0 | 0 | tbd | pending |
| DM-T2_MAXIMUS | tbd | 0 | 0 | 0 | tbd | pending |

Category total: pending.

---

## Grand totals

| Category | pass | fail | na | untested | Status |
|----------|-----:|-----:|---:|---------:|:------:|
| DM-A | 0 | 0 | 0 | tbd | pending |
| DM-H | 0 | 0 | 0 | tbd | pending |
| DM-K | 0 | 0 | 0 | tbd | pending |
| DM-R | 0 | 0 | 0 | tbd | pending |
| DM-T | 0 | 0 | 0 | tbd | pending |
| **All** | 0 | 0 | 0 | **tbd** | **pending** |

Notes
- Travel LOB first-cut: validation SQL + DOCX are regenerable from
  `BGIL_DBT/validation/tools/gen_dm_{k,a,h,r,t}_travel.py`. Results
  (Pass / Fail / NA / counts) are filled in per section once each query
  has been executed against the vault.
- Shared vault: travel row scopes use the RECORD_SOURCE value set parsed
  from each project's own feeds (not the MAXIMUS_ / OPUS_ prefix, which
  the partner build also writes).
- First-cut limitations carry a short note on the DM-K / DM-A sections:
  stg2 columns that resolve via a `resolved_mtv2__` walk column or a
  plain-join (non-macro) stitch are reported as unresolved rather than
  inlined into the sampled queries.
- No DM-H member plan yet for travel; the DM-H files cover every
  satellite in the project. Trim once a plan is agreed.
