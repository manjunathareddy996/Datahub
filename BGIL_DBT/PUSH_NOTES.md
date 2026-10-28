# Push Notes

Running log of pushes to this repo. Newest first.

---

## 2026-10-28 — Round-2 single-source satellite collapse (travel)

**Target:** `main` (`ede6885`)
**What:** 155 single-item `source_model` YAML lists collapsed to scalar form across both
travel projects. These were newly-visible files in the merged tree (mostly augmented
satellites that came along with the restoration push). Multi-item lists untouched.
Count by project: `opus_travel_dv_dbt` 3, `maximus_travel_v2_dv_dbt` 152.

---

## 2026-10-28 — Restore maximus_travel_v2_dv_dbt files lost in merge

**Target:** `main` (`fae3e0a`)
**What:** 543 files that were in the feature tip (`d3e2e98`) but got accidentally
removed during the merge resolution were restored. The merge resolution step ran
`git rm` on every DD (deleted-by-both) entry; that confirmed main's deletions of
files the feature side wanted to keep. Affected sub-trees:

- `dbt_project.yml`, `packages.yml`, `profiles.yml`
- `macros/` (8 files incl. `sat_multi_source.sql`, `ma_sat_multi_source.sql`)
- `models/staging/` (115 stg1 layer-1 casts + `_mtv2_sources.yml`)
- `dbt_packages/` (350 vendored package files for dbt_utils + automate_dv)
- `generators/`, `build_artifacts/`, `build_profile*.json`, `BUILDER_ASKS_*.md`

Restored verbatim from `d3e2e98` with `git checkout d3e2e98 -- <paths>`.

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
