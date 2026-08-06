# Follow-up note for the mapper — re: v5 subject-attribution fix

Applied the v5 subject-attribution fix and rebuilt on it. It works as designed — 22 of the 24
RE-ANCHOR rows and all 49 EXCLUDE+FLAG rows are now correctly reflected in the build (details
in `appendix_9_subject_attribution.csv`). Two things need your input before they're fully
correct: a confirmed pairing bug in the auto-detected companion keys, and 2 rows that don't
have anywhere to go yet.

---

## 1. Auto-pairing bug — 15 rows corrected, 1 left for you to confirm

Before wiring the `Subject key / Role` column into the build, I checked every RE-ANCHOR pairing
against the real OPUS column list for its table. 15 rows (across the 4 loader tables and 2
others) were pointing at the wrong companion column — pattern looks like each row got paired
with the *previous* row's column instead of its own. I corrected these (verified, not guessed —
each fix targets a column that provably exists on that table and matches the row's own label):

| Table(s) | Column | Sheet said | Corrected to |
|---|---|---|---|
| `BA_HCP_PROD_8428/8432/8433/8439_*_LOADER` (×4) | `PD_IMD_RM_E_CODE` | → `PD_IMD_CODE` (wrong entity — that's the intermediary org, not a person) | **self-key** |
| same ×4 | `PD_BAGIC_RM_E_CODE` | → `PD_IMD_RM_E_CODE` (a different person's code) | **self-key** |
| `BA_HCP_PROD_8432/8433_*_LOADER` (×2) | `PD_IMD_RM_NAME` | → `PD_IMD_CODE` | → `PD_IMD_RM_E_CODE` (same table, same role) |
| same ×2 | `PD_BAGIC_RM_NAME` | → `PD_IMD_RM_E_CODE` | → `PD_BAGIC_RM_E_CODE` (same table, same role) |
| `BJAZ_GPG_POL_DTLS` | `SUB_IMD_NAME` | → `IMD_CODE` (parent's code) | → `SUB_IMD_CODE` (exists on the table, was unused) |
| `BJAZ_GRP_HLT_IMD_DTLS` | `SUB_IMD_NAME` | → `IMD_CODE` | → `SUB_IMD_CODE` (same) |
| `BJAZ_HM_HCM_EXTRACT` | `HOSPITAL` (name) | → `HOSPITAL_BILL_NO` (a billing reference, not an identifier) | → `HOSPITAL_ID` (exists on the table, was unused) |

**Still needs your confirmation** (I did not correct this one — held it as originally stated,
exactly the case your own note flagged for eyeballing):

> `BJAZ_GPG_POL_DTLS.BAGIC_RM_E_CODE` → `BAGIC_E_CODE`

The table also has a genuinely distinct `[child:servicing-employee]` row on `BAGIC_E_CODE`
itself (RM vs. servicing-employee are two different people per your own Consolidation Fixes).
Right now both `BAGIC_E_CODE`'s own row and `BAGIC_RM_E_CODE`'s row resolve to the *same* party
key (`BAGIC_E_CODE`'s value), and their `Employee Code` attribute values get `COALESCE`d
together — meaning if this pairing is wrong, the servicing employee's own code could get
silently overwritten by the RM's code (or vice versa) in the final row, not just misattributed
the way the original bug was. **Please confirm**: is `BAGIC_RM_E_CODE` really the same person as
`BAGIC_E_CODE`, or does it need its own companion (or should it self-key, like the other
`*_RM_E_CODE` columns)?

Please also propagate these 15 corrections into the workbook's `Subject key / Role` column so
future re-generations don't need this cross-check repeated.

---

## 2. Two rows still have nowhere to go — need a target satellite

`BJAZ_TPA_CLAIM_DETAILS_WS.HOSPITAL_CITY` and `HOSPITAL_STATE` are tagged RE-ANCHOR →
`HOSPITAL_CODE`, target `SAT_COMMON_ADDRESS`. Problem: `SAT_COMMON_ADDRESS`'s canonical parent
is `HUB_LOCATION`, but `HOSPITAL_CODE` is a `HUB_PARTY` key (the hospital as a party) — putting
a party-keyed row into a location-keyed satellite table would mix two different hash-key types
in one physical table, which isn't valid. I excluded these 2 columns from this build rather
than force it (see `appendix_10_reanchor_hub_mismatch_excluded.csv`).

**Question**: should `HOSPITAL_CITY`/`HOSPITAL_STATE` instead land on a `HUB_PARTY`-anchored
provider satellite (e.g. `SAT_PARTY_PROVIDER_CAPABILITY`, if it has an address-shaped slot), or
does `SAT_COMMON_ADDRESS` need a formal per-row parent-hub override the way I've already applied
elsewhere (§12 of the build notes) for a few other satellites?

---

## 3. Still open from the previous round (unchanged — checked again in v5, not yet resolved)

- `LNK_PARTY_RELATIONSHIP` / `LNK_PARTY_GROUP` — still need the specific column carrying the
  *proposer's own* distinct party identifier (separate from the member's).
- `HUB_PROPOSAL` on `BA_HCP_PROD_8433_FHC_LOADER` and `BJAZ_EC_MEM_DTLS_EXTN` — no key column
  confirmed yet.
- `HUB_FINANCIAL_TRANSACTION` on `BJAZ_PMJAY_PRMBOOK_DTLS` and `BJAZ_REMEDINET_CLAIM_DETAILS` —
  same.

---

## What this unlocked (for context)

22 subject-attribution corrections are now live: `SAT_PARTY_IDENTITY` and `SAT_LNK_ROLE_EMPLOYEE`
both correctly carry the nominee/IMD-RM/insurer-RM/intermediary/sub-intermediary/hospital/
provider as their **own** party rows now, keyed by their own (corrected) companion columns —
not folded onto whichever party the table's main business key happens to represent. Full
before/after log in `appendix_9_subject_attribution.csv`.
