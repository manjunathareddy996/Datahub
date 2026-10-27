# Travel LOB — follow-up to mapper feedback round 2

Response to `MAPPER_REPLIES_TRAVEL.md`. Everything below was checked against the actual
re-exported `Travel_SourceToModel_Mapping.xlsx` (not just the reply's prose) before being
implemented — a couple of the reply's claims turned out not to be reflected in the actual
workbook rows, called out explicitly below rather than silently assumed.

## Implemented as specified

- **`AGENTEMAILID` re-anchor** — confirmed, unchanged.
- **`AREA` mistargeting** (§2) — moved off `SAT_RISK_PERSON_TRAVEL` to build-side
  `SAT_AUG_PRODUCT_TERMS.Plan Geographical Zone`, keyed via each table's own `HUB_PRODUCT` key
  (`BJAZ_TRV_PLAN_MV.PLAN_ID`, `BJAZ_TRV_RATE_MASTER_MV.PLAN`).
- **Rider rate columns mistargeting** (§2) — new `SAT_AUG_COVERAGE_RATING`, keyed
  `RIDER_SEQ_NO → HUB_COVERAGE`, plus `RIDER_PREMIUM` (same disposition, `RIDER_NO` key).
- **`SAT_COMMON_ADDRESS` full-address key** (§3A) — implemented per the *body text's*
  reasoning (content hash of the full normalized address), not the "PINCODE key added" line
  in the reply's own "Applied to workbook" summary — see discrepancy note below. This also
  surfaced a genuine bug in our own earlier build (see "Bugs found" below).
- **Degenerate financial-transaction key** (§3B) — added for `BJAZ_TRV_LOADER_LOG_TABLE_MV`
  (reuses `POLICYNUMBER`, same pattern as the existing `HUB_RISK_OBJECT` degenerate key).
  Unblocked `SAT_FINTXN_PREMIUM`, `SAT_FINTXN_HEADER` (new), `SAT_FINTXN_TAX`,
  `SAT_FIN_CHARGE_RATE`, and the `SPDISCOUNT` augmentation on that table.
- **17-column wide-benefit unpivot** (§3C) — implemented, see discrepancy note below on the
  benefit-code catalog.
- **`MODEOFTRANSPORT`/`ALTITUDE` fan-out** (§4) — built as new `SAT_AUG_RISK_PERSON_TRAVEL`,
  fanned out across the same 5 traveller composites as the DOB augmentation. This was
  straightforward because the source table (`BJAZ_TRV_LOADER_DATA_MV`) already carries its
  own `POLICY_REF` — no cross-table join needed.

## Discrepancies between the reply text and the actual re-exported workbook

Same pattern noticed once before in the Partner LOB build (round 2 there) — the reply
document describes fixes as "applied to the workbook," but a few of them aren't actually
present as structured rows in the re-exported `.xlsx`. Not a criticism, just flagging so
nothing gets silently assumed twice:

1. **`SAT_COMMON_ADDRESS` key** — the reply's "Applied to workbook" summary says "`PINCODE`
   key added," but the body text explicitly argues *against* pincode-alone and specifies a
   full-address content hash instead, and the actual `Target→Source` sheet still shows no
   `KEY:HUB_LOCATION` row with `PINCODE` added at all. Built per the body's reasoning (full
   address hash) since it's both more specific and the only one that actually holds up —
   pincode-alone would still collapse many distinct addresses onto one row, exactly as the
   reply itself explains.
2. **Benefit→cover-code catalog** — the reply says the mapping "now carries the
   key-derivation rule + the benefit→cover-code catalog." The actual `Source→Target` rows for
   all 17 benefit columns are unchanged from before (still just `benefit=<COLUMN_NAME>` in
   the Rationale field, no separate catalog sheet or column). Built using the raw column name
   (lowercased) as the benefit code. If a cleaner catalog exists, please share it and we'll
   re-key — low effort to swap once we have real codes.
