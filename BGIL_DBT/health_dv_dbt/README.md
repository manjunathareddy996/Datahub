# Health LOB Data Vault — dbt project

Data Vault 2.0 build for the Health line of business, on Snowflake, using
[AutomateDV](https://automate-dv.readthedocs.io/) (`Datavault-UK/automate_dv`). This is the
**only active build** in this project — an earlier hand-written build and an early
AutomateDV prototype both exist under `_archive/` for reference but are not part of the dbt
DAG (outside `model-paths`, `dbt run` never sees them).

**Status: not yet `dbt deps`'d or run against Snowflake.** Everything below has been
generated and hand/script-verified (structural review, dependency-resolution sweeps,
cross-checks against the source mapping) but never compiled or executed. Before this goes
anywhere near production, run `dbt deps && dbt compile` at minimum, then a real run against
a dev schema. See "What's verified vs. not" below for the honest breakdown.

## Architecture

```
Snowflake RAW.HEALTH (source tables)
        │
models/staging/health/*.sql            -- 1:1 casts, one view per source table (unchanged
        │                                  since before AutomateDV; every stage() model below
        │                                  reads from here)
        ▼
models/automate_dv/standard/
  stitched/*.sql                       -- ONLY for satellites needing attribute-level
        │                                  merging across tables (44 of them): raw staging
        │                                  in, FULL OUTER JOIN + COALESCE, no hashing.
        ▼
  staging/stg2_*.sql                   -- automate_dv.stage() calls. Computes every hash key
        │                                  (namespaced: hash('HUB_X|' || raw_key), never a
        │                                  bare hash — see "Hash key convention" below) and
        │                                  every HASHDIFF. One of two shapes:
        │                                    - per source table (union-only contributors,
        │                                      or single-table satellites) — ~887 of these
        │                                    - per stitch (one stage() pass on the joined
        │                                      output) — 43 of these
        ▼
  hubs/*.sql · links/*.sql · satellites/*.sql · references/*.sql
                                        -- automate_dv.hub() / .link() / .sat() / .ma_sat()
                                           calls, fed from a list of stage() outputs.
```

`models/automate_dv/augmented/` is a **second, parallel, not-mapper-confirmed** track: 15
satellites (`SAT_AUG_<HUB>`) built from 219 previously-unmapped source columns that a
keyword/anchor classifier bucketed against a hub with a verified key. Kept structurally
separate from `standard/` on purpose — these are proposals, not part of the canonical model.

### The one hard rule this build follows throughout

**A table is only routed through a `stitched/` view if its columns get `COALESCE`d against
another table's columns for the same key** (attribute-level merge). A table that only ever
contributes whole, distinct rows (row-union, no merge) is read directly from its own
`stage()` output by `hub()`/`link()`/`sat()`/`ma_sat()` — those macros already union
natively, so routing it through a stitch too would be redundant and, worse, would bypass
the coalesce/dedupe the stitch exists for if it *did* need one. See any `stitched/*.sql`
file's header comment for the specific reasoning on that satellite.

### Hash key convention

Every hash key in this build is `hash('{HUB_OR_LINK_CODE}|' || raw_business_key)`, via a
derived namespaced-text helper column (`*_NK`) hashed in its own step — never
`hash(raw_business_key)` alone. This prevents two different hubs from colliding on the same
hash if they happen to share a raw value on some source table (it happens — e.g.
`HUB_QUOTE` and `HUB_PROPOSAL` share `QUOTE_REF_NO` on some tables). AutomateDV's
`hashed_columns` config only accepts column names, not literals, so the namespacing has to
be its own `derived_columns` entry first — every `stg2_*.sql` file follows this same
two-step pattern. **This is not the same hashing formula the archived hand-written build
used** (that used `dbt_utils.generate_surrogate_key` directly in the vault layer) — hash
values from this build will not match the archived one; they're independent systems, not
meant to be diffed against each other.

Link member-end hashes reuse the *exact same* formula as that hub's own `stage()` models,
so they're guaranteed to equal the real hub row's hash for the same raw value — genuine
foreign keys, never independently re-derived. A link's own hash doesn't need to match
anything external, so it's computed directly from the concatenated raw keys in one pass.

## Folder structure

```
health_dv_dbt/
  models/
    staging/health/          124 files -- 1:1 source casts (shared foundation)
    automate_dv/
      standard/               -- the canonical, mapper-confirmed build
        stitched/              43 files
        staging/               887 files
        hubs/                  20 files
        links/                 58 files
        satellites/            109 files (includes SAT_LNK_POLICY_PARTY_ROLE)
        references/            1 file  (REF_EXCLUSION)
      augmented/                -- NOT mapper-confirmed, see above
        staging/                72 files
        satellites/             15 files
  macros/
    location_address_key.sql  -- reference/documentation only, not invoked (see its header)
  docs/                        -- see "Supporting documentation" below
  packages.yml                 -- dbt-labs/dbt_utils, Datavault-UK/automate_dv
  dbt_project.yml
_archive/                      -- OUTSIDE model-paths, dbt never touches this
  intermediate/, raw_vault/     -- the original hand-written build (141 + 187 files)
  prototype_automate_dv/        -- the early 4-model AutomateDV proof-of-concept
```

## Setup

```
dbt deps                          # installs dbt_utils + automate_dv per packages.yml
dbt debug                         # confirm your profile ('health_dv') connects to Snowflake
```

`vars` in `dbt_project.yml`: `health_raw_database` / `health_raw_schema` point staging at
the source tables (`RAW.HEALTH` by default) — override per environment via `--vars` or your
`profiles.yml` target if the source location differs.

Materializations: `staging` and `automate_dv.standard.stitched`/`staging` are views;
`hubs`/`links`/`satellites` (both standard and augmented) are incremental tables;
`references` are views. No custom incremental strategy overrides — plain AutomateDV
defaults throughout.

## What's verified vs. not

- **Structurally verified**: every one of the 1,204 files under `models/automate_dv/`
  resolves every `ref()`/`source_model` reference to a real model (automated sweep, 0
  dangling refs). All 43 `stitched/*.sql` views and all 58 `links/*.sql` were individually
  hand-reviewed (join logic, grain, CDK columns). ~850 of 851 link business-key references
  cross-checked against the source mapping's own verified key inventory.
- **Bugs found and fixed during generation** (all fixed in the generator script, then
  regenerated — not patched file-by-file): a quote-parsing bug that would have swapped hub
  codes and column names in link hash formulas; duplicate `source_model` entries plus a
  wrong `src_nk` reference in hub definitions; a Python operator-precedence bug that
  silently dropped the `config()` block from most stitch-backed satellites; and — the
  significant one — a hub-key column naming mismatch (`_HK` vs `_HKEY`) that would have
  broken **14 of 20 hubs** at compile time, found by manually cross-checking column names
  referenced across files (the automated ref-resolution sweep only checks that a *file*
  exists, not that the specific *column* it's asked for actually does — worth keeping that
  distinction in mind if extending this build further).
- **Never compiled or run.** No `dbt compile`, no `dbt run`, no Snowflake execution, at any
  point. Column names inside Jinja/YAML blocks were checked by grep/regex and manual review,
  not by an actual dbt parse. Treat the "0 dangling refs" and "hand-reviewed" claims above
  as necessary, not sufficient — a real `dbt compile` pass should be the very first thing
  the build/test team does with this.
- **Per-table stage() files** (the ~887 + 72 bulk of the tree) were generated by the same
  reviewed scripts as the hand-checked pieces above, and passed the dependency-resolution
  sweep, but were not individually read end-to-end the way the stitches/links were — this
  was an explicit scope decision partway through the build (stitches and links hand-verified
  in full; the high-volume per-table config layer trusted to the generator).

## Round 4: `HUB_LOCATION` address rekey (mapper feedback)

Mapper feedback: on address tables with no location-id/loc-code column, `HUB_LOCATION`'s key
must be the content hash of the full normalized address (Building/Door | Street | Locality |
City | District | State | Postal Code | Country — upper/trim, drop nulls), never bare
pincode or a single address line — `SAT_COMMON_ADDRESS` is single-active, so a weak key
collapses many distinct real addresses onto one row. Postal code stays as the `Postal Code`
attribute value. Full detail: `mapper_correspondence/ADDRESS_KEY_FIX_HEALTH.md` /
`Health_address_rekey.csv` (project root).

- **`BJAZ_HM_HOSPITAL_MASTER` had exactly this bug, hand-written into the original build**
  (not generator-produced — the same bug *class* as Travel's `TRANSITFROM` catch, found
  independently in this LOB). It was keyed bare on `PIN_CODE` inside
  `stitch_common_address.sql`'s `code_branch` FULL OUTER JOIN chain (was `t3`). Removed from
  that join and rebuilt as its own branch, keyed on the content hash of
  `ADDRESS1|ADDRESS2|CITY_NAME|STATE_NAME|PIN_CODE`.
- **15 tables that previously had `HUB_LOCATION`'s key left null** (address text present,
  never built) are now populated in `stitch_common_address.sql`'s `rekey_branch`, each keyed
  on the content hash of whatever address parts that table actually has. Two tables carry
  more than one genuinely distinct address on the same row and contribute two separate
  branches, not conflated: `BJAZ_HG_POL_DTLS` (current/permanent vs. dispatch/mailing) and
  `BJAZ_TPA_CLAIM_DETAILS_WS` (customer/insured vs. hospital — a third subject on this table,
  the existing `payee` M4 route, is untouched).
