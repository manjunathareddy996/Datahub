# Travel LOB Data Vault — dbt project

Data Vault 2.0 build for the Travel line of business, on Snowflake, using
[AutomateDV](https://automate-dv.readthedocs.io/) (`Datavault-UK/automate_dv`). Built on the
same principles as [`health_dv_dbt/`](../health_dv_dbt/README.md) and
[`partner_dv_dbt/`](../partner_dv_dbt/README.md), in its own separate project.

**Status: not yet `dbt deps`'d or run against Snowflake.** Everything below has been
generated and script/hand-verified (structural review, dependency-resolution sweeps,
cross-checks against the source mapping) but never compiled or executed.

## Source documents

- `Travel_SourceToModel_Mapping.xlsx` — the mapper's source→target mapping (Summary,
  Source→Target, Target→Source, Augmentation (build-side), Benefit Catalog [round 3],
  Review Flags sheets). `Source→Target` gained a `Key / Grain / Join` column in round 3 that
  now renders every key/join/unpivot rule as a real structured column, not just prose.
- `mapper_correspondence/TRAVEL_FIXES_APPLIED.md` — the mapper's note describing two correctness fixes applied to
  the mapping before handoff (multi-traveller re-grain, subject-attribution), and the
  **build-side-by-default augmentation policy** this build follows (no modeler round-trip
  right now; revisit at Motor).
- `data_5b.js` (project root) — the canonical model this mapping validates against (same file
  `partner_dv_dbt` uses; Travel maps into the same shared hubs/links/satellites).
- `OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv` (project root) — real Snowflake column types for all
  9 source tables (plus a 10th, `BJAZ_TRV_MEMBER_DTLS_EXTN`, confirmed in-scope by the mapper
  but held pending a data check — see `docs/MAPPER_QUESTIONS_TRAVEL.md`). Every
  `stg_travel__*.sql` staging cast derives its type from this file directly.
- `mapper_correspondence/MAPPER_REPLIES_TRAVEL.md` — the mapper's replies, round 2 and round 3
  (same file, extended in place): round 2 confirmed both judgment calls and both
  subject/grain questions, corrected 3 of the "no-key" gaps; round 3 confirmed the
  `BA_TRV_DATA_POLICY_DTLS_MV` fan-out join, supplied real cover codes, and re-targeted
  `RIDER_PREMIUM` in the workbook itself (matching what this build had already done
  proactively in round 2).
- `benefit_catalog.json` (project root, round 3) — the real `HUB_COVERAGE` cover code + name
  per free-cover-limit benefit column, mirrored in the workbook's Benefit Catalog sheet.

## Architecture

Same shape as Health/Partner, minus one layer:

```
Snowflake RAW.GG_DWHSTAGE (source tables)
        │
models/staging/travel/*.sql            -- 1:1 casts, one view per source table (9 tables)
        ▼
models/automate_dv/standard/
  stitched/*.sql                       -- ONE view (round 3) -- see below
        │
  staging/stg2_*.sql                   -- automate_dv.stage() calls, namespaced hash keys +
        │                                  HASHDIFF (188 files: per-table + per-attribute)
        ▼
  hubs/*.sql · satellites/*.sql        -- hub() / sat() / ma_sat() calls (no links/*.sql --
                                           see below)
```

**No `links/` models** — the mapping's Target→Source sheet has zero `KEY:LNK_*` rows, no
genuine associative link is needed anywhere in this LOB's source tables. The two satellites
that are canonically link-parented (`SAT_LNK_ROLE_NOMINEE_BENEFICIARY`, and
`SAT_LNK_ROLE_CUSTOMER` in the augmented track) use the same **role-special** pattern as
Health/Partner: built directly off `HUB_PARTY` with a literal `ROLE_TYPE_CK`, ratified for
Health as M3 ("a load-time provenance label, not a fabricated business key").

