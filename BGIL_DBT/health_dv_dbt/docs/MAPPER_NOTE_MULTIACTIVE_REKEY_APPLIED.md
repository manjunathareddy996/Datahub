**Status: extended by `MAPPER_NOTE_HEALTH_DATA7_SYNC_APPLIED.md`**, which reconciles the
`SAT_POLICY_PREMIUM_HEAD` literals here to the mapper's exact wording and fixes a
previously-unbuilt `FLOAT_PREMIUM` branch found while doing so. Kept for the original
context — the collision-bug fix and analysis below is still accurate.

# Follow-up note for the mapper — re: MAPPER_NOTE_MULTIACTIVE_REKEY.md (Health)

Applied. This LOB writes all three of the rekeyed satellites, and one of them
(`SAT_POLICY_PREMIUM_HEAD`) had a real, pre-existing collision bug your note's structural
change surfaced — worth knowing about even though it predates this rekey.

---

## `SAT_FINTXN_COMMISSION` / `SAT_FIN_CHARGE_RATE` — straightforward, no collision found

Both converted `sat()` → `ma_sat()` with the declared child key. Each has exactly one
contributing table with no real type/discriminator column, so the child key is a literal
(`'Standard'` / `'Service Charge'`) — a judgment call, not fabricated data. No existing rows
were at risk here; this is purely bringing the schema in line with `data_7`.

## `SAT_POLICY_PREMIUM_HEAD` — a real bug, found because of your note

This satellite was **already** `ma_sat()` with a child key column
(`PREMIUM_HEAD_CODE_CK`) — but every one of its 5 contributing tables had that column
hardcoded to the same blank literal `'!'`. Any policy with premium-head rows from 2+ of
those 5 tables would have silently collapsed onto one multi-active row under AutomateDV's
hashdiff tracking, discarding the rest. This is exactly the failure mode your note's opening
line describes ("multiple columns were silently overwriting each other").

Fixed with a distinct literal per table/premium-head concept. One table needed splitting,
not just relabeling: `BJAZ_GRP_HLT_MATERNITY_DTLS` was forcing two genuinely different
premium-head concepts onto one row —

- `PRIME_RIDER_BASE_PREM` → Base Amount (a rider base premium)
- `PERMIUM_CO_BUFFER` → Net Head Premium (a co-buffer premium component)

These read as different concepts, not two attributes of the same head, so I split them into
two branches (`'Maternity Rider'` / `'Maternity Co-Buffer'`) rather than pick one literal to
cover both. **Please sanity-check this split** — I inferred the concept split from the
column names; if these actually *are* the same premium head with two amount fields, let me
know and I'll fold them back into one branch.

## Not actioned: the secondary `data_7` promotions

Your note also mentions `SAT_FINTXN_PREMIUM` gaining Discount Percentage/Description and
`SAT_ASSESSMENT_HEADER` gaining Scheduled Time/Rescheduled Date-Time/Sub-Status, foldable
from build-side augmentation if a LOB already had them. Checked this build's augmented
track — nothing matches, so there's nothing to fold here.

## Verified

Dependency-resolution + `src_pk`/`hashed_columns` sweep re-run clean after all changes: 0
dangling refs, 0 mismatches, across all 1329 `.sql` files in this project.