- **Two already-built M4 party-address tables** (`BA_HCP_PP_MEM_DTLS`,
  `BJAZ_HAT_ID_MEM_DETLS`) previously keyed `HUB_LOCATION` on the single free-text address
  line alone, nulling out `CITY`/`STATE`/`PIN` columns the table actually has. Both rewritten
  to key on the full content hash and expose the remaining address parts as real attributes.
  A third M4 table's existing route (`BJAZ_TPA_CLAIM_DETAILS_WS`'s `payee` address) was
  reviewed and correctly left alone — its rekey columns in the mapper's list are for the
  customer/hospital subjects above, a different address on the same row, not the payee's.
- **`BJAZ_HM_COINSU_CLM_DTLS` — closed per `mapper_correspondence/MAPPER_REPLY_ADDRESS_REKEY_HEALTH.md`.** The
  mapper's target was `NETWORK_CITY | STATE` (plain `STATE`, not `NETWORK_STATE` — the
  earlier mismatch was a naming mix-up, not a missing column). Both columns exist on the raw
  source but weren't exposed in staging; added there, then built as the 17th `rekey_branch`
  entry, keyed on the content hash of just those two columns — a coarse city/state grain,
  no street or pincode on this table, which is expected under the uniform rule (hash
  whatever parts exist). This closes all 17 tables in the mapper's original list (15 in
  `rekey_branch` + the 2 already-existing M4 tables above).