**`stitched/` has exactly ONE view, added in round 3** — every other satellite attribute in
this LOB traces to exactly one source column, so a stitch would add indirection without
bypassing anything (this was true and confirmed for the whole build through round 2).
`stitch_risk_person_travel_trip_attrs.sql` is the one genuine exception: the mapper confirmed
`BA_TRV_DATA_POLICY_DTLS_MV` shares the exact same `POLICY_REF` value space as
`BJAZ_TRV_LOADER_DATA_MV`, so its trip attributes (Destination, Trip Duration, Geographical
Zone, Visa Type) need to be joined in and fanned out to every traveller on the policy. Raw
staging in, `LEFT JOIN` on `POLICY_REF`, zero hashing — the same convention Health/Partner's
`stitched/` views use, just needed for the first time here.

`models/automate_dv/augmented/` is the **build-side, no-modeler-round-trip** track — per
`mapper_correspondence/TRAVEL_FIXES_APPLIED.md`'s explicit policy for Travel right now, augmentation columns are
built as `SAT_AUG_*`, using the exact `SAT_AUG_*` names the mapper specifies where given.
Round 2 added two new augmented satellites the mapper's reply asked for:
`SAT_AUG_COVERAGE_RATING` (coverage/rider-level rating factors that were mis-targeted at a
product-level satellite with no key) and `SAT_AUG_RISK_PERSON_TRAVEL` (`MODEOFTRANSPORT`/
`ALTITUDE`, fanned out to every traveller on the policy).

### Hash key convention

Identical to Health/Partner: every hash key is `hash('{HUB_OR_LINK_CODE}|' || raw_key)` via a
derived `*_NK` helper column, namespaced by hub code. `_HKEY` suffix used consistently
throughout (the `_HK`/`_HKEY` split that broke 14 Health hubs never happened here, same as
Partner).

### `HUB_RISK_OBJECT` — the one synthetic hub

The mapping has no explicit `KEY:HUB_RISK_OBJECT` row (unlike the other 13 hubs). Two
resolutions, both synthetic and both documented in the relevant `stg2_hub_*.sql` header:

1. **`BJAZ_TRV_LOADER_DATA_MV`** (the wide multi-traveller table, `MEMBER1..5` ×
   NAME/GENDER/PASSPORTNO/RELATION/DISEASE/DOB) — **mapper-specified** composite key
   `POLICY_REF || '|MEMBERn'`, per `mapper_correspondence/TRAVEL_FIXES_APPLIED.md` Fix 1: gives each of up to 5
   travellers on a policy their own `HUB_RISK_OBJECT` node instead of collapsing onto the
   payer party (the bug the fix corrected).
2. **`BJAZ_TRV_LOADER_LOG_TABLE_MV`** — a separate, single-traveller source feed (confirmed:
   no `MEMBER`-prefixed columns anywhere in its real schema) that also carries risk-object
   attributes (vehicle/motor fields, trip dates). **Not mapper-specified** — this build
   synthesizes one risk-object per policy by reusing its own `POLICYNUMBER` (the same raw
   value as its `HUB_POLICY` key, just re-namespaced). Stable and logically justified (1
   single-traveller policy = 1 risk object), but a genuine build-side judgment call — flagged
   in `docs/MAPPER_QUESTIONS_TRAVEL.md`.

