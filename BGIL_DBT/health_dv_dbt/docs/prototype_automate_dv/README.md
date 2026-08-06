# AutomateDV prototype — HUB_LOCATION / SAT_COMMON_ADDRESS / SAT_PARTY_ADDRESS_USAGE

Evaluation prototype only. Nothing here replaces or is read by the production
`staging` / `intermediate` / `raw_vault` models — it's a self-contained parallel build
under `models/prototype_automate_dv/`, schema `proto_automate_dv`. Not yet `dbt deps`'d or
run — dbt isn't available in this environment (same limitation as the rest of the project
so far); everything below has been hand-checked for correctness but not compiled against
Snowflake.

## The convention this follows

**Staging is 1:1 per source table.** Every `stage()` model reads exactly one upstream
model (either an existing production `stg_health__*` view, or — for the one table that
needs a row reshape, not a join — a tiny single-table unpivot view) and computes that
table's own hash keys and hashdiff inline. `hub()` and `link()` then take a **list** of
these per-table stage outputs and union/dedupe them natively — this is documented,
first-class AutomateDV behaviour, not something hand-rolled.

This replaces the custom "harmonized union view" from the first draft of this prototype,
which pre-joined multiple tables by hand before staging. That draft worked but didn't
match how AutomateDV is actually meant to be used — staging should stay per-table, and
hub/link/sat macros should do their own consolidation from a list.

## File map

- `macros/location_address_key.sql` — reference/documentation for the normalisation rule
  (trim/upper, pipe-delimited). Not invoked from YAML metadata (fragile — a Jinja macro
  call embedded inside a `fromyaml()`-parsed string risks breaking on the macro's own
  quotes/parens); each per-table stage model writes the same expression inline instead,
  audit-ability over cleverness.
- `models/prototype_automate_dv/staging/` — one `stage()` model per source table:
  - `stg2_ba_hcp_pp_mem_dtls.sql`, `stg2_bjaz_hat_id_mem_detls.sql`,
    `stg2_bjaz_tpa_claim_details_ws_payee.sql` — read the existing production staging
    models directly.
  - `unpivot_bjaz_bandhan_medi_clam_address.sql` + `stg2_bjaz_bandhan_medi_clam_address.sql`
    — the one exception: this table carries 2 addresses per row (permanent/mailing), so a
    single-table row-reshape has to happen before `stage()` can map column-to-column. Still
    1 source table in, 1 output — not a cross-table join.
  - `stg2_common_address_stitched.sql` — NOT a per-table model. The one `stage()` pass for
    the whole location-stitch cluster; see "the one exception" below. There is deliberately
    no individual `stg2_*_location.sql` for `BJAZ_EHH_POL_DTLS` / `BJAZ_HM_HCM_EXTRACT` /
    `BJAZ_HM_HOSPITAL_MASTER` — those 3 tables are attribute-joined, so they're read straight
    from raw production staging inside the stitch, never given their own stage() model.
- `models/prototype_automate_dv/hubs/` — `proto_hub_party.sql`: `hub()` fed directly from a
  **list** of 4 per-table stage outputs. `proto_hub_location.sql`: `hub()` fed from a list
  of **5** sources — the 4 party stage outputs directly, plus `stg2_common_address_stitched`
  standing in for the 3 attribute-joined tables (see routing rule below). Neither has any
  custom SQL of its own.
- `models/prototype_automate_dv/satellites/` —
  - `proto_ma_sat_party_address_usage.sql` — `ma_sat()` fed directly from a **list** of the
    4 party-address stage outputs (row-union, no attribute merging needed — see file
    comment for the one unverified assumption here).
  - `proto_sat_common_address.sql` — `sat()` fed from the stitched output (see below).
- `models/prototype_automate_dv/stitched/stitch_common_address.sql` — **the one genuine
  exception** to "stage() per table, feed hub/link/sat directly."

## Why `SAT_COMMON_ADDRESS` needs an extra step and nothing else does

`hub()`/`link()`'s multi-source union — and, if the unverified assumption above holds,
`ma_sat()`'s too — only **stacks whole rows**. `SAT_COMMON_ADDRESS` needs
**attribute-level merging**: one of the 3 code-keyed tables might have `city` but not
`postal_code` for the same location, and both need to land on the same output row.
AutomateDV has no macro for that.

Important correction from the first version of this section: there is **no per-table
`stage()` model for an attribute-joined table**. `stitch_common_address.sql` reads the 3
code-keyed tables' *raw production staging* directly (`stg_health__*`, the plain 1:1 cast
layer — not an AutomateDV `stage()`) and joins on the **raw** business key
(`RISK_LOCATION`/`POLICY_LOCATION`/`PIN_CODE`), not a hash — there's nothing to hash until
after the join produces one clean row per location. The 4 party-address tables are only
`UNION`'d into the same view (not joined), so they *do* come from their own per-table
`stage()` outputs, contributing their raw `LOCATION_CODE_KEY` (not the already-hashed
`LOCATION_HK`) so both branches land in the same unhashed shape.
`stg2_common_address_stitched.sql` is the **one and only** place `LOCATION_HK` gets hashed
for this whole cluster — a single `stage()` pass on top of the stitch, computing both the
hash key and `HASHDIFF` together, once, after every table's contribution has already been
joined/unioned into one row per location.