- **Populating `HUB_LOCATION`/`SAT_COMMON_ADDRESS` content does not require a party-key
  anchor** — only building a `LNK_PARTY_LOCATION` route does. Several rekeyed tables (e.g.
  `BJAZ_GRP_HLT_CUST_DTLS`) have no party key at all but still contribute pure address
  content via the union-only `rekey_branch`.
- **Verified end-to-end**: `stg2_common_address.sql` (the stage-on-stitch) hashes
  `LOCATION_HKEY` from the new `PARENT_BK` unchanged in shape; `hub_location.sql` and
  `sat_common_address.sql` both source from it unchanged, so the new keys flow through
  without any edit needed at the hub/satellite layer. All 21 `ref()` targets the rekey
  touches (including `BJAZ_HM_COINSU_CLM_DTLS`) resolve to real staging models (checked
  directly, not just by the generator producing output).

## Round 5: multi-active rekey (cross-LOB, from the Motor review)

`mapper_correspondence/MAPPER_NOTE_MULTIACTIVE_REKEY.md`: the Motor modeler pass (`data_7`, Phase 7)
changed the grain of three satellites this build also writes, because multiple columns were
silently overwriting each other on what used to be single-active satellites. **No source
column→attribute re-mapping was needed** — each new child key promotes an attribute this
build already populates.

- **`SAT_FINTXN_COMMISSION`** — converted `sat()` → `ma_sat()`, child key
  `COMMISSION_TYPE_CK`. Only 1 column (`BJAZ_HEALTH_WEBSERVICE_INFO.COMM_DISC_RATE`), no real
  discriminator on the table, so the child key is a literal (`'Standard'`) — a judgment call,
  not fabricated data.
- **`SAT_FIN_CHARGE_RATE`** — converted `sat()` → `ma_sat()`, child key `CHARGE_TYPE_CK`.
  Same shape: 1 table (`BJAZ_GRP_TPA_EXTN`), both columns are one charge concept, literal
  `'Service Charge'`.