Every OTHER table with `HUB_RISK_OBJECT`-parented attributes in the mapping
(`BJAZ_TRV_PLAN_MV`, `BJAZ_TRV_RATE_MASTER_MV`, `BJAZ_TRV_RIDER_DTLS_MV`, `BJAZ_TRV_DETLS_EXTN`)
has **no** risk-object-compatible key at all and no confirmed join to one — those columns are
not built; see Known gaps. **`BA_TRV_DATA_POLICY_DTLS_MV` is the one exception** (round 3):
it carries its own `POLICY_REF` (the same column, same value space, as
`BJAZ_TRV_LOADER_DATA_MV`'s), so its trip attributes are joined in via
`stitch_risk_person_travel_trip_attrs.sql` and fanned out to every traveller — see the
`stitched/` note above.

## Folder structure

```
travel_dv_dbt/
  models/
    staging/travel/             10 files -- 1:1 source casts + _sources.yml (9 tables)
    automate_dv/
      standard/                  -- the canonical, mapper-verified build
        stitched/                  1 file (round 3 -- see Architecture)
        staging/                  188 files
        hubs/                     14 files (13 explicit + synthetic HUB_RISK_OBJECT; round 2
                                              added an address-point HUB_LOCATION branch and
                                              a 17-way wide-benefit HUB_COVERAGE unpivot, now
                                              keyed on the mapper's real cover codes -- round 3)
        links/                    0 files -- none needed, see Architecture
        satellites/                33 files (round 2 added SAT_FINTXN_HEADER, fixed
                                              SAT_COMMON_ADDRESS, extended SAT_FINTXN_PREMIUM/
                                              _TAX/SAT_FIN_CHARGE_RATE/SAT_COVERAGE_DEFINITION;
                                              round 3 extended SAT_RISK_PERSON_TRAVEL with the
                                              fan-out join + a self-caught gap fix, see below)
        references/                0 files -- none mapped for Travel
      augmented/                  -- build-side, no modeler round-trip (current Travel policy)
        staging/                   38 files
        satellites/                12 files (round 2 added SAT_AUG_COVERAGE_RATING,
                                              SAT_AUG_RISK_PERSON_TRAVEL)
  packages.yml                    dbt-labs/dbt_utils, Datavault-UK/automate_dv
  dbt_project.yml
```

## Setup

```
dbt deps                          # installs dbt_utils + automate_dv per packages.yml
dbt debug                         # confirm your profile ('travel_dv') connects to Snowflake
```

`vars` in `dbt_project.yml`: `travel_raw_database` / `travel_raw_schema` point staging at the
source tables (`RAW.GG_DWHSTAGE` by default) — override per environment.

Materializations: `staging` and `automate_dv.standard.staging` are views; `hubs`/`satellites`
(both standard and augmented) are incremental tables.

## What's verified vs. not

- **Structural**: every `ref()`/`source_model` reference across all 295 `.sql` files resolves
  to a real model (0 dangling refs), every hub's/satellite's `src_pk` was cross-checked
  against its stage source's `hashed_columns` output, and — new in round 2 — every declared
  `src_payload`/`src_cdk` column was cross-checked against the UNION of all its listed source
  models' actual output columns (not just the pk). That third check exists because of a bug
  class caught twice in round 2: a stage-filename collision (two different columns from the
  same table, targeting the same hub/satellite, generating the identical filename) silently
  overwrote one column's stage file with the other's — the satellite's declared payload still
  listed both, but only one was actually being produced. Found first in `hub_location.sql`
  (`TRANSITFROM`'s key was silently discarded in favour of `TRANSITTO`'s — affected 5 hubs:
  `HUB_DISTRIBUTION_CHANNEL`, `HUB_LOCATION`, `HUB_ORG_UNIT`, `HUB_PARTY`, `HUB_PRODUCT`), then
  again in the augmented-track generator (`SAT_AUG_PRODUCT_TERMS` silently lost 2 of its 3
  `BA_TRV_PLAN_MST_MV` attributes). Both generators fixed (stage filenames now include the
  column name), all affected files rebuilt, and the new cross-check would catch a recurrence.
- **Never compiled or run.** No `dbt compile`, no `dbt run`, no Snowflake execution.
- **Column types: real for all 9 source tables**, read from `OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv`
  (supplied by the mapper, root folder) — every `stg_travel__*.sql` staging cast now derives
  its type straight from that file's `DATA_TYPE` column, not inferred. (This was originally a
  real gap: only 3 of 9 tables had type data at build time, and the other 6 were
  hand-classified from column name as a stand-in — that path also caught and fixed a regex
  bug that had mis-cast `AGE_ARRAY_COMMA_SEPARATED` as a number, since "RATE" is a substring
  of "sepaRATEd", the same class of bug caught earlier in the Partner build. Once the real
  schema arrived, cross-checking against it surfaced 6 genuine misses — `COMMISSION_AMT`,
  `SP_DISCOUNT_AMT`, `PLAN_SUM_INSURED`, `LOADING_AMT`, `DISCOUNT_AMT`, `SERVICE_CHARGE` all
  look like amounts by name but are actually stored as `TEXT` in Snowflake — now cast
  correctly.) The schema file also lists a 10th table, `BJAZ_TRV_MEMBER_DTLS_EXTN`, that isn't
  in the mapping's scope at all — flagged in `docs/MAPPER_QUESTIONS_TRAVEL.md`, not built.
