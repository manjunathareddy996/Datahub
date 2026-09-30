# Follow-up note for the mapper — re: `HUB_LOCATION` address rekey (Partner, 5 tables)

**Status: CLOSED.** Confirmed with no changes needed, per `MAPPER_REPLY_ADDRESS_REKEY_PARTNER.md`
(including the cross-LOB note that `BJAZ_HM_HOSPITAL_MASTER`'s Health-side bug — see the
Health note — never existed on the Partner side; Partner's `code_branch` was already correct).

Applied the full-address content-hash key rule from `ADDRESS_KEY_FIX_PARTNER.md` /
`Partner_address_rekey.csv` across all 5 tables. All built and verified end-to-end — no
open items on this one, unlike the Health side.

---

## What changed

`stitch_common_address.sql` already existed for Partner with a correctly-keyed `code_branch`
(6 tables, all on real location-id/pincode columns — `AZBJ_ADDRESS_EXTN.ADD_ID`,
`BJAZ_CLM_SUPP_EXTN.BILLING_LOC`, `BJAZ_CP_ADD_HIST.ADD_ID`, `BJAZ_PINCODE`/
`BJAZ_PINCODE_MASTER.PINCODE`, `CP_ADDRESSES.ADD_ID`); no bug found there, unlike Health's
`BJAZ_HM_HOSPITAL_MASTER`. Your 5 tables had no `HUB_LOCATION` contribution at all before
this round — added as a new `composite_branch`, unioned alongside the existing one:

- `BJAZ_HM_MEMBER_DTLS` — `ADDRESS|CITY|STATE|PIN`
- `BJAZ_SH_MEM_DTLS_EXTN` — `ADDRESS` alone (degenerate single-column key, only part present)
- `BJAZ_CTNGY_GC_MEM_DATA` — `INSURED_ADDRESS` alone
- `BJAZ_HM_HOSPITAL_MASTER` — `ADDRESS1|ADDRESS2|CITY_NAME|STATE_NAME|PIN_CODE`
- `BJAZ_CTNGY_PA_MEM_DTLS` — **two separate branches**, not conflated: the member's own
  address (`HOUSE_NO|STREET_NAME|MEM_ADDRESS|CITY|STATE|PIN_CODE`, the finer-grained one) and
  the assignee's (`ASSIGNE_ADDRESS` alone) — a different subject on the same row, with only
  one free-text line and no city/state/pin of its own. We did not borrow the member's
  city/state/pin for the assignee's key; that would have fabricated data the row doesn't
  actually carry for that subject.

## Verified, not just generated

`stg2_common_address.sql` and the downstream `hub_location.sql`/`sat_common_address.sql` are
unchanged — they already read from the stitch's output, so the new branch flows through
without any edit at that layer. All 5 new `ref()` targets resolve to real staging models, and
every column referenced in a generated key expression was checked directly against that
model's actual output columns.
