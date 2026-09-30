# Applied — mapper reply on Partner data_7 sync (MAPPER_REPLY_PARTNER_DATA7_APPLIED.md)

All four corrections applied. Full detail in `partner_dv_dbt/README.md` ("Round 6: mapper reply
corrections"). Verified: 420 `.sql` files, 0 dangling refs, 0 `src_pk` mismatches, and a semantic
cross-check confirming every satellite branch's hash-key formula is character-identical to its
hub's (0 mismatches across 81 checked branches — `HUB_COVERAGE`, `HUB_RISK_OBJECT` member-medical,
`HUB_FINANCIAL_TRANSACTION`). Motor confirmed untouched.

Two small things worth a quick look, not blocking:

1. **Item 2's `INTERMEDIARY_ID → HUB_PARTY` was corrected to `PARTNER_ID`.** This table's
   existing, already-built `HUB_PARTY` branch (`stg2_hub_bjaz_intermediary__party.sql`) keys on
   `PARTNER_ID`, not `INTERMEDIARY_ID` — using the literal column your reply named would have
   silently produced `SAT_PARTY_PAYOUT_PROFILE` rows that never join to any real `HUB_PARTY`
   row. Used `PARTNER_ID` so it actually joins. Flagging in case `INTERMEDIARY_ID` was meant to
   replace `PARTNER_ID` as this table's canonical `HUB_PARTY` key going forward (a bigger change
   than this satellite) rather than just a naming slip in the reply.

2. **The modeler's alternative for `SPL_TDS_RATE`** (`SAT_LNK_ROLE_AGENT.Special TDS Rate` on the
   agent party-role link) wasn't built — `SAT_PARTY_PAYOUT_PROFILE` is what's in the refreshed
   map, and building the role-link alternative needs that link keyed first, which is more work
   than this round's scope. Left as `SAT_PARTY_PAYOUT_PROFILE.TDS Rate` per the map; happy to
   switch if the role-link home is preferred.
