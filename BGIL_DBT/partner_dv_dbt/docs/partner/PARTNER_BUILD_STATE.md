# Partner LOB — definitive build state (single source of truth)

This one note supersedes the back-and-forth trail (`MAPPER_QUESTIONS`, `MAPPER_REPLIES` r1/r2,
`MODELER_AUGMENTATION`, `MAPPER_NOTE_5B`). Everything you asked across both feedback rounds is
answered; nothing is pending from the mapper side.

- **Model:** `data_5b`
- **Build from:** `Partner_SourceToModel_Mapping.xlsx` (authoritative — already reflects every fix below)
- **Validation:** 0 invalid targets, 0 collapse violations vs `data_5b`

## Coverage (30 tables, 1,279 columns)
| | count |
|---|---|
| Mapped (canonical targets) | **776** |
| Build-side augmentation (`SAT_AUG_*`) | **167** |
| Dropped at Stage-03 (technical/audit) | 336 |
| Required-for-mapping total | 943 |

## 1. The one fresh canonical build — `SAT_LNK_CLAIM_PARTY_ROLE`
The modeler added it in `data_5b` (on `LNK_CLAIM_PARTY`, multi-active, child key "Party Role Type +
Role Sequence"). **Build it fresh** — you had *held* `CLM_INTERESTED_PARTIES.IP_TYPE`/`IP_NO` unbuilt
pending the answer, so there is **no build-side `SAT_AUG_CLAIM_PARTY_ROLE` to replace** (ignore the
"replace" wording in the 5b note).
- `IP_TYPE` → `SAT_LNK_CLAIM_PARTY_ROLE.Party Role Type`
- `IP_NO` → `SAT_LNK_CLAIM_PARTY_ROLE.Role Sequence`
- Key: `CLAIM_ID + PART_ID` (both verified on `CLM_INTERESTED_PARTIES`).

This is the **only** delta since your round-2 build. Everything else below you already implemented or found.

## 2. Confirmed keys & decisions (already in your round-2 build — listed for completeness)
- **`PINCODE` → `KEY:HUB_LOCATION`** on both pincode tables (explicit tag).
- **`HUB_DISTRIBUTION_CHANNEL` key = `INTERMEDIARY_ID`** on `BJAZ_INTERMEDIARY(_HIST)` (IRDA code too
  sparse — your call, agreed), `IMD_CODE` on `BJAZ_CLM_SUPP_EXTN`.
- **Member composite = multi-active child key, NOT a hub-key composite** — ratified. `HUB_POLICY` stays
  keyed on `CONTRACT_ID` alone; member sequence (`MEMBER_NO`/`MEM_SEQNO`) is the child key on
  `SAT_AUG_POLICY`. **Never `OBJECT_ID`** (unstable surrogate).
- **`INTERMEDIARY_ID → HUB_AGREEMENT`** kept (passes the stability litmus).
- **Licence dup-check:** `BJAZ_INTERMEDIARY.LICENSE_NO` distinct from `IRDA_LICENSE_NO` (keep both);
  `BJAZ_CLM_SUPP_EXTN.LICENSE_NO` = `SURVEYOR_LICENSE_NO` (dropped as duplicate).

## 3. Bug — surveyor licence (you found it; workbook now matches)
- `SAT_LNK_ROLE_SURVEYOR.IRDAI Surveyor Licence Number` ← **`SURVEYOR_LICENSE_NO`** (the real value),
  not `IRDA_LICENSE`.
- `IRDA_LICENSE` (the Y/N flag) → build-side **"Has IRDA Licence Indicator"** — do not use as the number.

## 4. Build-side augmentation — 167 columns stay `SAT_AUG_*` (NOT canonical)
Build these on your side; promoted to canonical only if the same concept recurs in Motor.
| Group | Cols |
|---|---|
| New LOB-local sats — Lawyer/Advocate role, Affinity Membership | 17 |
| Missing attributes on 20 existing satellites (largest: `SAT_LNK_ROLE_PROVIDER`, `SAT_PARTY_KYC`, `SAT_CHANNEL_DEFINITION`) | 111 |
| Repeating groups (14 groups — child-key / single→multi-active, your call) | 39 |

Per-column detail: `Partner_SourceToModel_Mapping.xlsx` → **Augmentation (build-side)** sheet.

## 5. Confirmed gaps / out-of-scope (no action — not misses)
- **`AZBJ_ADDRESS_EXTN`** — no `HUB_PARTY` key exists (`UNIQUE_ID` 3/10k, `ADD_ID` is a row surrogate).
  Stays sourced from `BJAZ_CP_ADDRESS_LINK` only. Confirmed.
- **11 zero-source satellites** (`SAT_FINTXN_*`, `SAT_COVERAGE_*`, `SAT_RISK_*`, `SAT_ASSESSMENT_*`,
  `SAT_INSTRUMENT_DEFINITION`) — belong to Policy/Claim/Health LOBs, sourced there. Out-of-scope for
  Partner, not build misses.
- **`SAT_LNK_POLICY_PARTY_ROLE.Party Role Type`** — genuinely unmapped in Partner (no policy-grain type
  column). `OCP_INTERESTED_PARTIES.IP_NO` still feeds its Role Sequence.

## 6. Open questions — all closed
- CLM→policy path? → none exists; resolved via `SAT_LNK_CLAIM_PARTY_ROLE` (§1). ✅
- `AZBJ_ADDRESS_EXTN` party key? → none (§5). ✅
- `IRDA_LICENSE` meaning? → "Has IRDA Licence" indicator, build-side (§3). ✅

**Net: repoint to `data_5b`, build `SAT_LNK_CLAIM_PARTY_ROLE` (fresh), keep the 167 build-side.
Nothing else pending from the mapper.**
