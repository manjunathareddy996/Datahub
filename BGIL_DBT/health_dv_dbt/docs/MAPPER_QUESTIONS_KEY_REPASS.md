# Questions for the Health mapping owner — key-building re-pass

Context for this round: the original rule for every gap in this build was "if the source
doesn't have a key, don't assume it — document it as a joinability issue." That rule was
revised: **if a key is needed, build one where it can be logically justified** — Data Vault
hashing already supports hashing multiple columns together, so a missing single-column key
isn't automatically a dead end.

Under that revised rule, every currently-excluded (hub, table) combination — 164 of them,
across every satellite that has an `no_key_tables` entry — was re-scanned. Results split
into three tiers by confidence. **Nothing in this document has been applied to the build
yet** — it's all proposals for you to confirm, correct, or reject.

---

## Tier A — single-column discoveries (high confidence, please confirm)

An identifier-shaped column (contains `NO`/`ID`/`CODE`/`REF`) whose name fits the target
hub's domain, that the earlier exact-name-match discovery pass missed (because the exact
name wasn't already used as a key elsewhere). Recommend tagging these as `KEY:<hub>`
directly — no composite needed.

| Hub | Table(s) | Candidate column(s) | Note |
|---|---|---|---|
| `HUB_ASSESSMENT` | `BJAZ_CLM_PRE_AUTH_HLT_DTLS` | `PRE_AUTH_NO`, `PRE_AUTH_REF` | two candidates — same thing or different? |
| `HUB_ASSESSMENT` | `BJAZ_TPA_CLAIM_DETAILS_WS` | `PRE_AUTH_LETTER_NO` | |
| `HUB_FINANCIAL_TRANSACTION` | `BA_HCP_PROD_8428/8432/8433/8439_*_LOADER` (×4) | `PD_RECEIPT_NO` | |
| `HUB_FINANCIAL_TRANSACTION` | `BJAZ_BANDHAN_MEDI_CLAM` | `RECEIPT_NO` | |
| `HUB_FINANCIAL_TRANSACTION` | `BJAZ_EHH_POL_DTLS` | `RECEIPT_NO` | |
| `HUB_FINANCIAL_TRANSACTION` | `BJAZ_HG_POL_DTLS` | `RECEIPT_NO`, `TRACE_NUMBER` | `TRACE_NUMBER` is a payment-gateway trace ref — likely the better of the two |
| `HUB_LOCATION` | `BA_HCP_PROD_8428/8432/8433/8439_*_LOADER` (×4) | `PD_PIN_CODE` | **caveat**: a pincode identifies an area, not a specific address — same coarseness issue as the composite-address-key discussion elsewhere in this build. Worth it, or too coarse to be useful? |
| `HUB_PARTY` | `BJAZ_CARD_DTLS` | `EMP_NO` | |
| `HUB_PARTY` | `BJAZ_HM_GMC_AHC` | `EMP_ID`, `CONTACT_NO` | **caveat**: `CONTACT_NO` is a phone number — weak as a party identifier (numbers get shared/reused/changed). `EMP_ID` is the safer choice if only one is needed. |

---

## Tier B — composite candidates (needs your judgment, not just confirmation)

Full list of 143 rows in `docs/appendix_11_key_repass_composite_candidates.csv` — one row
per (hub, table), each showing: the table's other already-verified keys, and candidate
"discriminator" columns (things that look like they might distinguish multiple rows per
key). **Read the discriminator column with real skepticism** — the matching heuristic that
generated it is naive (any `TYPE`/`CATEGORY`/`STATUS`/`FLAG`/`IND`-suffixed column), and it
produces real noise. Concrete example already caught: for `HUB_ASSESSMENT` on
`BJAZ_HCF_MEMBER_DTLS`, it proposed `SMOKER_FLAG`/`ASTHMA_FLAG`/`DIABETES_FLAG` as
"discriminators" — those are medical-condition flags, not anything that identifies a
distinct assessment event. Whether a proposed composite is actually valid depends on
whether that table can legitimately have more than one row per (existing key + candidate
discriminator) — something only real data or your knowledge of the source can answer, not
a column-name pattern.

Breakdown by hub (busiest first): `HUB_RISK_OBJECT` (52 tables), `HUB_COVERAGE` (22),
`HUB_PARTY` (17), `HUB_FINANCIAL_TRANSACTION` (11), `HUB_LOCATION` (10), `HUB_CLAIM` (8),
`HUB_POLICY` (4), `HUB_PRODUCT` (4), `HUB_ASSESSMENT` (3), `HUB_DISTRIBUTION_CHANNEL` (2),
`HUB_DOCUMENT` (2), `HUB_ORG_UNIT` (2), `HUB_PAYMENT_INSTRUMENT` (2), `HUB_PROPOSAL` (2),
`HUB_REINSURANCE_TREATY` (2). 17 of the 143 rows have **no** candidate discriminator column
at all — those would need a literal/mapper-supplied discriminator, not just confirmation of
an existing column (the CSV flags these in the `note` column).

For each row you're able to look at: is the existing key + candidate discriminator
genuinely unique per row on that table? If yes, that's the composite key. If the
discriminator is wrong (like the medical-flag example) but a *different* column on that
table would work, please say which. If nothing on the table can distinguish multiple rows,
it stays excluded — same as before.

---

## Tier C — confirmed dead ends (no action needed, for awareness only)

These 6 have no column of any kind — single or composite — that could represent the target
hub. Still excluded, same as before the re-pass; listed here just so you know they were
checked, not skipped:

- `BJAZ_FPLM_DISABILITY_DETAILS`, `BJAZ_FPLM_HOSPT_TRTMNT_DTLS`, `BJAZ_FPLM_POST_MORTEM_DTLS`
  (all → `HUB_CLAIM`)
- `BJAZ_M_KYC_DRIVING_LICENCE` (→ `HUB_PARTY`)
- `BJAZ_HM_EXCLUSION_MASTER` (→ `HUB_PRODUCT`)
- `BJAZ_KBL_LEAD_PROCESSING` (→ `HUB_RISK_OBJECT`)
