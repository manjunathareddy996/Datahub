**Status: superseded by `MAPPER_NOTE_TRAVEL_DATA7_SYNC_APPLIED.md`**, which confirms this
work and closes the one flagged item below (the `SAT_AUG_FINTXN_PREMIUM` discount fold).
Kept for the original context.

# Follow-up note for the mapper — re: MAPPER_NOTE_MULTIACTIVE_REKEY.md (Travel)

Applied. This LOB writes two of the three rekeyed satellites, and `SAT_FIN_CHARGE_RATE` had
a real, pre-existing collision bug — same class as the one found in Health's
`SAT_POLICY_PREMIUM_HEAD` while applying this same note there.

---

## `SAT_FINTXN_COMMISSION` — straightforward, no collision found

Converted `sat()` → `ma_sat()`, child key `COMMISSION_TYPE_CK`. Two contributing tables
(`BA_TRV_DATA_POLICY_DTLS_MV`, `BJAZ_TRV_LOADER_DATA_MV`), neither with a real
commission-type discriminator, so both use the literal `'Standard'`. Different `transaction_
id`/`transactionid` namespaces per table mean no cross-table collision risk in practice.

## `SAT_FIN_CHARGE_RATE` — a real bug, found because of your note

`BA_TRV_DATA_POLICY_DTLS_MV` was forcing two genuinely different charge concepts onto one
row with **no discriminator at all** (this satellite had no child key declared before this
rekey, so it wasn't even a stale-literal case like Health's — the two concepts were just
merged):

- `LOADING_PER` → Additional Loading Rate
- `SERVICE_CHARGE` → Charge Amount

Split into two branches (`'Additional Loading'` / `'Service Charge'`).
`BJAZ_TRV_LOADER_LOG_TABLE_MV`'s existing single-column contribution keeps the
`'Service Charge'` literal, since it's the same charge concept from a different table.
**Please sanity-check**: if `LOADING_PER` and `SERVICE_CHARGE` are actually meant to be
read together as one charge line (not two), let me know and I'll recombine them.

## Flagged, not folded: `SAT_AUG_FINTXN_PREMIUM`'s `DISCOUNT_PERCENTAGE`

Your note's secondary "also live in `data_7`" section says `SAT_FINTXN_PREMIUM` gained
canonical `Discount Percentage`/`Discount Description` attributes, foldable from build-side
augmentation if a LOB already had them — and this LOB does: `SAT_AUG_FINTXN_PREMIUM` already
carries `DISCOUNT_PERCENTAGE`. I didn't fold it, on purpose: the same augmented satellite
also carries `SPECIAL_DISCOUNT_AMOUNT`/`SPECIAL_DISCOUNT_PERCENTAGE`, a related but distinct
concept your note doesn't mention a canonical home for, and pulling just one of three
related columns out felt like it would leave the augmented satellite in a half-migrated
state rather than a clean one. Your note frames this whole item as "no action, just
awareness," so I left it — but it's a real, available win if you want it done. Say the word
and I'll fold `DISCOUNT_PERCENTAGE` into canonical `SAT_FINTXN_PREMIUM` and leave the two
special-discount columns in the augmented satellite.

## Verified

Dependency-resolution + `src_pk`/`hashed_columns` sweep re-run clean after all changes: 0
dangling refs, 0 mismatches, across all 296 `.sql` files in this project.
