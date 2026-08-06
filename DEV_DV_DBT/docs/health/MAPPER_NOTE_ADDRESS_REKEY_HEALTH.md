# Follow-up note for the mapper — re: `HUB_LOCATION` address rekey (Health, 17 tables)

**Status: CLOSED.** All 17 tables built and verified end-to-end, per your reply in
`MAPPER_REPLY_ADDRESS_REKEY_HEALTH.md`. Applied the full-address content-hash key rule from
`ADDRESS_KEY_FIX_HEALTH.md` / `Health_address_rekey.csv`. One real, pre-existing bug of
exactly the shape you described was also found and fixed along the way.

**Addendum (per your reply):** `BJAZ_HM_COINSU_CLM_DTLS` is now built — the mix-up was on our
side (we were looking for `NETWORK_STATE`, which doesn't exist; your list correctly specified
plain `STATE`). `NETWORK_CITY`/`STATE` weren't exposed in this build's staging model even
though they exist on the raw source, so both were added there first, then the 17th
`rekey_branch` entry was built keyed on the content hash of `NETWORK_CITY | STATE` — a coarse
city/state grain, no street or pincode on this table, same as you flagged. Confirmed noted
and applied: no party anchoring added for any of the 16 union-only tables (location-dedup
only, per your point 3) — happy to produce the M4-candidate list as a separate future pass if
that's ever wanted.

---

## 1. A bug of your own description, found in the existing build — `BJAZ_HM_HOSPITAL_MASTER`

Not one of the 17 you listed as needing a change, but it had precisely the problem your note
describes: `HUB_LOCATION` was keyed bare on `PIN_CODE` (inside `stitch_common_address.sql`'s
`code_branch` FULL OUTER JOIN chain), so every hospital sharing a pincode was collapsing onto
one `SAT_COMMON_ADDRESS` row. Removed from that join, rebuilt as its own branch keyed on the
content hash of `ADDRESS1|ADDRESS2|CITY_NAME|STATE_NAME|PIN_CODE`. Same bug class we caught
in Travel's `TRANSITFROM`/`TRANSITTO` stage files earlier — worth a general note that this
key shape (bare pincode, no full-address hash) may be worth a sweep elsewhere if it turns up
again.

## 2. 15 of the remaining 16 tables built (the 16th, `BJAZ_HM_COINSU_CLM_DTLS`, is section 3)

Each keyed on the content hash of whatever address parts it actually has (order: Building/
Door, Street, Locality, City, District, State, Postal Code, Country — upper/trim, drop
nulls; degenerates to a single column where only one part exists, e.g.
`BJAZ_HM_HOSP_MASTER_EXTN1` on `AREA` alone). Full per-table column list in
`Health_address_rekey.csv`; the branches now live in `stitch_common_address.sql`'s
`rekey_branch`.

Two tables carry more than one genuinely distinct address on the same row and were built as
**two separate branches each**, not conflated:
- `BJAZ_HG_POL_DTLS` — current/permanent address vs. dispatch/mailing address (different
  column prefixes, `DISP_*`/`MAILING_PINCODE` vs. the base columns).
- `BJAZ_TPA_CLAIM_DETAILS_WS` — customer/insured address (`ADDRESS`/`INS_CITY`/`INS_STATE`)
  vs. the hospital's address (`HOSPITAL_CITY`/`HOSPITAL_STATE`). Note this table already had
  a third, separate address subject built earlier (the `payee` M4 route via
  `LNK_PARTY_LOCATION`) — untouched here, it's a different row-level subject from either of
  these two.

Two already-built M4 party-address tables (`BA_HCP_PP_MEM_DTLS`, `BJAZ_HAT_ID_MEM_DETLS`)
were previously keyed on a single free-text line alone, with `CITY`/`STATE`/`PIN` nulled out
even though the table has them. Both rewritten to the full content-hash key with those
columns now populated as real attributes.

**A scoping simplification confirmed by your reply**: this build (all 15 union-only tables in
`rekey_branch` plus `BJAZ_HM_COINSU_CLM_DTLS` below) does not anchor to a party key — that's
only required for the `LNK_PARTY_LOCATION` route (the M4 pattern), and per your point 3 this
fix is location-dedup only and deliberately doesn't revisit that. Noted for a possible future
pass: if member/customer/hospital address-by-party is ever wanted, we can produce a list of
which of these tables carry a usable party key as M4 candidates — not attempted here.

## 3. Now built — `BJAZ_HM_COINSU_CLM_DTLS` (17th branch, closed per your reply)

Your rekey list targets `NETWORK_CITY | STATE` — the mismatch on our side was reading
`STATE` as `NETWORK_STATE`; both columns are confirmed real on the raw source. Neither was
exposed in this build's staging model, so both were added there first (`network_city`,
`state`), then the 17th `rekey_branch` branch was built keyed on the content hash of
`NETWORK_CITY | STATE` — a coarse city/state grain, no street or pincode on this table, per
your caveat. All 17 tables in the original list are now built.

## 4. Verified, not just generated

`stg2_common_address.sql` (the stage-on-stitch that hashes `LOCATION_HKEY`) and the
downstream `hub_location.sql`/`sat_common_address.sql` are all unchanged in shape — they
already read from the stitch's output, so the new keys flow through without any edit at that
layer. Confirmed directly, not assumed: every one of the rekey's 21 `ref()` targets resolves
to a real staging model, and every column referenced in a generated key expression was
spot-checked against that model's actual output columns (not just trusted from the mapping
sheet).
