# Mapper questions — Travel LOB build

**Status: round 1, superseded in part.** The mapper replied in `MAPPER_REPLIES_TRAVEL.md` and
most items below are now resolved — see `MAPPER_FOLLOWUP_ROUND2_TRAVEL.md` for what was
implemented, what's still genuinely open (the trip-attribute cross-table fan-out, the 10th
table), and a couple of discrepancies between the reply's prose and the actual re-exported
workbook. This file is kept for the original reasoning/evidence, not as the current status.

Issues and judgment calls found while building `travel_dv_dbt` from
`Travel_SourceToModel_Mapping.xlsx` + `TRAVEL_FIXES_APPLIED.md`. The mapping itself was
already verified and pre-fixed (multi-traveller re-grain, subject-attribution) before this
build started, which meant far fewer genuine ambiguities than the Health/Partner builds —
what's below is what's left.

## 1. Judgment calls applied without an explicit instruction (please confirm or correct)

**`HUB_RISK_OBJECT` key for `BJAZ_TRV_LOADER_LOG_TABLE_MV`.** The mapping gives an explicit
composite key (`POLICY_REF || '|MEMBERn'`) for `BJAZ_TRV_LOADER_DATA_MV`'s traveller members,
but `BJAZ_TRV_LOADER_LOG_TABLE_MV` — a separate, single-traveller feed with no `MEMBER`-
prefixed columns at all — has no risk-object key specified anywhere. This build synthesizes
one by reusing `POLICYNUMBER` (the same value as that table's own `HUB_POLICY` key,
re-namespaced `'HUB_RISK_OBJECT|'`) — stable and logically justified for a single-traveller
feed, but not something you told us to do. Please confirm this is right, or point us at a
better risk/vehicle identifier if one exists on this table.

**`BJAZ_TRV_LOADER_DATA_MV.AGENTEMAILID` re-anchored to the agent.** `TRAVEL_FIXES_APPLIED.md`
Fix 2 explicitly re-anchored `TRAVEL_AGENT_NAME` (on `BA_TRV_DATA_POLICY_DTLS_MV`) to the
agent via `INTERMEDIARY_CODE` instead of the table's payer key. `AGENTEMAILID` (on a
*different* table, `BJAZ_TRV_LOADER_DATA_MV`, tagged `[child:agent]`) looks like the exact
same shape of problem — an agent's email sitting in a payer-keyed table. We applied the same
fix, re-anchoring it via that table's own `INTERMEDIARY` column rather than
`PREMIUMPAYERID`. Please confirm this was the intent, since it wasn't called out explicitly
the way the name was.

**RESOLVED — column types.** `OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv` was supplied covering
real Snowflake types for all 9 tables (this originally listed only 3 of 9 with types available
elsewhere; the other 6 had been hand-classified from column name as a stand-in). All 9
`stg_travel__*.sql` staging casts have been rebuilt from this file — no more inferred types.

Worth noting: cross-checking the earlier hand-classification against this real schema
surfaced 6 real misses — `COMMISSION_AMT`, `SP_DISCOUNT_AMT`, `PLAN_SUM_INSURED`,
`LOADING_AMT`, `DISCOUNT_AMT`, `SERVICE_CHARGE` all *look* like amounts by name and were
guessed as `NUMBER`, but are actually stored as `TEXT` in Snowflake. Good illustration of why
name-based guessing isn't a substitute for the real catalog — all six now cast correctly as
trimmed varchar.

**New finding: a 10th table exists in the schema file that isn't in the mapping's scope.**
`OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv` also lists `BJAZ_TRV_MEMBER_DTLS_EXTN` — a table not
among the 9 tables `Travel_SourceToModel_Mapping.xlsx` covers, and not referenced anywhere in
the Source→Target or Augmentation sheets. Given the name ("member details"), this could be
relevant to the same multi-traveller grain that `BJAZ_TRV_LOADER_DATA_MV`'s `MEMBER1..5`
columns address (Fix 1) — worth checking whether it should be in scope, or whether it's
superseded/unrelated. Not built here since it has no mapping at all; flagging rather than
guessing at its columns' targets.

## 2. Possible subject-attribution mismatch (not just a missing key)

`BJAZ_TRV_PLAN_MV.AREA` and `BJAZ_TRV_RATE_MASTER_MV.AREA` are mapped to
`SAT_RISK_PERSON_TRAVEL.Geographical Zone` — a per-traveller attribute. But both source
tables are plan/rate REFERENCE tables (cover definitions and pricing rates respectively), not
traveller-instance tables — `AREA` there reads much more like "which geography does this
*plan* apply to" than "where is this *traveller* going." Not built (these tables also have no
`HUB_RISK_OBJECT` key to attach to regardless — see below), but worth double-checking whether
the intended target is actually a product/plan-level satellite instead.

Similarly, `BJAZ_TRV_RIDER_RATE_MAST_MV`'s rating columns (`EXTN_PRM_EXCLUDING_ST`,
`MIN_EXTN_PRM`, `MIN_NB_PRM`, `NB_PRM_EXCLUDING_ST`) target `SAT_PRODUCT_RATING_FACTOR`/
`SAT_PRODUCT_RATING_STRUCTURE` (parent `HUB_PRODUCT`), but this table's only verified key is
to `HUB_COVERAGE` (via `RIDER_SEQ_NO`), not `HUB_PRODUCT` — these are rider/coverage-level
rating factors, not product-level ones. Not built; flagged rather than guessed.