- **Round 3: benefit catalog adopted, trip-attribute fan-out built, one more self-caught gap
  fixed.** The mapper supplied real cover codes (`benefit_catalog.json` / the workbook's new
  Benefit Catalog sheet) — the 17 wide-benefit `HUB_COVERAGE` keys now use
  `POLICY_REF || <real cover code>` instead of the raw column name placeholder. The
  trip-attribute fan-out for `BA_TRV_DATA_POLICY_DTLS_MV` is now built (confirmed: it shares
  the exact `POLICY_REF` value space with `BJAZ_TRV_LOADER_DATA_MV`) — this needed the one
  genuine join in this LOB, see the `stitched/` note above. While rebuilding that satellite,
  found a second, independent gap (not from the mapper): `BJAZ_TRV_LOADER_DATA_MV`'s own trip
  columns with no `MemberN` prefix (`AREAPLAN`, `DEPARTUREDATE`, `NOOFJOURNEYDAYS`,
  `PRJOURNEY`, `RETURNDATE`) were valid mapped columns that the original per-member generator
  silently never built at all — its filter only matched columns literally containing
  `MEMBERn`, so these 5 matched none of the 5 per-member branches and were dropped with zero
  trace, not even a documented gap. Now fanned out to all 5 travellers, `COALESCE`d against
  the joined `BA_TRV_DATA_POLICY_DTLS_MV` values where both could populate the same canonical
  attribute (`Geographical Zone`, `Trip Duration`, `Destination Country` — `data_5b` has one
  slot for each, not separate per-source variants).
- **Judgment calls applied without an explicit mapper instruction, both confirmed correct in
  round 2** (`mapper_correspondence/MAPPER_REPLIES_TRAVEL.md`): the `HUB_RISK_OBJECT` synthetic key for
  `BJAZ_TRV_LOADER_LOG_TABLE_MV`; re-anchoring `BJAZ_TRV_LOADER_DATA_MV.AGENTEMAILID` to the
  agent via `INTERMEDIARY` (now recorded explicitly in the workbook too).

## Round 4: multi-active rekey (cross-LOB, from the Motor review)

`mapper_correspondence/MAPPER_NOTE_MULTIACTIVE_REKEY.md`: the Motor modeler pass (`data_7`, Phase 7)
changed the grain of `SAT_FINTXN_COMMISSION` and `SAT_FIN_CHARGE_RATE`, both of which this
LOB also writes. No source column→attribute re-mapping needed — the new child keys promote
attributes this build already populates.

- **`SAT_FINTXN_COMMISSION`** — converted `sat()` → `ma_sat()`, child key
  `COMMISSION_TYPE_CK`, literal `'Standard'` on both contributing tables (no real
  commission-type discriminator on either `BA_TRV_DATA_POLICY_DTLS_MV` or
  `BJAZ_TRV_LOADER_DATA_MV`).
- **`SAT_FIN_CHARGE_RATE`** — **a real collision bug, not just a missing declaration.**
  `BA_TRV_DATA_POLICY_DTLS_MV` was forcing two genuinely different charge concepts
  (`LOADING_PER`, an additional loading rate, and `SERVICE_CHARGE`, a service charge amount)
  onto one row with no discriminator at all. Split into two branches
  (`'Additional Loading'` / `'Service Charge'`); `BJAZ_TRV_LOADER_LOG_TABLE_MV`'s existing
  contribution keeps the `'Service Charge'` literal (same concept, different table).
- **Flagged, not folded**: `SAT_AUG_FINTXN_PREMIUM` (augmented track) already carries a
  `DISCOUNT_PERCENTAGE` column that lines up with the note's "also live in `data_7`"
  promotion of that exact attribute onto the canonical `SAT_FINTXN_PREMIUM`. **Done in
  round 5** — see below; left as a flag at the time this round-4 section was written.
- **Verified**: full dependency-resolution + `src_pk`/`hashed_columns` sweep re-run after
  these changes, 0 dangling refs, 0 mismatches across all 296 `.sql` files in this project.

## Round 5: `data_7` re-baseline (`mapper_correspondence/MAPPER_NOTE_TRAVEL_DATA7_SYNC.md`)

