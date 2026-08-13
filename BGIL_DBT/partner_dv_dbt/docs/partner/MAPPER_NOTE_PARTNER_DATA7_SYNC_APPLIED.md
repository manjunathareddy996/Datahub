# Partner data_7 sync — applied, and what's genuinely open

Applied `MAPPER_NOTE_PARTNER_DATA7_SYNC.md` in full: the small folds/fixes/gaps (address
`careofname`, policy header `issuedate`, `TAX_CODE`/`NO_OF_DAYS` confirmations,
`ENDORSEMENTDATE`, the premium-head 4-column completion), and the 4 previously-unbuildable
"dense multi-active fan-in" satellites (`SAT_COVERAGE_LIMITS`, `SAT_COVERAGE_MEMBER_BENEFIT`,
`SAT_RISK_HEALTH_MEMBER_MEDICAL`, `SAT_FINTXN_TAX`). Full detail in `partner_dv_dbt/README.md`
("Round 5: data_7 full sync"). Verified clean: 347 `.sql` files, 0 dangling refs, 0
`src_pk`/`hashed_columns` mismatches.

This note only covers what's genuinely unresolved — items that need mapper/modeler input, not
things we already decided ourselves with reasonable confidence.

## 1. No resolvable key for HUB_COVERAGE or HUB_FINANCIAL_TRANSACTION

The refreshed workbook has no `KEY:HUB_COVERAGE` or `KEY:HUB_FINANCIAL_TRANSACTION` row
anywhere, and none of the ~15 tables feeding the 4 new satellites carries a usable business
key for either concept — checked directly against the Opus schema for `SECTION_CODE`/
`SCHEME_CODE`/`PARTITION_NO`/`BENEFIT_OPTED`-style columns; present on a few tables, absent on
most, no formula that covers all contributors.

We degenerated all 4 satellites to `HUB_POLICY` grain instead of inventing a new hub with an
unconfirmed key, folding the member/benefit/tax-type dimension into each satellite's own
multi-active child key. This mirrors the accepted Motor `SAT_RISK_MOTOR_IDV_TENURE` fallback.
We also considered reusing the existing `HUB_RISK_OBJECT`, but its business key
(`INS_OBJ_UID`, from `BJAZ_CLM_INTERESTED_PARTIES`) is a different concept than member-medical
identity — mixing grains under one hub would have corrupted a hub that already works, so we
didn't.

**Ask**: is there a real `HUB_COVERAGE`/`HUB_FINANCIAL_TRANSACTION` key we're missing (e.g. a
column not exposed in the Opus schema snapshot we have, or a derivation from fields we didn't
think to combine)? If not, please confirm the `HUB_POLICY`-degenerate approach is an
acceptable permanent shape, not just a stopgap.

## 2. SAT_FINTXN_TAX's TDS Rate doesn't fit the rest of the satellite

`SPL_TDS_RATE`/`TDS_RATE_IND` on `BJAZ_INTERMEDIARY`/`BJAZ_INTERMEDIARY_HIST` map to
`SAT_FINTXN_TAX.TDS Rate`, but that table has no `CONTRACT_ID` at all — it's an
intermediary/party master, not policy-grain. It can't share this satellite's degenerate
`HUB_POLICY` key with the CGST/SGST/IGST/cess columns (which come from
`BJAZ_CTNGY_PA_MEM_DTLS`, a member/policy-detail table). We left it unbuilt.

**Ask**: does TDS Rate belong on a different, party/intermediary-grain satellite (e.g.
something under `HUB_PARTY`, closer to a commission or agent-terms concept), or is there a
real transaction-level join between `BJAZ_INTERMEDIARY` and a policy/financial-transaction
table that we're missing?

## 3. SAT_RISK_HEALTH_MEMBER_MEDICAL / SAT_COVERAGE_MEMBER_BENEFIT column depth

`SAT_COVERAGE_MEMBER_BENEFIT` got full per-column branching (31 branches across 11 tables,
same pattern as Motor's `SAT_POLICY_TAX_HEAD`). `SAT_RISK_HEALTH_MEMBER_MEDICAL` did not — we
mirrored `health_dv_dbt`'s own shipped build of this satellite instead, which picks one
representative column per payload slot per table rather than branching every condition.

Several Partner tables carry noticeably more per-condition columns than Health's did — e.g.
`BJAZ_HCF_MEMBER_DTLS` has ~10 distinct disclosed-indicator flags (asthma, diabetes, heart,
hypertension, cholesterol, hyperlipidemia, other-risk, ...) and 7 distinct loading-percentage
columns, and we only picked one of each. This is consistent with an already-accepted
precedent, but it's a real simplification, not a complete capture.

**Ask**: is the one-row-per-table shape acceptable for `SAT_RISK_HEALTH_MEMBER_MEDICAL` in
Partner too, or should we invest in full per-condition branching (a real follow-up task, not a
quick fix, given the column volume)?

## 4. SAT_POLICY_ENDORSEMENT — ADD_ENDORSEMENT_NO / DEL_ENDORSEMENT_NO

The workbook maps `ADD_ENDORSEMENT_NO` and `DEL_ENDORSEMENT_NO` (alongside the already-built
`ENDORSEMENT_NO`) to "Endorsement Number" on `BJAZ_HM_MEMBER_DTLS`. We only added
`ENDORSEMENT_DATE` this round, per the sync note's explicit scope — these two were never
built and remain unbuilt.

**Ask**: are `ADD_ENDORSEMENT_NO`/`DEL_ENDORSEMENT_NO` meant to be separate attributes (an
endorsement-added vs. endorsement-removed distinction) or duplicates of `ENDORSEMENT_NO` we
should fold in directly?
