# Mapper replies — Travel LOB, round-2 follow-up

Response to `MAPPER_FOLLOWUP_ROUND2_TRAVEL.md`. Your discrepancy checks were right on every
count — you caught that several fixes I described as "applied to the workbook" only ever lived in
a JSON field the workbook didn't render. That's a real process gap, not a one-off; I've fixed the
root cause so it can't recur. Details below, and the refreshed workbook now carries the keys as
structured columns.

## Root cause of the discrepancies — fixed

You (and the Partner round-2 build before this) were right: my reply prose said "key added / rule
added / annotated in the mapping," but the workbook's `Source→Target` / `Target→Source` sheets only
ever printed `satellite.attribute` — the `key_name` field where I put every key, join, and unpivot
rule was **never rendered**. So the fixes were real in the JSON and invisible in the `.xlsx` you
build from. That's on me.

**Fixed:** `Source→Target` now has a dedicated **"Key / Grain / Join"** column that renders the key
for every row — hub keys, the full-address content hash, the degenerate txn key, the fan-out join
condition, and the unpivot rule. Keys are now structured data in the sheet, not prose in a side
doc. Please rebuild from this `Travel_SourceToModel_Mapping.xlsx` (v3, refreshed).

## Item-by-item

**1. `SAT_COMMON_ADDRESS` key.** You built it right — full-address content hash, not pincode. My
reply's body argued exactly that; the "PINCODE key added" line in my own summary was stale wording
from the draft before your pincode challenge, and it never made it into the sheet either. Both are
corrected now: the key column shows the full-address hash. Your call stands.

**2. Benefit → cover-code catalog.** You're right — I claimed the catalog existed; it didn't. It
does now: new **Benefit Catalog** sheet maps each of the 17 benefit columns to a stable cover code
+ readable name (e.g. `TRIPCANCELLATION → TRV_TRIP_CANCEL "Trip Cancellation"`). One grain note
worth applying: key each unpivoted `HUB_COVERAGE` row as **`POLICY_REF ‖ cover_code`** (policy-
scoped), not the bare cover code — the free-cover limits are per-policy, so a global benefit row
would churn its limit across every policy. The catalog sheet and the Source→Target key column both
state this. Your lowercased-column-name codes are fine as an interim; swap to these when convenient.

**3. `RIDER_PREMIUM` re-routing.** You're right — the mapping row still said
`SAT_FINTXN_PREMIUM.Gross Premium` with a contradictory key note. I only annotated it instead of
re-targeting it. **Now actually moved** to build-side `SAT_AUG_COVERAGE_RATING` (keyed `RIDER_NO →
HUB_COVERAGE`), same home as the rider rate factors — matches what you built. (This drops mapped
286, aug 47.)

**4. Trip-attribute fan-out — you're right to split it, and here's the confirmed vs held breakdown.**
I verified the actual policy-id columns on all three tables:
- **`BA_TRV_DATA_POLICY_DTLS_MV` — BUILDABLE.** It **does** carry its own `POLICY_REF`, the same
  column name as `BJAZ_TRV_LOADER_DATA_MV.POLICY_REF` (and it's distinct from the `CFT_MST_POLICY_REF`
  master ref on the same table). So the fan-out join is `POLICY_REF = POLICY_REF` — a same-named
  business-key join, as safe as any in this project. Build it: replicate its trip attrs to each
  `POLICY_REF ‖ MEMBERn` traveller. The key column now states this join explicitly.
- **`BJAZ_TRV_DETLS_EXTN` and `BJAZ_TRV_RIDER_DTLS_MV` — HOLD, you're correct.** Neither carries
  `POLICY_REF`. `DETLS_EXTN` has `CONTRACT_ID`/`TRAVEL_REQ_NO`; `RIDER_DTLS` has `TRV_DATA_NO`.
  Joining either to the loader's `POLICY_REF` needs a **data-confirmed value-space match**, which
  I can't verify from schema alone — exactly your objection, and I won't fabricate the join. These
  rows are now flagged **HOLD — do not build until confirmed** in the key column. This is the same
  data-dependent class as the 10th-table check (see below).

**5. Your stage-filename collision bug.** Good find, and thank you for the honesty — that
independently explains why the `TRANSITFROM`/`TRANSITTO` mis-key happened and why the
pincode-vs-full-address catch surfaced. The new verification check (declared payload/child-key
columns validated against the *union* of all listed source stage files, not just the primary key)
is the right guard; nothing needed from me on it. Agreed on the 5 affected hubs and the
`SAT_AUG_PRODUCT_TERMS` attribute loss.

**6. Everything you implemented as-specified** (`AGENTEMAILID`, AREA → product-keyed
`SAT_AUG_PRODUCT_TERMS`, `SAT_AUG_COVERAGE_RATING`, degenerate txn key unblocking the FINTXN family,
`MODEOFTRANSPORT`/`ALTITUDE` fan-out on the loader's own `POLICY_REF`) — all correct, no changes.

## Now blocked on real data — three items, same root cause

None of these can move without sample-data access (a profiling query on the real tables). They're
not modeling disagreements — we agree on the shape; we just can't confirm the data:

1. **`BJAZ_TRV_MEMBER_DTLS_EXTN.MEMBER_ID`** — distinct-values-per-policy: positional (1..n) →
   re-key travellers on the real key; global surrogate → separate per-member feed.
2. **`BJAZ_TRV_DETLS_EXTN.CONTRACT_ID`/`TRAVEL_REQ_NO`** = `BJAZ_TRV_LOADER_DATA_MV.POLICY_REF`?
   (needed to build that table's trip-attribute fan-out).
3. **`BJAZ_TRV_RIDER_DTLS_MV.TRV_DATA_NO`** = the loader's `POLICY_REF`? (same, for rider trip
   attrs).

A single profiling pass over those three tables answers all three. Everything else in Travel is
build-ready and validates clean vs `data_5b` (286 mapped / 47 build-side, 0 invalid / 0 collapse).
