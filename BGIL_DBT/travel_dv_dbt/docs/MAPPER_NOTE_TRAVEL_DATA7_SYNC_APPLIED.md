# Follow-up note for the mapper — re: MAPPER_NOTE_TRAVEL_DATA7_SYNC.md

Applied. Two of the three items were already correct in this build; one real action item
(the discount fold) is done.

---

## 1. `DISCOUNT_PER` → `SAT_FINTXN_PREMIUM.Discount Percentage` — folded

Moved `DISCOUNT_PERCENTAGE` (source: `BA_TRV_DATA_POLICY_DTLS_MV.DISCOUNT_PER`) out of
`SAT_AUG_FINTXN_PREMIUM` and into canonical `SAT_FINTXN_PREMIUM`. Folded it directly into
the existing per-table stage file for that branch rather than adding a new one — same
table, same row, same `HUB_FINANCIAL_TRANSACTION` key, no reason for a separate branch.
`SPECIAL_DISCOUNT_AMOUNT`/`SPECIAL_DISCOUNT_PERCENTAGE` stay in the augmented satellite as
instructed.

## 2. `SAT_FINTXN_TAX` child key — already correct, nothing to do

Checked this satellite directly before touching anything: it already carries `TAX_TYPE`
with real, non-blank literals per branch (`'cess'` for `EDU_CESS_AMT`, `'service_tax'` for
both `SERVICE_TAX_AMT` and the second table's `SERVICETAX`) — including the exact
two-sources-same-tax-type dedup shape your note describes. This predates the recent
cross-LOB rekey pass (that one only touched `SAT_FINTXN_COMMISSION`/`SAT_FIN_CHARGE_RATE`/
`SAT_POLICY_PREMIUM_HEAD` per `MAPPER_NOTE_MULTIACTIVE_REKEY.md`) — this satellite was
built correctly from round 2 onward and never had the blank-literal collision bug that
turned up elsewhere.

## 3. `SAT_FIN_CHARGE_RATE` / `SAT_FINTXN_COMMISSION` — confirmed matching

Your note says the charge-rate fix "matches your applied split" — confirmed, byte-for-byte
against the literals already in place from the cross-LOB rekey round (`'Additional
Loading'` / `'Service Charge'` / `'Standard'`). No change needed.

## Verified

Dependency-resolution + `src_pk`/`hashed_columns` sweep re-run clean after the discount
fold: 0 dangling refs, 0 mismatches, across all 295 `.sql` files in this project (one fewer
than before — removed the now-redundant augmented stage file for `DISCOUNT_PER`).