This mirrors the original design discussion's conclusion: hub/link should feed off plain
per-table staging, and only satellites that genuinely need cross-table attribute merging
get a thin custom step — not a blanket harmonization layer for everything.

## Routing rule: attribute-joined vs. unioned

Confirmed rule for the full migration, not just this cluster: **a table only has to be
routed through a stitch view if it's attribute-*joined*** (its columns get `COALESCE`d
against another table's columns for the same key, like the 3 code-keyed `SAT_COMMON_ADDRESS`
tables). Once that join happens, reading the table's individual `stage()` output separately
anywhere else would bypass the coalesce/dedupe the stitch exists for — so `hub()`/`link()`
read it *only* via the stitch (see `proto_hub_location.sql`).

A table that's only ever **unioned** into a stitch (row-stacked, no `COALESCE`, like the 4
party-address tables in `stitch_common_address.sql`'s `composite_branch`) doesn't have this
problem — nothing is lost by also reading its `stage()` output directly elsewhere, and
`hub()`/`link()`/`ma_sat()` already union natively, so there's no need to route it through
a stitch just because it happens to appear in one. `proto_hub_party.sql` and
`proto_ma_sat_party_address_usage.sql` both read the 4 party tables' `stage()` outputs
directly, not through `stitch_common_address`.

Applying this at full scale: only the **44 satellites that need attribute-level joins**
(see the design-discussion count) get a stitch view; hub/link keys for tables inside one of
those 44 stitches are sourced from the stitch's output, not read a second time directly.
Every other source table (union-only or single-table satellites, and anything feeding a
hub/link that isn't part of a stitch) is a plain `stage()` model referenced directly.

## Synthetic keys are an expected, not exceptional, output of this pattern

`LOCATION_CODE_KEY`'s composite-text form (`stg2_ba_hcp_pp_mem_dtls.sql` etc.) is a
**synthetic key** — invented because no source table gives these 4 party-address rows a
real location code, not derived or discovered from anything the source system issues. This
is a natural, expected consequence of staging-level hashing: once a satellite's payload
*is* a hash key (like `Location Reference`), that hash has to come from somewhere, and if
the source genuinely has no usable key, the alternative to a synthetic one is leaving the
attribute unbuilt — same choice as always in this project, just showing up more often now
that AutomateDV pushes the hashing decision earlier, into staging, where the "no real key"
gap is immediately visible instead of surfacing later.

Treated as a new, explicit provenance category alongside the existing
`explicit` / `discovered` / `confirmed` / `reanchor` tags used elsewhere in this build:
**`synthetic`** — a key invented from available attribute columns, not sourced from or
confirmed by anything the mapper or source system provides. Every synthetic key must be
called out as such (as `LOCATION_CODE_KEY`'s composite form is here), never silently
presented as if it were a real business key, and its fragility (e.g. two spellings of the
same address won't collapse to one key) documented alongside it.

## Scope, deliberately narrowed

- `proto_hub_location` covers 7 of production's 18 source-table branches, `proto_hub_party`
  covers 4 of ~20. Enough to prove the list-union pattern; extending to the rest means
  adding more `stage()` models to the same lists, not a new mechanism.
- `proto_sat_common_address` covers 3 of production's 6 `SAT_COMMON_ADDRESS` tables.
- Only mapper-confirmed source columns are used. Several tables have address-shaped
  columns sitting right next to the mapped ones that were never tagged by the mapper
  against this satellite (e.g. `BJAZ_HAT_ID_MEM_DETLS.CITY/STATE/PIN`,
  `BA_HCP_PP_MEM_DTLS.DC_CITY/DC_STATE/DC_PINCODE`) — not assumed here, same "don't
  fabricate a key/mapping" rule as everywhere else in this build. Worth a mapper question,
  separately from this prototype.
- `SAT_PARTY_ADDRESS_USAGE`'s remaining canonical gaps (`Role Context`,
  `Preferred Indicator`, `Effective From Date`) are still gaps — no source column exists
  for them on any of the 4 tables. `SEQUENCE_CK` is a constant `'1'` placeholder since no
  table has genuine multiple addresses per usage type to sequence.
- No explicit "business key is not null" filter in the code-keyed staging models (unlike
  the production intermediate layer, which filters at every branch) — relying on `hub()`'s
  documented behaviour of excluding NULL/empty `src_nk` rows itself. Unverified without a
  real compile; flagged in the relevant file.

## What this does and doesn't decide

Confirms the per-table staging + macro-union pattern is mechanically sound, solves the
`Location Reference` problem without a join, and needs a custom step in exactly one place
(genuine attribute-level merging), not as a general pattern. Does **not** yet answer
whether the composite-address-key approach is an acceptable trade-off given its
key-fragmentation risk (two spellings of the same address won't dedupe) — that's a
data-quality call, not an architecture one, and still needs a decision before this pattern
goes into the real build.