## 3. Real "no key on this table" gaps — 59 columns across the standard model

Every one of these has a canonical satellite target but the specific source table has no
verified key to that satellite's parent hub. Full detail available on request; by satellite:

| Satellite | Gap columns | Source table(s) |
|---|---|---|
| `SAT_COVERAGE_DEFINITION` | 18 (16 "Free Cover Limit" benefit fields + 2 others) | `BJAZ_TRV_LOADER_DATA_MV` (no `HUB_COVERAGE` key), `BJAZ_TRV_DETLS_EXTN` |
| `SAT_RISK_PERSON_TRAVEL` | 11 (Geographical Zone, Destination, Trip dates, Trip Duration, Visa Type) | `BA_TRV_DATA_POLICY_DTLS_MV`, `BJAZ_TRV_DETLS_EXTN`, `BJAZ_TRV_PLAN_MV`, `BJAZ_TRV_RATE_MASTER_MV`, `BJAZ_TRV_RIDER_DTLS_MV` — none have a `HUB_RISK_OBJECT` key |
| `SAT_FINTXN_PREMIUM` | 6 | `BJAZ_TRV_DETLS_EXTN`, `BJAZ_TRV_LOADER_LOG_TABLE_MV` (no `HUB_FINANCIAL_TRANSACTION` key), `BJAZ_TRV_RIDER_DTLS_MV` |
| `SAT_COMMON_ADDRESS` | 5 (Building, Pincode, State, Street, Sub-area/City) | `BJAZ_TRV_LOADER_DATA_MV` — has address text but no `HUB_LOCATION` key |
| `SAT_POLICY_HEADER` | 3 | `BA_TRV_PLAN_MST_MV`, `BJAZ_TRV_DETLS_EXTN` — neither has a `HUB_POLICY` key |
| `SAT_COVERAGE_LIMITS`, `SAT_PRODUCT_RATING_FACTOR`, `SAT_PRODUCT_RATING_STRUCTURE` | 2 each | see item 2 above for the rating-factor cases |
| `SAT_COMMON_CLASSIFICATION`, `SAT_DOCUMENT_DEFINITION`, `SAT_FINTXN_HEADER`, `SAT_FINTXN_TAX`, `SAT_FIN_CHARGE_RATE`, `SAT_INSTRUMENT_DEFINITION`, `SAT_ORG_UNIT_DEFINITION`, `SAT_POLICY_ENDORSEMENT`, `SAT_POLICY_TERMS`, `SAT_QUOTE_RATING` | 1 each | various — mostly `BJAZ_TRV_LOADER_LOG_TABLE_MV` or `BJAZ_TRV_DETLS_EXTN` missing the relevant hub key |

`SAT_POLICY_ENDORSEMENT`'s one mapped column (`BJAZ_TRV_DETLS_EXTN.ACTION_CODE` → Endorsement
Type) also has no `HUB_POLICY` key on that table — even once keyed, the canonical childkey
"Endorsement Number" has no source data anywhere in the mapping, so this satellite couldn't
be built with real history discrimination even if the hub key existed.

## 4. Augmented-track gaps (build-side, same root causes as above)

- `TRP_DLY_WAY` (`BJAZ_TRV_DETLS_EXTN` → `SAT_AUG_COVERAGE_CONDITIONS`) — no `HUB_COVERAGE` key.
- `SPDISCOUNT`/`SPDISCOUNTAMT` (`BJAZ_TRV_LOADER_LOG_TABLE_MV` → `SAT_AUG_FINTXN_PREMIUM`) — no
  `HUB_FINANCIAL_TRANSACTION` key; `SPDISCOUNTAMT` is also the mapping's own noted duplicate
  of `SPDISCOUNT`, so it wouldn't be added even with a key.
- `STUDENT_PLAN_YN` (`BJAZ_TRV_RIDER_DTLS_MV` → `SAT_AUG_PRODUCT_TERMS`) — this table only has
  `HUB_COVERAGE`/`HUB_POLICY` keys, no `HUB_PRODUCT`.
- `MODEOFTRANSPORT`, `ALTITUDE` (`BJAZ_TRV_LOADER_DATA_MV`, no `MEMBERn` prefix) — target a
  per-traveller satellite (`SAT_RISK_PERSON_TRAVEL`) but aren't scoped to any specific
  traveller. If these are meant to apply to the whole policy rather than one traveller, they
  may need a different (policy-level) home instead.

## 5. Confirmed clean (no action needed)

- No stitches or links needed anywhere in this LOB (see README Architecture section) —
  verified, not assumed.
- The 9 `EXCLUDE+FLAG` name-only augmentation columns (assignee/sponsor/nominee names with no
  key) were correctly excluded by the mapping itself; not re-litigated here.
- `SAT_LNK_ROLE_NOMINEE_BENEFICIARY` and `SAT_LNK_ROLE_CUSTOMER` (role-special pattern) both
  resolved cleanly via each contributing table's own payer key — no gaps found.