- **`SAT_POLICY_PREMIUM_HEAD`** — **a real collision bug, not just a missing declaration.**
  This satellite was already `ma_sat()` with a child key column (`PREMIUM_HEAD_CODE_CK`) —
  but every one of its 5 contributing tables had it hardcoded to the same blank literal
  `'!'`. Any policy with premium-head rows from 2+ of those tables would have silently
  collapsed onto one multi-active row, discarding the rest under AutomateDV's hashdiff
  tracking. Fixed with a distinct literal per table/concept
  (`'Base Cover'`/`'Per Person Premium'`/`'Maternity Rider'`/`'Maternity Co-Buffer'`/
  `'Add-On Premium'`/`'Surgical Cover Base'`). `BJAZ_GRP_HLT_MATERNITY_DTLS` was also split
  into two branches — it had been forcing two genuinely different premium-head concepts
  (`PRIME_RIDER_BASE_PREM`, `PERMIUM_CO_BUFFER`) onto one row, exactly the "multiple Base
  Amount / Net Head Premium rows per table" case the mapper's note flagged for a real check.
- **Not actioned**: the note's secondary "also live in `data_7`" promotions
  (`SAT_FINTXN_PREMIUM` += Discount Percentage/Description, `SAT_ASSESSMENT_HEADER` +=
  Scheduled Time/Rescheduled Date-Time/Sub-Status) — checked, this LOB has no matching
  build-side augmentation columns to fold, so there's nothing to do here (Travel does, see
  its own README).
- **Verified**: full dependency-resolution + `src_pk`/`hashed_columns` sweep re-run after
  these changes, 0 dangling refs, 0 mismatches across all 1329 `.sql` files in this project.

## Round 6: `data_7` re-baseline (`mapper_correspondence/MAPPER_NOTE_HEALTH_DATA7_SYNC.md`)

The Health mapping is now the canonical, unsuffixed `Health_SourceToModel_Mapping.xlsx`
(129 tables — up from the `_v5` file this build was originally sourced from), superseding
all `_v2`…`_v5` versions. **Target validity: 0 breaks** — every previously-mapped column
still resolves against `data_7`, additive only.

- **Only 6 of the 129 tables are genuinely unbuilt** — despite the note's "48 new" framing
  (which counts against an older baseline than what this project actually built from,
  empirically verified by diffing the workbook's table list against this project's 123
  staging models). All 6 (`BJAZ_HM_CHARGE_MASTER`, `BJAZ_HM_DIAGNOSIS_MASTER`,
  `BJAZ_HM_DISEASE_MASTER`, `BJAZ_HM_ICD_DISEASE_MASTER`, `BJAZ_HM_ICD_MASTER`,
  `BJAZ_HM_ROOM_MASTER`) are `needs_reanchor` in the workbook with **no target at all** —
  nothing to build, correctly left alone.
- **`SAT_POLICY_PREMIUM_HEAD` child-key literals reconciled** to the mapper's exact tokens:
  `'Per Person Premium'` → `'Per-Person Basis'`, `'Add-On Premium'` → `'Add-On'`,
  `'Surgical Cover Base'` → `'Surgical Cover'` (the mapper's note explicitly says the exact
  literal was left for the builder to finalise — matched their proposed wording instead of
  keeping the earlier guesses, since there's no reason to diverge once given the exact text).
- **A genuinely new gap, found while reconciling**: `BJAZ_HCF_MEMBER_DTLS.FLOAT_PREMIUM`
  (→ Net Head Premium, child key `'Floater'`) was sitting unbuilt on this table's own
  staging model the whole time — only `ADON_PREMIUM` (`'Add-On'`) had been wired into
  `SAT_POLICY_PREMIUM_HEAD`. Added as a second branch off this table (now split the same
  way `BJAZ_GRP_HLT_MATERNITY_DTLS` was in round 5).
- **`SAT_FINTXN_COMMISSION`/`SAT_FIN_CHARGE_RATE` literals confirmed matching** — the
  mapper's note explicitly confirms `'Standard'`/`'Service Charge'` match what round 5
  already applied. No change.
- **No augmentation fold this pass** — the mapper's note explains the `_v5` workbook's 514
  augmentation rows don't carry a structured proposed-home the way Travel/Partner's did, so
  nothing could be machine-matched against `data_7`'s two secondary promotions (already
  confirmed not applicable to Health in round 5 anyway).
