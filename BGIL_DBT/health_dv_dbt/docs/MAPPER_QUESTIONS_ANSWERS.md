# Answers — Health mapping owner → dbt Data Vault build

Responses to `MAPPER_QUESTIONS.md`, grounded in the canonical model (`data_v4.js` — 20 hubs,
71 links), the current Health mapping (v5, 129 tables), and the full source column catalogue
(`DWH_OPUS_columns_list_3185_tables.xlsx` — 3,185 tables / 77,195 columns).

## Framing (read first)

Two principles drive every answer below:

1. **Satellites never move.** Every satellite stays on the hub it is modelled on. The
   `HUB_RISK_OBJECT` satellites are correct: the *risk object* is the **insured thing** — motor
   vehicle, property, or (in Health) the **insured person/member**. So "no key for
   `HUB_RISK_OBJECT`" does **not** mean re-parent; it means **we have not yet tagged the column
   that identifies the insured member.** The mapper's job is only to **find the business key**.

2. **The hub key = the primary key of the satellite's grain.** When a source row populates a
   satellite, the column that uniquely identifies that satellite's row *is* the hub's business
   key. Tag that column as `KEY:<hub>`.

3. **Every row is a unit of work.** A source row does not populate one hub in isolation. It
   carries several business keys at once, so loading it populates **its hub + its satellites +
   every link whose component hubs are all present as keys on that row** (grain-permitting).
   [Section F](#f-unit-of-work--which-links-each-row-populates) works this out per table — it is
   the answer to "what links get populated for a given row," and it dissolves most of Section C.

Status flags: ✅ **tag now** (column identified) · 🔗 **populates links** (see §F) ·
🌱 **needs a code list / external seed** · 🔎 **spot-check**.

---

## Index

| # | Question | Verdict |
|---|----------|---------|
| [1](#1-hub_risk_object) | `HUB_RISK_OBJECT` key | ✅ `MEMBER_NO` / `POLICY_REF+MEM_SEQNO` |
| [2](#2-hub_loss_event) | `HUB_LOSS_EVENT` key | ✅ claim/intimation no (1:1 with claim) |
| [3](#3-hub_coverage-on-22-tables) | `HUB_COVERAGE` on 22 tables | ✅ `COVER_CODE`; loaders = unpivot key |
| [4](#4-hub_agreement-on-hospital-tables) | `HUB_AGREEMENT` on hospital tables | ✅ `HOSID` (empanelment agreement) |
| [5](#5-hub_proposal) | `HUB_PROPOSAL` key | ✅ `QUOTE_REF_NO` (proposal≈quote here) |
| [6](#6-hub_financial_transaction) | `HUB_FINANCIAL_TRANSACTION` key | ✅ `TPA_TRANS_KEY` / instrument |
| [7](#7-hub_org_unit) | `HUB_ORG_UNIT` key | ✅ `OPERATING_OFFICE` |
| [8](#8-hub_location) | `HUB_LOCATION` key | ✅ `POLICY_LOCATION` / `PIN_CODE` |
| [9](#9-hub_party) | `HUB_PARTY` key | ✅ `LOGINNAME`; outward = name-only |
| [10](#10-hub_product) | `HUB_PRODUCT` key | ✅ not product-scoped (exclusion is a REF) |
| [11](#11-hub_policy-on-hospital-master) | `HUB_POLICY` on hospital master | ✅ it's `HOSID` (provider), not policy |
| [12](#12-hub_reinsurance_treaty) | `HUB_REINSURANCE_TREATY` | ✅ no treaty key → out of scope |
| [13](#13-16-links-with-no-source) | 16 links "with no source" | 🔗 mostly populated as unit-of-work |
| [14](#14-lnk_party_relationship--lnk_party_group) | party relationship / group | 🔗 `RELATION` + two party keys |
| [15](#15-lnk_policy_renewal) | `LNK_POLICY_RENEWAL` | ✅ `PREV_POLICY_NO` exists |
| [16](#16-lnk_policy_endorsement) | `LNK_POLICY_ENDORSEMENT` | ✅ `ENDT_NO` exists |
| [17](#17-lnk_coverage_hierarchy) | `LNK_COVERAGE_HIERARCHY` | 🔗 derived in coverage unpivot |
| [18](#18-ref_relationship_type--ref_exclusion) | `REF_*` masters | ✅ `EXCLUSION` / 🌱 `RELATIONSHIP_TYPE` |
| [19](#19-213-discovered-hub-keys) | 213 discovered keys | 🔎 spot-check |

---

## A. The two "keyless" hubs

### 1. `HUB_RISK_OBJECT`
**✅ The insured member is the risk object. Tag the member identifier.**

| Table | Column to tag as `KEY:HUB_RISK_OBJECT` |
|-------|----------------------------------------|
| `BJAZ_HCF_MEMBER_DTLS` | `MEMBER_NO` |
| `BJAZ_EC_MEM_DTLS_EXTN` | `MEMBER_NO` |
| `BJAZ_CTNGY_PA_MEM_DTLS` | `MEMBER_REF_NUMBER` |
| `BA_HCP_PROD_8428_GPG_LOADER`, `..._8433_FHC_LOADER` | `MD_SEQ_NO` (per-policy seq → key on `POLICY_REF + MD_SEQ_NO`) |

Business key rule: `MEMBER_NO` where it exists; otherwise the composite **`POLICY_REF + MEM_SEQNO/MD_SEQ_NO`**
(the sequence is unique only within a policy). ⚠️ **Not `OBJECT_ID`** — that is the OPUS
row-surrogate (it always sits with `ACTION_CODE`/`VERSION_NO`/`PREVIOUS_VERSION`), not a business
key. Once tagged, these member rows populate the risk-object links in §F (no model change; the six
risk satellites stay exactly where they are).

### 2. `HUB_LOSS_EVENT`
**✅ In Health the loss event is the hospitalisation/claim event — key it by the claim/intimation number.**

| Table | Column to tag as `KEY:HUB_LOSS_EVENT` |
|-------|---------------------------------------|
| `BJAZ_HM_HCM_EXTRACT` | `CLAIM_NO` |
| `BJAZ_HM_INWARD_DTLS` | `CLAIM_ID` (intimation `INWARD_ID` if you want the FNOL grain) |
| `BJAZ_TPA_CLAIM_DETAILS_WS` | `TPA_CLAIM_NO` |

Health has no separate incident-id distinct from the claim, so the loss event is 1:1 with the
claim and takes the **same claim/intimation number** as its business key. `SAT_LOSS_EVENT_DETAIL`
stays on `HUB_LOSS_EVENT`; `LNK_CLAIM_LOSS_EVENT` is then populated from the same claim row (§F).

---

## B. Hub key missing on specific tables — the column to tag

### 3. `HUB_COVERAGE` on 22 tables
**✅ Two shapes.**

- Where a discrete coverage/section code exists, tag it: **`BJAZ_HG_POL_DTLS.COVER_CODE`** (and any
  `HCP_SEQNO` / `SECTION_CODE` on the coverage tables).
- On the **wide benefit loaders** (`BA_HCP_PROD_8428_GPG_LOADER`, `..._8433_FHC_LOADER`,
  `BJAZ_GRP_HLT_DTLS`) coverage is one column per benefit (`MLAC_ROAD_AMBULANCE_COVER`,
  `PLC_HOSP_CASH_SI`, …). The coverage key is **minted during the benefit-column unpivot** as
  `POLICY_REF + <benefit-code>`, where benefit-code is the column-derived coverage identifier. The
  six coverage satellites are then keyed on that synthetic coverage key. This is an ETL unpivot,
  not a re-parent.

### 4. `HUB_AGREEMENT` on `BJAZ_HM_HOSPITAL_MASTER` / `_EXTN` / `_EXTN1`, `BJAZ_REMEDINET_CLAIM_DETAILS`
**✅ The agreement is the hospital network empanelment — key it by the hospital.**

The EXTN table literally carries `EMPANEL_DATE`, `RE_EMPANEL_DATE`, `AGREEMENT_EXP_DATE`,
`YEAR_EMPANELMENT` → this is the insurer↔hospital empanelment **agreement**, and it is identified
per hospital. Tag **`HOSID`** as `KEY:HUB_AGREEMENT` on the hospital master tables (and
`REMEDINET_PROVIDER_CODE` / `IRDA_ID` on the REMEDINET table). One source column (`HOSID`)
legitimately serves as the business key for the agreement grain whose satellite the row populates;
the agreement and provider-party links both fall out in §F. No re-parent.

### 5. `HUB_PROPOSAL` on `BA_HCP_PROD_8433_FHC_LOADER`, `BJAZ_EC_MEM_DTLS_EXTN`, `BJAZ_GRP_HLT_DTLS`, `BJAZ_HG_POL_DTLS`
**✅ Proposal is identified by the quote reference in this source.**

There is no separate proposal number; the pre-policy application is carried as the quote
reference. Tag **`QUOTE_REF_NO`** (`BJAZ_HG_POL_DTLS`, `BJAZ_GRP_HLT_DTLS` — also `QUOTE_NO`/
`QUOTE_SUB_NO`) as `KEY:HUB_PROPOSAL`. The proposal and quote share the same business key here, so
`HUB_PROPOSAL` and `HUB_QUOTE` hash from the same reference and `LNK_QUOTE_PROPOSAL` is a 1:1
identity link. The questionnaire content (`MEM_COVERED_POL_YN`, `PREV_DISEASE_COVERED_YN`,
`PREV_ACCIDENT_YN`) already maps to `SAT_PROPOSAL_QUESTIONNAIRE`; only the key was missing.

### 6. `HUB_FINANCIAL_TRANSACTION` on `BJAZ_GRP_TPA_EXTN`, `BJAZ_HM_HCM_EXTRACT`, `BJAZ_PMJAY_PRMBOOK_DTLS`, `BJAZ_REMEDINET_CLAIM_DETAILS`, `BJAZ_TPA_CLAIM_DETAILS_WS`
**✅ Use the transaction key where present, else the payment instrument.**

- `BJAZ_TPA_CLAIM_DETAILS_WS` has an explicit **`TPA_TRANS_KEY`** → tag it `KEY:HUB_FINANCIAL_TRANSACTION`.
- `BJAZ_HM_HCM_EXTRACT`: the payment is identified by its instrument — **`UTR_NO`** (fallback
  `CHEQUE_NO`); model these on `HUB_PAYMENT_INSTRUMENT` and key the fin-txn as `CLAIM_NO + UTR_NO`
  if a standalone txn key is required.
- `BJAZ_GRP_TPA_EXTN` is a TPA service-charge rate table keyed by `CONTRACT_ID` — the charge-rate
  satellite is policy-grain here, not a payment; no txn key needed.

`SAT_FINTXN_CLAIM_PAYMENT` stays on `HUB_FINANCIAL_TRANSACTION`; `LNK_FINTXN_CLAIM` /
`LNK_FINTXN_PARTY` / `LNK_FINTXN_INSTRUMENT` populate from the same claim-payment row (§F).

### 7. `HUB_ORG_UNIT`
**✅** Tag **`BJAZ_TPA_CLAIM_DETAILS_WS.OPERATING_OFFICE`** (and `CONTROLLING_OFFICE` as the parent
for `LNK_ORG_UNIT_HIERARCHY`). `BJAZ_HM_HOSPITAL_MASTER_EXTN` and `BJAZ_REMEDINET_CLAIM_DETAILS`
carry no internal BAGIC org unit — `SAT_ORG_UNIT_DEFINITION` simply isn't fed from those two.

### 8. `HUB_LOCATION`
**✅** `BJAZ_HM_HCM_EXTRACT.POLICY_LOCATION` (geo attr `CITY`/`PIN`); for the hospital, key
`BJAZ_HM_HOSPITAL_MASTER.PIN_CODE` (+`CITY_NAME`) and let the EXTN geography ride the same `HOSID`.
Prefer `PIN_CODE`/`LOCATION_CODE` as the `HUB_LOCATION` business key.

### 9. `HUB_PARTY`
**✅ / name-only.**
- `BJAZ_HM_POLICY_USERMAPPING` (cols: `POLICY_REF, LOGINNAME, UPDATED_ON, GG_CHANGE_DATE`) — tag
  **`LOGINNAME`** as `KEY:HUB_PARTY` (internal user party); `LNK_POLICY_PARTY` then links the user
  to the policy (access-mapping grain).
- `BJAZ_HM_OUTWARD_DTLS` — the recipient is **name-only** (`SENT_TO_NAME`, `PATIENT_NAME`); there is
  **no party-id column**, so the party key genuinely cannot be tagged. The dispatch row is
  claim-grain — key it on `CLAIM_ID`/`OUTWARD_ID`; `SAT_PARTY_CORRESPONDENCE` is populated on that
  claim key, with recipient name as an attribute. (Not a gap in the model — the source only has a
  name.)

### 10. `HUB_PRODUCT`
**✅ Not product-scoped here.**
- `BJAZ_HM_EXCLUSION_MASTER` (cols `EXCLUSION_ID, EXCLUSION_CODE, EXCLUSION_SUB_ID, EXCLUSION_DETAIL`)
  is the **exclusion code master** (see Q18), product-agnostic — do not key `HUB_PRODUCT` here.
- `BJAZ_ECARD_POL_DTLS_CONFIG` carries `POLICY_REF`/`QUOTE_REF` only — product is reached via the
  policy→product link; leave `HUB_PRODUCT` unkeyed and map its config under `HUB_POLICY`.

### 11. `HUB_POLICY` on `BJAZ_HM_HOSPITAL_MASTER`
**✅ It's a provider status, keyed by the hospital — not a policy.**

`SAT_COMMON_STATUS` here is fed by `HOS_STATUS` (hospital empanelment status). The table has no
policy column; its business key is **`HOSID`**. `SAT_COMMON_STATUS` is a shared/common satellite —
on this row its key is the hospital, so no `HUB_POLICY` key is needed. **Also fix:** the current
mapping tags `BJAZ_HM_HOSPITAL_MASTER_EXTN.REG_NO → HUB_POLICY`; `REG_NO` is the hospital
registration number — drop or re-anchor that key to the provider.

### 12. `HUB_REINSURANCE_TREATY`
**✅ No treaty key in source → out of scope for these tables.**

`BA_HCP_PROD_8428_GPG_LOADER` / `..._8433_FHC_LOADER` are direct retail-health/PA benefit loaders;
they carry no treaty identifier or cession columns. `SAT_RI_CESSION_DETAIL` is simply not fed from
Health (it belongs to the RI subject area, sourced elsewhere). Nothing to tag.

---

## C. Links "with no supporting source"

**These are largely answered by §F.** A link is not a separate sourcing problem when a
satellite-bearing row already carries both component keys — the developer builds the link in the
same unit of work. The genuinely-absent ones are called out.

### 13. 16 links with no source
**🔗 Split three ways:**
- **Now populated as unit-of-work** (once Q1–Q6 keys are tagged): `LNK_FINTXN_CLAIM`,
  `LNK_FINTXN_PARTY`, `LNK_FINTXN_INSTRUMENT`, `LNK_ASSESSMENT_DOCUMENT`, `LNK_AGREEMENT_PARTY`,
  `LNK_QUOTE_PROPOSAL` — all have both component keys co-located on a claim/payment/hospital/policy
  row (see §F). No new source needed.
- **Genuinely out of scope for Health** (no source key exists anywhere): `LNK_FINTXN_TREATY`,
  `LNK_TREATY_PARTY`, `LNK_TREATY_DOCUMENT`, `LNK_CLAIM_RI_RECOVERY` — RI/treaty subject area, per Q12.
- **`LNK_AGREEMENT_DOCUMENT`** — populated only if a hospital-agreement document reference exists on
  the hospital master; none found, so leave unfed unless a document table surfaces.

### 14. `LNK_PARTY_RELATIONSHIP` / `LNK_PARTY_GROUP`
**🔗 The data is the `RELATION` code + two party keys — buildable, not missing.**

Family/household relationship is the **member-to-proposer** relationship carried as a code on the
member row: `RELATION`, `MD_RELATION`, `MD_NOMINEE_RELATION`, `ASSIGNEE_RELATION`. To populate
`LNK_PARTY_RELATIONSHIP` you pair **proposer party key** (the policyholder/`CONTRACT_ID` party)
with **member party key** (`MEMBER_NO` resolved to `HUB_PARTY`) and stamp the `RELATION` code on
the link satellite. `LNK_PARTY_GROUP` is the same, scoped to the policy's member roster (the group
= the policy's insured set). Both are unit-of-work links off the member rows (exclude `self` rows).
This needs the `REF_RELATIONSHIP_TYPE` code list (Q18) for the relationship attribute.

### 15. `LNK_POLICY_RENEWAL`
**✅ The prior-term column exists — it was missed.**

| Table | Prior-term policy column (→ second `HUB_POLICY` key) |
|-------|------------------------------------------------------|
| `BJAZ_HG_POL_DTLS` | `PREV_POLICY_NO` |
| `BJAZ_GRP_HLT_DTLS` | `PREV_POL_REF` |
| `BJAZ_EC_MEM_DTLS_EXTN` | `FIRST_POLICY_REF`, `CON_POLICY_REF` |

Build the link as (current `POLICY_REF` → prior `PREV_POLICY_NO`). These are real prior contracts,
not row-duplicates.

### 16. `LNK_POLICY_ENDORSEMENT`
**✅ The endorsement column exists.**

**`BJAZ_PMJAY_PRMBOOK_DTLS.ENDT_NO`** (with `ENDT_TYPE`, `ENDT_EFF_DATE`) is a true endorsement
sequence — build `LNK_POLICY_ENDORSEMENT` as (`POLICY_REF`, `ENDT_NO`). **Do not** use `VERSION_NO`
(that is generic OPUS row-versioning, sits with `ACTION_CODE`/`PREVIOUS_VERSION`).

### 17. `LNK_COVERAGE_HIERARCHY`
**🔗 Derived during the coverage unpivot (Q3), not a source column.**

No table carries two distinct coverage-code columns; the base↔rider relationship is implicit in
the wide benefit columns. When the loader benefits are unpivoted into coverage rows (Q3), emit the
hierarchy at the same time — base plan as parent, add-on covers as children under the same
`POLICY_REF`. There is no column to tag; it is a rule in the unpivot.

---

## D. Reference code masters

### 18. `REF_RELATIONSHIP_TYPE` / `REF_EXCLUSION`
- **`REF_EXCLUSION` — ✅** `BJAZ_HM_EXCLUSION_MASTER` **is** the master: map `EXCLUSION_CODE` = code,
  `EXCLUSION_DETAIL` = description, `EXCLUSION_SUB_ID` = sub-code. It shows zero mapped rows only
  because it wasn't in scope; add it as the `REF_EXCLUSION` source.
- **`REF_RELATIONSHIP_TYPE` — 🌱** No source table defines the relationship code list (the only
  `*_MASTER` with relationships is `BJAZ_EMP_ROLE_MASTER` = employee roles). The codes appear only
  as usages (`RELATION`, `ASSIGNEE_RELATION`). **Needs an external seed** — supply the standard
  relationship code list (self, spouse, son, daughter, father, mother, …) from the enterprise
  reference-data set; it is not derivable from Health source.

---

## E. Discovered keys

### 19. 213 discovered hub keys
**🔎 Method is sound; sample-check for two false-positive patterns:**
1. **OPUS surrogates** read as business keys — `OBJECT_ID`, `VERSION_NO`, `PREVIOUS_VERSION`,
   `REVERSING_VERSION` (~91 tables). Any hub key from these is wrong.
2. **Registration/reference numbers mis-anchored** — e.g. `REG_NO` (hospital registration) tagged
   `HUB_POLICY` (Q11), or `IRDA_ID`/`TAN_NO`/`TARIFF_MAPPING_ID` read as entity keys when they are
   provider attributes.

A ~20-row stratified sample (by hub) is enough; the rest can be trusted.

---

## F. Unit of work — which links each row populates

This is the "what links get populated for a given row" analysis. **Rule:** a source row populates
its hub key + satellites + **every link whose component hubs are all keyed on that row**, subject
to two filters — (a) the link must involve the row's **primary grain** hub; (b) a **self-link**
(two components on the same hub: renewal, party-relationship, coverage-hierarchy, org-hierarchy)
populates only if the row carries **two distinct** key columns of that hub.

`HUB_RISK_OBJECT` alone attaches to **10 links**:
`LNK_POLICY_RISK_OBJECT`, `LNK_POLICY_COVERAGE_RISK`, `LNK_RISK_OBJECT_PARTY`,
`LNK_RISK_OBJECT_LOCATION`, `LNK_RISK_OBJECT_ASSESSMENT`, `LNK_RISK_OBJECT_DOCUMENT`,
`LNK_QUOTE_RISK_OBJECT`, `LNK_PROPOSAL_RISK_OBJECT`, `LNK_CLAIM_RISK_OBJECT`,
`LNK_LOSS_EVENT_RISK_OBJECT` — a member row fills whichever of these its partner keys are present for.

Worked per representative table (after the keys above are tagged):

| Table (primary grain) | Hub key to tag | Links the row populates |
|---|---|---|
| `BJAZ_HCF_MEMBER_DTLS` (**risk object**) | `MEMBER_NO` | `LNK_POLICY_RISK_OBJECT`, `LNK_POLICY_COVERAGE_RISK`, `LNK_RISK_OBJECT_PARTY`, `LNK_RISK_OBJECT_ASSESSMENT` |
| `BJAZ_HG_POL_DTLS` (**policy**) | (adds `COVER_CODE`, `QUOTE_REF_NO`, `RISK_OBJECT`) | `LNK_PROPOSAL_POLICY`, `LNK_POLICY_PARTY`, `LNK_POLICY_PRODUCT`, `LNK_POLICY_COVERAGE`, `LNK_POLICY_RISK_OBJECT`, `LNK_POLICY_COVERAGE_RISK`, `LNK_POLICY_CHANNEL`, `LNK_POLICY_ORG_UNIT`, `LNK_POLICY_LOCATION`, `LNK_POLICY_ENDORSEMENT`, `LNK_POLICY_RENEWAL`, `LNK_FINTXN_POLICY` |
| `BA_HCP_PROD_8433_FHC_LOADER` (**policy**) | `MD_SEQ_NO`, `COVER_CODE`, `QUOTE_REF_NO` | full policy fan above (minus renewal — no prev-policy col) + `LNK_POLICY_CESSION` |
| `BJAZ_HM_HCM_EXTRACT` (**claim**) | `CLAIM_NO`, `POLICY_LOCATION` | `LNK_CLAIM_LOSS_EVENT`, `LNK_CLAIM_POLICY`, `LNK_CLAIM_COVERAGE`, `LNK_CLAIM_RISK_OBJECT`, `LNK_CLAIM_PARTY`, `LNK_CLAIM_ASSESSMENT`, `LNK_CLAIM_DOCUMENT`, `LNK_CLAIM_LOCATION`, `LNK_CLAIM_PAYMENT_INSTRUMENT`, `LNK_FINTXN_CLAIM` |
| `BJAZ_TPA_CLAIM_DETAILS_WS` (**claim**) | `TPA_CLAIM_NO`, `TPA_TRANS_KEY`, `OPERATING_OFFICE` | claim fan above + `LNK_FINTXN_CLAIM`, `LNK_FINTXN_PARTY`, `LNK_FINTXN_INSTRUMENT`, `LNK_ORG_UNIT_LOCATION` |
| `BJAZ_HM_HOSPITAL_MASTER` (**provider party**) | `HOSID` | `LNK_AGREEMENT_PARTY`, `LNK_PARTY_ROLE`, `LNK_PARTY_LOCATION` |

Two cautions the developer should apply row-by-row:
- A link only fires when the partner key **has a value on that row** — e.g. a member-master row
  populates `LNK_CLAIM_RISK_OBJECT` only for members that carry a claim reference, not for all.
- The self-link filter matters: `LNK_POLICY_RENEWAL` fires only where `PREV_POLICY_NO` is present
  and distinct from `POLICY_REF`; `LNK_PARTY_RELATIONSHIP` only where proposer≠member.

---

## G. What still needs someone else

Very little — under the correct lens almost everything is a mapper tagging action. The only items
that cannot be closed by tagging a column:

| Item | Who | What is needed |
|------|-----|----------------|
| `REF_RELATIONSHIP_TYPE` code list (Q18) | Reference-data owner | Seed the standard relationship codes; not in Health source. |
| Coverage unpivot grain (Q3, Q17) | Modeler / ETL design | Ratify that loader benefit columns unpivot to `POLICY_REF + benefit-code` coverage rows, and that base↔rider hierarchy is emitted there. A design ruling, not a re-parent. |
| Proposal≡Quote key identity (Q5) | Modeler (confirm only) | Confirm `HUB_PROPOSAL` and `HUB_QUOTE` may share the `QUOTE_REF_NO` business key in Health. |

Everything else in Sections A–F is the developer tagging the identified column.

---

## H. Tagging cheat-sheet

| Hub / Link | Column → tag |
|------------|--------------|
| `HUB_RISK_OBJECT` | `MEMBER_NO` (or `POLICY_REF+MEM_SEQNO`/`MD_SEQ_NO`) |
| `HUB_LOSS_EVENT` | `CLAIM_NO` / `CLAIM_ID` / `TPA_CLAIM_NO` |
| `HUB_COVERAGE` | `COVER_CODE`; loaders → synthetic `POLICY_REF+benefit-code` |
| `HUB_AGREEMENT` | `HOSID` (hospital empanelment) |
| `HUB_PROPOSAL` | `QUOTE_REF_NO` |
| `HUB_FINANCIAL_TRANSACTION` | `TPA_TRANS_KEY`; else `CLAIM_NO+UTR_NO` |
| `HUB_ORG_UNIT` | `OPERATING_OFFICE` (parent `CONTROLLING_OFFICE`) |
| `HUB_LOCATION` | `POLICY_LOCATION` / `PIN_CODE` |
| `HUB_PARTY` (usermapping) | `LOGINNAME` |
| `LNK_POLICY_RENEWAL` | `POLICY_REF` + `PREV_POLICY_NO`/`PREV_POL_REF`/`FIRST_POLICY_REF` |
| `LNK_POLICY_ENDORSEMENT` | `POLICY_REF` + `ENDT_NO` |
| `LNK_PARTY_RELATIONSHIP` | proposer party + member party + `RELATION` |
| `REF_EXCLUSION` | `BJAZ_HM_EXCLUSION_MASTER.EXCLUSION_CODE` |
| Do **not** tag | `OBJECT_ID`, `VERSION_NO` (OPUS surrogates); `REG_NO`→policy (it's provider) |
