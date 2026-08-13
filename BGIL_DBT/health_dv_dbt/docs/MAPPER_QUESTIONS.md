# Questions for the Health mapping owner

These are the open items from the Health LOB dbt Data Vault build that need a mapping
decision, not a technical fix. Grouped so related items can be answered together. Full
detail behind every line is in the appendix CSVs referenced.

---

## A. Two hubs with no key anywhere in Health (highest priority — real member data is stuck)

1. **`HUB_RISK_OBJECT`** — no source column in the entire Health mapping is tagged as this
   hub's business key. Which column identifies the insured member/risk object — is it
   `MEM_SEQNO` (scoped by policy), or something else? Blocks 6 satellites:
   `SAT_RISK_PERSON_MEMBER`, `SAT_RISK_PERSON_INSURED`, `SAT_RISK_OBJECT_CORE`,
   `SAT_RISK_HEALTH_MEMBER_COVERAGE`, `SAT_RISK_HEALTH_MEMBER_MEDICAL`,
   `SAT_RISK_HEALTH_PED_WAITING`.
   *Alternative answer:* should these 6 satellites instead be re-parented to `HUB_PARTY` /
   `LNK_PARTY_ROLE` in the canonical model, since every member identifier so far was mapped
   there instead?
2. **`HUB_LOSS_EVENT`** — same question, for `SAT_LOSS_EVENT_DETAIL`. Candidate tables:
   `BJAZ_HM_HCM_EXTRACT`, `BJAZ_HM_INWARD_DTLS`, `BJAZ_TPA_CLAIM_DETAILS_WS`. Which column
   (if any) identifies the loss event on these?

---

## B. Hub key missing on specific tables (hub exists elsewhere in Health, just not tagged here)

For each: does the listed table have a column that identifies the hub? If yes, tag it as
`KEY:<hub>`. If no, should the affected satellite(s) be re-anchored to a hub this table
*does* already key to (noted where obvious)?

3. **`HUB_COVERAGE`** missing on 22 tables (the big one) — e.g. `BA_HCP_PROD_8428_GPG_LOADER`,
   `BJAZ_GRP_HLT_DTLS`, `BJAZ_HCF_MEMBER_DTLS`, `BJAZ_TPA_CLAIM_DETAILS_WS` (full list:
   `docs/appendix_6_satellite_table_exclusions.csv`, category=`excluded`, filter hub
   context via `appendix_5`). Affects `SAT_COVERAGE_CONDITIONS`, `SAT_COVERAGE_DEFINITION`,
   `SAT_COVERAGE_LIMITS`, `SAT_COVERAGE_LIVES_COUNT`, `SAT_COVERAGE_MEMBER_BENEFIT`,
   `SAT_COVERAGE_SUBLIMIT_SCHEDULE`. Is there a systemic reason coverage/benefit-line
   tables weren't given a coverage key (e.g. `COVER_CODE`/`HCP_SEQNO`-style column exists
   but wasn't tagged), or do most of these genuinely not carry one?
4. **`HUB_AGREEMENT`** missing on `BJAZ_HM_HOSPITAL_MASTER`, `BJAZ_HM_HOSPITAL_MASTER_EXTN`,
   `BJAZ_HM_HOSP_MASTER_EXTN1`, `BJAZ_REMEDINET_CLAIM_DETAILS`. Affects
   `SAT_AGREEMENT_COMMERCIAL_TERMS`, `SAT_AGREEMENT_DEFINITION`, `SAT_AGREEMENT_SLA`.
   These tables already key to `HUB_PARTY` (via `HOSID` — the hospital). Should the
   "agreement" attributes here actually be `HUB_PARTY` (provider) attributes instead?
5. **`HUB_PROPOSAL`** missing on `BA_HCP_PROD_8433_FHC_LOADER`, `BJAZ_EC_MEM_DTLS_EXTN`,
   `BJAZ_GRP_HLT_DTLS`, `BJAZ_HG_POL_DTLS`. Affects `SAT_PROPOSAL_HEADER`,
   `SAT_PROPOSAL_QUESTIONNAIRE`, `SAT_PROPOSAL_UNDERWRITING`.
6. **`HUB_FINANCIAL_TRANSACTION`** missing on `BJAZ_GRP_TPA_EXTN`, `BJAZ_HM_HCM_EXTRACT`,
   `BJAZ_PMJAY_PRMBOOK_DTLS`, `BJAZ_REMEDINET_CLAIM_DETAILS`, `BJAZ_TPA_CLAIM_DETAILS_WS`.
   Affects `SAT_FINTXN_CLAIM_PAYMENT`, `SAT_FIN_CHARGE_RATE`, `SAT_FIN_PREMIUM_REGISTER`.