The Travel mapping was originally built against `data_v5a`; this pass re-points it to
`data_7` (Phase 7). **Additive only** — every previously-mapped column still resolves,
nothing renamed out. Three build actions, two of which turned out to already be correct:

- **`SAT_FINTXN_PREMIUM.Discount Percentage` — folded in.** `DISCOUNT_PER`
  (`BA_TRV_DATA_POLICY_DTLS_MV`) was build-side augmentation (`SAT_AUG_FINTXN_PREMIUM`);
  `data_7` canonicalised it. Folded directly into the existing
  `stg2_fintxn_premium_ba_trv_data_policy_dtls_mv.sql` branch (same table, same row — no
  need for a separate stage file) and removed from the augmented satellite. The two
  special-discount columns (`SP_DISCOUNT_PER`/`SP_DISCOUNT_AMT`/`SPDISCOUNT`) stay
  augmented — `data_7` gave a home to standard discount, not special discount.
- **`SAT_FINTXN_TAX` child key (`Tax Type`) — already correct, no change needed.** Checked
  directly: this satellite has carried a real, non-blank `TAX_TYPE` literal per branch
  (`'cess'` / `'service_tax'` / `'service_tax'`) since round 2, including the exact
  two-sources-dedup-to-one-tax-type shape the sync note describes. Not part of the earlier
  cross-LOB `mapper_correspondence/MAPPER_NOTE_MULTIACTIVE_REKEY.md` pass (that covered `SAT_FINTXN_COMMISSION`/
  `SAT_FIN_CHARGE_RATE`/`SAT_POLICY_PREMIUM_HEAD` only) — this one was independently right
  from the original build.
- **`SAT_FIN_CHARGE_RATE` / `SAT_FINTXN_COMMISSION` child keys — confirmed matching.** The
  sync note explicitly says "matches your applied split" for the charge-rate fix from the
  cross-LOB rekey round; verified byte-for-byte against what's already built. No change.
- **Verified**: dependency-resolution + `src_pk`/`hashed_columns` sweep re-run after the
  discount fold, 0 dangling refs, 0 mismatches, across all 295 `.sql` files (one fewer than
  round 4 — the now-redundant `SAT_AUG_FINTXN_PREMIUM` discount-per stage file was removed).

## Known gaps and open items

**Resolved in round 2** (see `mapper_correspondence/MAPPER_REPLIES_TRAVEL.md` for full reasoning):
- `SAT_COMMON_ADDRESS` — was a real bug, not just a gap: `BJAZ_TRV_LOADER_LOG_TABLE_MV`'s
  rows were wrongly keyed via `TRANSITFROM` (a trip-transit code, unrelated to a person's
  address) due to the stage-filename collision bug above. Fixed: both loader tables now key
  `HUB_LOCATION` on a content hash of the full normalized address (mapper-confirmed —
  `SAT_COMMON_ADDRESS` is single-active and a pincode covers many distinct addresses, so
  pincode alone would collapse unrelated addresses onto one row).
- Premium on `BA_TRV_DATA_POLICY_DTLS_MV` was already correctly keyed via `TRANSACTION_ID`.
  For the two txn-less loader tables, `BJAZ_TRV_LOADER_LOG_TABLE_MV` now has a **degenerate**
  `HUB_FINANCIAL_TRANSACTION` key (reuses `POLICYNUMBER`, one premium record per policy) —
  unblocks `SAT_FINTXN_PREMIUM`, `SAT_FINTXN_HEADER` (new), `SAT_FINTXN_TAX`,
  `SAT_FIN_CHARGE_RATE`, and the `SPDISCOUNT` augmentation on that table.