- **Verified**: full dependency-resolution + `src_pk`/`hashed_columns` sweep re-run after
  these changes, 0 dangling refs, 0 mismatches across all 1330 `.sql` files in this project.

## Known gaps and open items

- **11 satellites have zero source data** (`SAT_COVERAGE_CONDITIONS`, `SAT_COVERAGE_DEFINITION`,
  `SAT_COVERAGE_LIMITS`, `SAT_COVERAGE_LIVES_COUNT`, `SAT_COVERAGE_MEMBER_BENEFIT`,
  `SAT_COVERAGE_SUBLIMIT_SCHEDULE`, `SAT_FIN_PREMIUM_REGISTER`,
  `SAT_PRODUCT_EXCLUSION_CATALOGUE`, `SAT_PROPOSAL_HEADER`, `SAT_RISK_HEALTH_PED_WAITING`,
  `SAT_RI_CESSION_DETAIL`) — matches the same gap set the archived build had; six of these
  are the `HUB_COVERAGE` satellites pending the modeler's benefit-code unpivot seed (M1 in
  `docs/MODELER_DECISIONS_HEALTH.md`).
- **Mapper questions awaiting a response**: `docs/MAPPER_QUESTIONS_KEY_REPASS.md` (143
  composite-key candidates, Tier B — genuinely needs domain judgment, not yet actioned) and
  the source-table business-context questions in `docs/MAPPER_QUESTIONS_TABLE_CONTEXT.md`.
- **`SAT_PARTY_CONTACT_ADDRESS_LINK` / `SAT_LNK_POLICY_PARTY_ROLE`** each have several
  canonical attributes with no source data at all (documented in each file's own header
  comment) — built with only the attributes that have real data, nothing fabricated.
- **Composite/synthetic keys** (e.g. `LOCATION_CODE_KEY` built from address text when no
  real location code exists) carry a real fragility: two different spellings of the same
  address won't dedupe to one location. Accepted trade-off, not fixed — flagged in the
  relevant `stg2_*.sql` file headers.
- **`_archive/`'s hash values will never match this build's.** If anything ever needs to
  reconcile against the old hand-written build's already-loaded data, that's a real
  migration exercise, not a drop-in replacement.

## Data model reference

`data_5a.js` (project root, one level up from `health_dv_dbt/`) is the **current canonical
model** — 20 hubs / 71 links / 363 satellites / 54 refs. `data_v4.js` and `data_v5.js` in
the same location are superseded (kept for audit-trail purposes — see
`docs/MAPPER_NOTE_V5_MODELSYNC.md` and `docs/MODELER_DECISIONS_HEALTH.md` for what changed
between them and why). If a newer `data_*.js` shows up, diff it against `data_5a.js` before
assuming this build's model reference is still current — that's exactly how the last two
model-sync rounds in this project's history got caught.

## Supporting documentation

Everything in `docs/` is still relevant unless marked otherwise — this build's satellites,
hub keys, and link definitions all trace back to the mapping decisions documented here, not
just to `data_5a.js` in isolation.

- `docs/automate_dv_build/README.md` — the detailed generation notes for the
  `automate_dv/standard` + `augmented` build (this is the deep-dive version of this README's
  architecture section).
- `docs/HEALTH_DV_BUILD_NOTES.md` — build notes for the **archived** hand-written build.
  Historical only; the join-stitch and hub-key-discovery *methodology* it documents is still
  what this build reuses, but its file-level specifics (paths, materializations) describe
  `_archive/`, not the active tree.
- `docs/MAPPER_QUESTIONS*.md`, `docs/MAPPER_NOTE_V5_*.md`, `docs/MODELER_*.md` — the mapper/
  modeler Q&A trail. `MAPPER_NOTE_V5_MODELSYNC.md` and `MODELER_DECISIONS_HEALTH.md` are the
  most recent and most load-bearing — they document the `data_5a.js` changes this build's
  M2/M4 pieces implement directly.
- `docs/appendix_*.csv` — hub/link/satellite build coverage, discovered keys, mapper
  resolutions, subject-attribution corrections, satellite exclusions. Audit trail for *why*
  a given key/exclusion decision was made; still accurate for the underlying facts even
  though some were originally generated against the archived build's file names.
- `docs/prototype_automate_dv/` — notes for the archived early prototype. Historical only.
