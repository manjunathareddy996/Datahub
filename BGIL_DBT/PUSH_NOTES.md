# Push Notes

Running log of pushes to this repo. Newest first.

---

## 2026-10-28 — Merge feature/collapse-single-source-model-travel-sats into main

**Target:** `main` (merge from `feature/collapse-single-source-model-travel-sats`)
**Resolution:** feature wins on all conflicts (`-X theirs`); rename/rename conflicts
resolved in feature's favor (kept `maximus_travel_v2_dv_dbt/` project directory and
`raw_vault/standard/` internal path; dropped main's parallel `maximus_travel_dv_dbt/`
rename target).

**Feature branch (now deleted) carried five commits:**

1. `ec08591` — collapse single-item `source_model` lists to scalar strings across both
   travel dbt projects (112 satellite files).
2. `e5993cb` — prefix all 566 `maximus_travel_v2` RECORD_SOURCE literals with `MAXIMUS_`
   (283 stg2 derived_columns + 283 unpivot/aug inline literals; `{{ source() }}` refs
   and comment lines left untouched).
3. `8d736ac` — stg2 `LOAD_DATETIME` wired to the project's CDC watermark column instead
   of `'!CURRENT_TIMESTAMP()'`:
     - opus_travel: `'INC_JOB_UPDATED_AT'` (226 files)
     - maximus_travel_v2: `'REC_REFRESH_AT'` (324 files)
   Also added the per-project convention to `utils/skill.md` Segment 2.
4. `4799ac0` — content update per skill (travel dbt).
5. `d3e2e98` — fix opus_travel aug stage() PARENT_BK YAML quoting (10 files; broken
   single-quote nesting around `|memberN` was returning Undefined from `fromyaml` and
   crashing `ref()`).

**Post-merge actions:**
- Pushed `main` with the merge commit.
- Deleted `feature/collapse-single-source-model-travel-sats` locally and on origin.

---