- The 17 "Free Cover Limit" benefit columns on `BJAZ_TRV_LOADER_DATA_MV` are a wide-benefit
  unpivot (the Health pattern) — each column is its own coverage instance, keyed
  `HUB_COVERAGE` = `POLICY_REF || Cover Code`. **Round 3**: the mapper's round-2 reply
  claimed a benefit→cover-code catalog existed but it wasn't actually in the re-exported
  workbook then — flagged, and in round 3 the mapper supplied a real one (`benefit_catalog.json`
  + the workbook's new Benefit Catalog sheet). All 17 keys now use the real cover code
  (e.g. `TRV_ACC_HOSP_EXP`) instead of the earlier raw-column-name placeholder.
- `BJAZ_TRV_PLAN_MV`/`BJAZ_TRV_RATE_MASTER_MV.AREA` — confirmed mistargeted (plan/rate
  applicability zone, not a traveller's destination). Moved to build-side
  `SAT_AUG_PRODUCT_TERMS.Plan Geographical Zone`, keyed via each table's own `HUB_PRODUCT` key.
- `BJAZ_TRV_RIDER_RATE_MAST_MV`'s 4 rating columns — confirmed mistargeted (coverage-level,
  not product-level; the model has no coverage-rating satellite at all). Moved to new
  build-side `SAT_AUG_COVERAGE_RATING`, keyed via `RIDER_SEQ_NO → HUB_COVERAGE`.
  `BJAZ_TRV_RIDER_DTLS_MV.RIDER_PREMIUM` (previously mapped to
  `SAT_FINTXN_PREMIUM.Gross Premium` with no key on that table) moved here too, keyed via
  `RIDER_NO`. Flagged for Motor as a promote-to-canonical candidate.
- `MODEOFTRANSPORT`/`ALTITUDE` — confirmed these are trip-level facts and
  `SAT_RISK_PERSON_TRAVEL` is the right satellite; they just needed fan-out to every
  traveller on the policy. Built as new `SAT_AUG_RISK_PERSON_TRAVEL`, same
  `POLICY_REF || MEMBERn` composite as the DOB augmentation (no cross-table join needed —
  this table already carries its own `POLICY_REF`).

**Resolved in round 3** (see `docs/MAPPER_FOLLOWUP_ROUND2_TRAVEL.md` for the original
question and `mapper_correspondence/MAPPER_REPLIES_TRAVEL.md`'s round-3 update for the mapper's answer):
- **`BA_TRV_DATA_POLICY_DTLS_MV`'s trip attributes** (Destination, Trip Duration,
  Geographical Zone code/name, Visa Type) — confirmed buildable: this table shares the exact
  `POLICY_REF` value space with `BJAZ_TRV_LOADER_DATA_MV`. Built via the one genuine join in
  this LOB (`stitched/stitch_risk_person_travel_trip_attrs.sql`), fanned out to every
  traveller. `BJAZ_TRV_DETLS_EXTN` and `BJAZ_TRV_RIDER_DTLS_MV`'s trip attributes remain
  correctly unbuilt — the mapper confirmed they have no `POLICY_REF` and the join to the
  loader table is unconfirmed (same data-dependent class as the 10th table below).
- **RIDER_PREMIUM** — round 2 already applied the mapper's stated intent (moved to
  `SAT_AUG_COVERAGE_RATING`, keyed via `RIDER_NO`) even though the workbook row hadn't caught
  up yet; round 3's re-exported workbook now shows the row itself updated to match exactly.
  No build change needed.
- **A self-caught gap, found while rebuilding the fan-out**: `BJAZ_TRV_LOADER_DATA_MV`'s own
  trip columns with no `MemberN` prefix (`AREAPLAN`, `DEPARTUREDATE`, `NOOFJOURNEYDAYS`,
  `PRJOURNEY`, `RETURNDATE`) were silently never built at all — not from the mapper, not
  previously documented as a gap. Now fanned out to all 5 travellers.

**Still open:**
- **9 EXCLUDE+FLAG augmentation columns not built at all**, per the mapping's own
  Disposition — all name-only, no key, correctly excluded.
- **A 10th table, `BJAZ_TRV_MEMBER_DTLS_EXTN`, is confirmed in scope but not built.** It's a
  real per-member table (`POLICY_REF` × `MEMBER_ID`) carrying `SUMINSURED`, `SI_CURRENCY`,
  `ID_CARD_NO`, `TYPE_OF_LOSS` — complementary to, not a replacement for, the wide
  `MEMBER1..5` block. Held pending a data check both sides can't currently do without sample
  data: does `MEMBER_ID` line up positionally with `MEMBER1..5`, or is it a global surrogate?
  The answer decides whether it re-keys the traveller grain or lands as its own feed.