3. **`RIDER_PREMIUM` re-routing** — the reply says "Rider premium → coverage-level → build-side
   on coverage." The actual `Source→Target` row for `RIDER_PREMIUM` still shows `Model Target
   = SAT_FINTXN_PREMIUM.Gross Premium` (its original, unbuildable target). Applied the
   reply's stated *intent* anyway (moved to `SAT_AUG_COVERAGE_RATING`), since the table
   genuinely has no `HUB_FINANCIAL_TRANSACTION` key and the reasoning is sound — but please
   update the actual mapping row so it's on record, not just in a reply doc.
4. **Trip-attribute fan-out annotations** — the reply says these are "annotated in the
   mapping." The `Source→Target` rows for `BA_TRV_DATA_POLICY_DTLS_MV`/`BJAZ_TRV_DETLS_EXTN`/
   `BJAZ_TRV_RIDER_DTLS_MV`'s trip attributes are unchanged — still plain
   `SAT_RISK_PERSON_TRAVEL.<attr>` with no fan-out mechanism or join key specified. This is
   the one item we did **not** build (see below) — specifically because there's nothing
   concrete in the actual workbook to build it *from*.

## Not implemented — needs a real join key, not just intent

**Trip attributes on tables with no `POLICY_REF` of their own** (`BA_TRV_DATA_POLICY_DTLS_MV`:
Destination, Trip Duration, Visa Type, Geographical Zone code/name; `BJAZ_TRV_DETLS_EXTN`:
Trip Start/End Date, `TRP_DLY_PRM`; `BJAZ_TRV_RIDER_DTLS_MV`: Trip Duration). The fan-out
instruction ("fan the trip attributes out to each enumerated traveller's `HUB_RISK_OBJECT`")
makes sense conceptually, but these three tables don't carry `POLICY_REF` — their own policy
identifiers are `TRV_DATA_NO` (`BA_TRV_DATA_POLICY_DTLS_MV`), `CONTRACT_ID`/`TRAVEL_REQ_NO`
(`BJAZ_TRV_DETLS_EXTN`), and `TRV_DATA_NO` (`BJAZ_TRV_RIDER_DTLS_MV`). Fanning these out to
`BJAZ_TRV_LOADER_DATA_MV`'s traveller composites requires a **cross-table join** — matching
one of these policy identifiers against `BJAZ_TRV_LOADER_DATA_MV.POLICY_REF` — and this build
has no confirmation that those value spaces are actually the same policy identifier under a
different column name (as opposed to, say, `TRV_DATA_NO` being a different kind of reference
that happens to also relate to a policy).

**Question**: is `TRV_DATA_NO`/`CONTRACT_ID`/`TRAVEL_REQ_NO` on these three tables guaranteed
to equal (or be derivable to) the same `POLICY_REF` value used on `BJAZ_TRV_LOADER_DATA_MV`
for the same real policy? If yes, please add an explicit join-key row to the mapping (or
confirm here) and we'll build the fan-out. If the relationship is more complex (e.g. via an
intermediate table, or not 1:1), that's worth knowing before we build anything — we'd rather
ask than fabricate a join between two identifiers we can't confirm are the same thing.

## Bug found independently (not from the reply's reasoning, but in the same area)

While rebuilding `SAT_COMMON_ADDRESS`'s key, found that our own earlier build had a
stage-filename collision bug: whenever a hub had 2+ business-key columns on the *same*
source table (5 hubs affected: `HUB_DISTRIBUTION_CHANNEL`, `HUB_LOCATION`, `HUB_ORG_UNIT`,
`HUB_PARTY`, `HUB_PRODUCT`), the generator wrote each column's stage file to an identical
filename, so only the last-processed column's key actually survived — e.g.
`BJAZ_TRV_LOADER_LOG_TABLE_MV`'s `HUB_LOCATION` hub was only ever populated from `TRANSITTO`,
never `TRANSITFROM` (and `SAT_COMMON_ADDRESS` was consequently keyed off `TRANSITFROM` by
accident — the actual bug that made your PINCODE-vs-full-address catch necessary in the
first place). Same bug independently reappeared in the augmented-track generator
(`SAT_AUG_PRODUCT_TERMS` silently lost 2 of its 3 attributes). Both generators fixed, all
affected hubs/satellites rebuilt, and a new verification check (declared payload/cdk columns
checked against the union of all listed source stage files, not just the primary key) now
runs against the whole project to catch a recurrence.

## Still pending on both sides

- **`BJAZ_TRV_MEMBER_DTLS_EXTN` (10th table)** — you need a `MEMBER_ID` distinct-values-per-
  policy profile; we don't have sample data access to check this independently either. Held,
  as agreed.
