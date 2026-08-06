# Modeler decisions — Health LOB feedback (response to MODELER_FEEDBACK_HEALTH.md)

**Date:** 2026-07-21  •  **Model version after this pass:** Phase 6b / v25  •  **Source of truth:** `Site/data.js` (20 hubs / 71 links / 363 sats / 54 refs / 6,283 attrs)

Verdict on each of the eight items you raised. **Two were actioned as model changes (M2, M4); the rest are reference-data seeds or design rulings — no structural change.** Nothing here reworks your build; all are additive or confirmations.

---

## Actioned as model changes (done in Phase 6b)

### M2 — `SAT_LNK_POLICY_PARTY_ROLE` — ADDED ✅
Confirmed the gap: `LNK_POLICY_PARTY` had **zero satellites**, so policy-scoped party roles had no home. Added a **multi-active** satellite:

- **Parent:** `LNK_POLICY_PARTY`  •  **Child key:** `Party Role Type + Role Sequence`
- **Attributes:** Party Role Type (policyholder / insured / main-agent / sub-agent / nominee / beneficiary / financier / servicing RM), Role Sequence, Role Category, Intermediary Sub-Type, Attribution Percentage, Role Effective Date, Role End Date, Primary Indicator, Role Status, Appointment Reference.

Your **24 held columns** (main/sub agent, RM type, nominee/beneficiary role) map straight into this. The party's *global* credentials still live on the `LNK_PARTY_ROLE` satellites (`SAT_LNK_ROLE_AGENT` etc.); the *policy-scoped* label lives here. Both correct at their own grain.

### M4 — `SAT_PARTY_ADDRESS_USAGE` — REMOVED ✅ (canonical = normalized route)
Agreed, and this was our own Phase-5 redundancy. It duplicated address lines already on `SAT_COMMON_ADDRESS` and duplicated the normalized route. **Canonical party-address path is now:**

`LNK_PARTY_LOCATION`  +  `SAT_PARTY_CONTACT_ADDRESS_LINK` (usage metadata on the party↔location tie)  +  `SAT_COMMON_ADDRESS` (address lines on `HUB_LOCATION`).

Load a party's address **once** via this route. The hospital-address case you hit is now the only supported path — no second party-keyed address satellite to force-fit into.

---

## Reference-data seeds (no structural change)

### M1 — `HUB_COVERAGE` unpivot — NOT a model change; seed the benefit-code vocabulary
All six coverage satellites and the `REF_COVERAGE_CODE` (Coverage Reference) master already exist. What's needed is the **wide→multi-active unpivot** plus a ratified **benefit-code vocabulary**:

- Mint coverage keys as `POLICY_REF ‖ benefit-code`, where **benefit-code is the canonical Coverage Code resolved through `REF_COVERAGE_CODE`** (extend the master with the health benefit codes — `MLAC_ROAD_AMBULANCE_COVER`, `PLC_HOSP_CASH_SI`, … → canonical codes). Do **not** mint a surrogate or fold the policy number into the *coverage catalogue* key beyond the policy-scoped instance.
- One `LATERAL FLATTEN`/`UNION ALL` branch per benefit column-group; assign the child-key literal per column; skip nulls (see `MAPPER_NOTES` — same pattern as tax-type).

**Action on us:** ratify/seed the benefit-code list in `REF_COVERAGE_CODE`. **Action on you:** build the unpivot. Additive, no rework.

### M6 — `REF_RELATIONSHIP_TYPE` — master exists, needs its code list seeded
The `REF_RELATIONSHIP_TYPE` master is already in the model; it only needs the standard codes loaded (self / spouse / son / daughter / father / mother / …). Reference-data task, not structure. (`REF_EXCLUSION` already resolved — noted.)

---

## Design rulings — confirmed, no model change

### M3 — literal `role_type_ck` on party-role satellites — ACCEPTABLE ✅
Anchoring the six role satellites on `HUB_PARTY` with a **literal** `role_type_ck` (e.g. `'PROVIDER'`) when no source carries a role-instance sequence is fine — it's a load-time provenance label, not a fabricated business key. Ratified as-built. No change.

### M5 — party-relationship / group grain — CONFIRMED ✅
Deriving the proposer via **self-join on the policy's member set** (`MD_IS_PROPOSER = 'Y'` / `RELATION = 'self'`), paired with each other member + `RELATION`, is the correct derivation. `LNK_PARTY_GROUP` = per-policy member roster. Confirmed as the intended grain. Do **not** build from a raw two-column pair (that repeats the redundant-pairing error). Until built, keep as documented gaps.

### M7 — RI / treaty / agreement links — OUT-OF-SCOPE FOR HEALTH ✅
`LNK_FINTXN_TREATY`, `LNK_TREATY_PARTY`, `LNK_TREATY_DOCUMENT`, `LNK_CLAIM_RI_RECOVERY`, `LNK_AGREEMENT_PARTY`, `LNK_AGREEMENT_DOCUMENT` are legitimately absent from Health source. **Marked out-of-scope-for-Health** — do not count as build misses. No model change.

### M8 — composite `HUB_RISK_OBJECT` key — RATIFIED ✅ (keep composite, do NOT re-parent)
Keying the insured member (the Health risk object) as **`POLICY_REF ‖ MEMBER_NO`** (or `‖ MEM_SEQNO`/`MD_SEQ_NO`) is the canonical Health risk-object key — the member-instance per policy is the risk. It's consistent with the existing `SAT_RISK_PERSON_INSURED` / `SAT_RISK_PERSON_MEMBER`. **Do not re-parent those six satellites to `HUB_PARTY`.**

One requirement to keep: the person's **global identity must stay resolvable to `HUB_PARTY`** via the party↔risk link, so "same person under two policies" (two risk objects) remains joinable at the party level. Keep that link populated.

---

## Summary

| # | Item | Decision | Model change |
|---|------|----------|--------------|
| M2 | Policy-party role sat | Added `SAT_LNK_POLICY_PARTY_ROLE` | ✅ done |
| M4 | Party↔address representation | Removed `SAT_PARTY_ADDRESS_USAGE`; use normalized route | ✅ done |
| M1 | Coverage unpivot | Seed benefit-code vocab in `REF_COVERAGE_CODE`; you build the unpivot | ⚪ ref-data |
| M6 | `REF_RELATIONSHIP_TYPE` | Seed the code list (master exists) | ⚪ ref-data |
| M3 | Literal `role_type_ck` | Ratified | ❌ none |
| M5 | Proposer / group grain | Confirmed (self-join derivation) | ❌ none |
| M7 | RI/treaty links | Out-of-scope-for-Health | ❌ none |
| M8 | Composite risk key | Ratified (keep composite; keep party link) | ❌ none |

Your build continues uninterrupted. M2 and M4 are live in Phase 6b (workbook `GI_DataVault_GI_Canonical_Model_Phase6b_PolicyPartyRole.xlsx` and the site). M1 and M6 are on us to seed; the rest are confirmations.