7. **`HUB_ORG_UNIT`** missing on `BJAZ_HM_HOSPITAL_MASTER_EXTN`, `BJAZ_REMEDINET_CLAIM_DETAILS`,
   `BJAZ_TPA_CLAIM_DETAILS_WS`. Affects `SAT_ORG_UNIT_DEFINITION`.
8. **`HUB_LOCATION`** missing on `BJAZ_HM_HCM_EXTRACT`, `BJAZ_HM_HOSPITAL_MASTER_EXTN`.
   Affects `SAT_COMMON_ADMIN_GEOGRAPHY`, `SAT_LOCATION_PROFILE`.
9. **`HUB_PARTY`** missing on `BJAZ_HM_OUTWARD_DTLS` (has a `HUB_CLAIM` key only — is there
   a recipient/party column?), `BJAZ_HM_POLICY_USERMAPPING` (has a `HUB_POLICY` key only —
   is there a user/party column?). Affects `SAT_PARTY_CORRESPONDENCE`,
   `SAT_PARTY_DIGITAL_IDENTITY`.
10. **`HUB_PRODUCT`** missing on `BJAZ_HM_EXCLUSION_MASTER` (has `EXCLUSION_ID`/
    `EXCLUSION_CODE` but no product link — is exclusion scoped to a product at all?) and
    `BJAZ_ECARD_POL_DTLS_CONFIG` (has `HUB_POLICY`/`HUB_QUOTE` keys only). Affects
    `SAT_PRODUCT_EXCLUSION_CATALOGUE`, `SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES`,
    `SAT_PRODUCT_RATING_FACTOR`.
11. **`HUB_POLICY`** missing on `BJAZ_HM_HOSPITAL_MASTER`. Affects `SAT_COMMON_STATUS` — is
    this actually a hospital/provider status attribute, not a policy one?
12. **`HUB_REINSURANCE_TREATY`** missing on `BA_HCP_PROD_8428_GPG_LOADER`,
    `BA_HCP_PROD_8433_FHC_LOADER`. Affects `SAT_RI_CESSION_DETAIL`.

---

## C. Relationships/links with no supporting source column (16 links)

13. **No source table carries both parties' keys together** for: `LNK_AGREEMENT_PARTY`,
    `LNK_AGREEMENT_DOCUMENT`, `LNK_QUOTE_PROPOSAL`, `LNK_ASSESSMENT_DOCUMENT`,
    `LNK_FINTXN_CLAIM`, `LNK_FINTXN_PARTY`, `LNK_FINTXN_INSTRUMENT`, `LNK_FINTXN_TREATY`,
    `LNK_TREATY_PARTY`, `LNK_CLAIM_RI_RECOVERY`, `LNK_TREATY_DOCUMENT`. Do any of these
    relationships actually exist in Health source data on a table not yet reviewed, or are
    they genuinely out of scope for Health?
14. **`LNK_PARTY_RELATIONSHIP`** (party-to-party, e.g. family/guarantor) and
    **`LNK_PARTY_GROUP`** (household/corporate group membership) — every candidate column
    pair found was either a duplicate ID for the *same* party, or an unrelated role pair
    (agent vs. customer). Is family/household relationship data captured anywhere in Health
    source (e.g. a "Relationship To Proposer" style code), and if so on which table/column?
15. **`LNK_POLICY_RENEWAL`** — ~20 tables carry two policy-identifier columns, but in every
    one the second is a duplicate of the first, never a distinct *previous-term* policy
    reference. Is there a `PREV_POLICY_NO`/`PREVIOUS_CONTRACT_ID`-style column anywhere that
    was missed?
16. **`LNK_POLICY_ENDORSEMENT`** — needs an endorsement/transaction-sequence column
    identifying each amendment event on a policy. Is there one (e.g. a `VERSION_NO` that
    specifically means "endorsement sequence," as opposed to a generic row-versioning
    column)?
17. **`LNK_COVERAGE_HIERARCHY`** (coverage-to-parent-coverage, e.g. rider on base cover) — no
    table has two distinct coverage-key columns. Is there a "parent coverage code" anywhere?

---

## D. Reference code masters (2)

18. **`REF_RELATIONSHIP_TYPE`** and **`REF_EXCLUSION`** — only *usages* of these codes were
    found (`ASSIGNEE_RELATION`, `EXLCUSIONS` on `BJAZ_CTNGY_PA_MEM_DTLS`), never a source
    table defining the code list itself. For `REF_EXCLUSION`, is `BJAZ_HM_EXCLUSION_MASTER`
    (`EXCLUSION_ID`/`EXCLUSION_CODE`) the intended master — it currently has zero mapped
    rows? Where does `REF_RELATIONSHIP_TYPE`'s code list live?

---

## E. Lower priority — spot-check only

19. **213 "discovered" hub keys** (`docs/appendix_7_discovered_hub_keys.csv`) were added by
    matching column names against known key-column names for that hub, not explicitly
    reviewed by a person. Worth a sample spot-check, not a full review — flag anything that
    looks wrong.
