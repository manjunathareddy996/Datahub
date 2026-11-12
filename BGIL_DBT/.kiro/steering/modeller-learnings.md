---
inclusion: always
---
# Modeller Learnings (living memory)

How this file works:
- Every correction, preference or convention the user teaches goes here as a short, dated rule.
- Read it before any modelling work (hubs, links, sats, stg1/stg2, augmented, quarantine).
- Rules here override `utils/skill.md` if they conflict. Note the conflict in the entry.
- Keep entries specific: rule, why, and an example file when known.

## Standing rules
- dbt is not installed locally. Verify by inspection, not `dbt parse` or `dbt run`.
- Sibling LOB projects (maximus_*, opus_*) are the reference for conventions. Check a sibling before assuming a default.
- Do not guess conventions: hash-key suffix, record-source prefix and folder layout come from a sibling LOB.
- Never read or echo values from `.env` or `profiles.yml`. Refer to keys by name.

## Learned from user (newest first)
<!-- Format: - [YYYY-MM-DD] Rule. Why: reason. Example: path -->
- [2026-11-12] Validation SQL (validation/<lob>/DM-*) is GENERATED. Fix the generator in validation/tools/, regenerate, never hand-edit the .sql/.docx. Travel generators: gen_dm_{a,h,k,r,t}_travel.py wrap the partner gen_dm_*.py by monkey-patching.
- [2026-11-12] DM-H is trimmed, not full: 4 sats per macro path for H1/H2/H4, ONE per macro for H3. Partner selection lives in gen_dm_h.py SELECTION; travel in gen_dm_h_travel.py SELECTION_PATHS / H3_PATHS. Pick only sats where H1 static check is Implemented AND STEP 2/3/4 exist. Mix standard + augmented.
- [2026-11-12] DM-H1 per-sat pattern (partner): STEP 1 HASHDIFF integrity, STEP 2 CDC BEFORE capture, STEP 3 map hkey to RAW business key, STEP 4 forced-change UPDATE, STEP 5 dbt run, STEP 6 AFTER capture, STEP 7 per-sat result. Travel must use the same pattern (shared h1_section in gen_dm_h.py).
- [2026-11-12] Maximus travel macros: only automate_dv.sat and automate_dv.ma_sat (no sat_multi_source). Opus travel: automate_dv.sat, sat_multi_source, ma_sat_multi_source. Opus travel DM-H is not trimmed yet.
- [2026-11-12] Travel ma_sat HASHDIFF hashes the child key (src_cdk) plus payload. Child-key columns are stored on the sat, so they count as recomputable (fixed in gen_dm_h.h1a). Do not flag them as "not stored".
- [2026-11-12] Maximus travel stg2s read resolved_mt__ views whose hkey uses walk tokens (w0_policy_number). Any generated query that rebuilds hkey must alias RAW as b and left-join the parent chain via AT._walk_join_sql (done for STEP 2 and, via bk_map_query_travel, STEP 3).
- [2026-11-12] Travel DM-H scope: ONLY DM-H1 and DM-H4 are trimmed/regenerated. Do NOT touch DM-H2 or DM-H3 unless asked (gen_dm_h_travel.py ACTIVE_CHECKS). Ask whether a task covers H2/H3 before regenerating them.
- [2026-11-12] validation/rca/test = user-pasted RCA results table (project, sat, status, pass/fail/na, remark). A selected H1/H4 sat marked fail/na there must be replaced by a same-macro sat that is not failing. gen_dm_h_travel.rca_failed() reads it and excludes failed sats from alternates; swap in SELECTION_PATHS. Blank result = not run, not a failure. First swap: PARTY_CONTACT_ADDRESS_LINK, POLICY_COVERAGE_SCHEDULE -> CLAIM_BENEFIT_HEAD, POLICY_DISCOUNT_LOADING_APPLIED.
- [2026-11-12] Opus travel H1/H4 trimmed too (4 per macro: automate_dv.sat, sat_multi_source, ma_sat_multi_source = 12 sats). Pick sats with the fewest columns the generator could not trace to RAW ("could not be traced ... first-cut" notes) so CDC evidence is complete; alternates are ranked the same way. Row-count files: DM-H_ROWCOUNT_CHECK.sql (Maximus), DM-H_ROWCOUNT_CHECK_OPUS.sql. rca_failed() is keyed (project, sat).
- [2026-11-12] Rule: "4 per macro, but if a macro has fewer, keep what exists". Opus travel stitch path has only 1 sat (SAT_RISK_PERSON_TRAVEL via plain-join stitch_risk_person_travel_trip_attrs; stitch_incremental macro exists but no Opus travel model calls it). Opus travel DM-H = 4+4+4+1 = 13 sats.
- [2026-11-12] Run generators one at a time. python3 validation/tools/gen_dm_h_travel.py MAXIMUS regenerates only that project. gen_dm_h.py (partner) currently fails in parse_stg on the current partner models (pre-existing).
- [2026-11-12] Open concern: partner STEP 4 emits UPDATE on BAGIC_PROD_MIRROR_DB.MAXI_RAW (prod mirror) while the procedure text says never modify it. Travel copies this. Confirm with user before anyone runs it.