- **The cross-table fan-out for trip attributes on `BJAZ_TRV_DETLS_EXTN`/
  `BJAZ_TRV_RIDER_DTLS_MV`** (Trip dates, Trip Duration, `TRP_DLY_PRM`) remains **not built** —
  mapper-confirmed (round 3): these tables carry `CONTRACT_ID`/`TRAVEL_REQ_NO`/`TRV_DATA_NO`,
  not `POLICY_REF`, and the value-space match to `BJAZ_TRV_LOADER_DATA_MV.POLICY_REF` is
  unconfirmed — same data-dependent class as the 10th table. `BA_TRV_DATA_POLICY_DTLS_MV`'s
  trip attributes were the one case that *was* confirmed and built (see "Resolved in round 3"
  above).
- `TRP_DLY_WAY` (`SAT_AUG_COVERAGE_CONDITIONS`) and `STUDENT_PLAN_YN` (`SAT_AUG_PRODUCT_TERMS`)
  remain unbuilt — confirmed genuine "no key on this table" gaps by the mapper, no fix
  available yet.
- **~18 more "no key on this table" gaps** across the standard model (down from 59 before
  round 2 — most of the rest were resolved across rounds 2/3): `SAT_POLICY_HEADER` (3),
  `BJAZ_TRV_DETLS_EXTN`/`BJAZ_TRV_RIDER_DTLS_MV`'s remaining `SAT_RISK_PERSON_TRAVEL` trip
  attributes (4, see above), `SAT_COVERAGE_LIMITS` (2), and single columns each on
  `SAT_COMMON_CLASSIFICATION`, `SAT_COVERAGE_DEFINITION` (`BJAZ_TRV_DETLS_EXTN.TRP_DLY_YN`
  only — the 17 loader-table columns are now built), `SAT_DOCUMENT_DEFINITION`,
  `SAT_FINTXN_PREMIUM` (`TRP_DLY_PRM`), `SAT_INSTRUMENT_DEFINITION`, `SAT_ORG_UNIT_DEFINITION`,
  `SAT_POLICY_ENDORSEMENT`, `SAT_POLICY_TERMS`, `SAT_QUOTE_RATING` — confirmed genuinely
  keyless by the mapper, not misses. Full list in `docs/MAPPER_QUESTIONS_TRAVEL.md`.
- **`SAT_LNK_POLICY_PARTY_ROLE`-equivalent gap**: no analogous satellite issue found here —
  Travel's role-special satellites (`SAT_LNK_ROLE_NOMINEE_BENEFICIARY`,
  `SAT_LNK_ROLE_CUSTOMER`) both resolved cleanly via each table's own payer key.

## Data model reference

`data_5b.js` (project root, one level up from `travel_dv_dbt/`) is the canonical model — the
same file `partner_dv_dbt` maps against. `Travel_SourceToModel_Mapping.xlsx`'s Summary sheet
confirms it was mapped against `data_5b` and validated (0 invalid targets, 0 collapse
violations). Diff any newer `data_*.js` against this one before trusting it's still current.

## Supporting documentation

- `mapper_correspondence/TRAVEL_FIXES_APPLIED.md` — the mapper's original fix note (root folder); load-bearing for
  the `HUB_RISK_OBJECT` composite-key rationale and the augmentation build-side policy.
- `docs/MAPPER_QUESTIONS_TRAVEL.md` — round-1 questions (superseded — see below).
- `mapper_correspondence/MAPPER_REPLIES_TRAVEL.md` (root folder) — the mapper's replies, round 2 and round 3.
- `docs/MAPPER_FOLLOWUP_ROUND2_TRAVEL.md` — what was implemented from the round-2 reply,
  discrepancies found between that reply's prose and the actual re-exported workbook at the
  time (all since resolved in round 3 — the mapper explicitly confirmed the builder's
  discrepancy-flagging was correct on every point), and the stage-filename-collision bug
  class found and fixed across 5 hubs + 1 augmented satellite. This README's "Known gaps"
  section (above) is the current status — round 3's resolutions are folded in there directly
  rather than in a third follow-up doc, since round 3 closed out nearly everything round 2
  had left open.
- `benefit_catalog.json` — real cover codes for the 17 wide-benefit `HUB_COVERAGE` keys.
