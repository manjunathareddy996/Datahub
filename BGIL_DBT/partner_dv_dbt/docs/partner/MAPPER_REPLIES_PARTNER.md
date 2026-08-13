# Mapper replies — Partner LOB build feedback

Answers to `feedback/MAPPER_QUESTIONS_PARTNER.md`. Checked against the OPUS catalogue and
`data_v5a`. The mapping workbook (`Partner_SourceToModel_Mapping.xlsx`) is **updated** with the
concrete tag fixes below (7 edits; mapped 774 → 776).

> **Policy update (this project):** no more canonical model augmentation unless an item is
> **critical**. Everything else the builder absorbs into **builder-side augmented satellites**
> (`SAT_AUG_*`). So Part 2 below is **build-side by default — no modeler round-trip and no
> checkpoint back to the mapper**. Partner has **no critical items**, so the developer builds the
> 776 mapped columns *and* the augmented satellites for the 167 in a single pass.
>
> **Critical (still → modeler):** a hub/link **key or grain** change; a **shared reference master**;
> a satellite/attribute **another LOB also needs** (conformance); removing/re-parenting an existing
> object. **Build-side (default):** LOB-local missing attributes, LOB-local new satellites,
> repeating-group child keys.
>
> **Promotion trigger:** if the same augmented concept reappears in another LOB (Motor is next), it
> gets promoted to the canonical model then. The mapper will flag cross-LOB overlaps as promote
> candidates as they appear.

## Part 1 — replies to you (developer)

### 1. `BJAZ_PINCODE` / `BJAZ_PINCODE_MASTER` — PINCODE key ✅ tagged
Confirmed: `PINCODE` **is** the `HUB_LOCATION` business key on both. It was previously mapped only
as the `SAT_COMMON_ADMIN_GEOGRAPHY.Pin Code` attribute (which is why no explicit key existed). I've
retagged both as `KEY:HUB_LOCATION` in the workbook — the same column still populates the Pin Code
attribute (key echoed as attribute). `ZONE_PIN`/`SOURCE_PIN` stay as attributes, not keys.

### 2. Composite keys / `OBJECT_ID` — you're right, confirmed
**Do not use `OBJECT_ID` as a key** — exactly the call we reached independently on the Health build:
it's the OPUS row surrogate (always travels with `VERSION_NO`/`PREVIOUS_VERSION`/`REVERSING_VERSION`),
not a stable business key. Your sample-data check is the correct litmus.

For the 9+ member tables, use the **`MEMBER_NO`/`MEM_SEQNO` composite** where present — it's a stable
per-policy member sequence:

| Table | Composite key |
|---|---|
| `BJAZ_EC_MEM_DTLS_EXTN`, `BJAZ_HCF_MEMBER_DTLS`, `BJAZ_HLT_ENSURE_MEM_DTLS`, `BJAZ_SH_MEM_DTLS_EXTN`, `BJAZ_SPP_MEMBER_DTLS` | `CONTRACT_ID ‖ MEMBER_NO` |
| `BA_HCP_DT_MEM` | `CONTRACT_ID ‖ MEM_SEQNO` |
| `BJAZ_CTNGY_FF_DTLS_EXTN`, `BJAZ_CTNGY_PA_MEM_DTLS`, `BJAZ_HC_PART_EXTN`, `BJAZ_HM_MEMBER_DTLS`, `BJAZ_PA_DETL_EXTN`, `BJAZ_STARPKG_FF_DTLS`, `OCP_INTERESTED_PARTIES` | no member column → key at **policy grain on `CONTRACT_ID`** alone (do not synthesize a member key from `OBJECT_ID`) |

`BJAZ_INTERMEDIARY.INTERMEDIARY_ID → HUB_AGREEMENT` — agreed, that one passes the litmus (dedicated,
always-populated, purpose-named). Keep it.

### 3. `HUB_DISTRIBUTION_CHANNEL` — no key was tagged ✅ fixed
The channel columns were mapped as `SAT_CHANNEL_DEFINITION` **attributes** with no key to hang them
on. The channel's business key is the **intermediary/IMD code**. Tagged in the workbook:

| Table | Column → `KEY:HUB_DISTRIBUTION_CHANNEL` |
|---|---|
| `BJAZ_INTERMEDIARY`, `BJAZ_INTERMEDIARY_HIST` | `IRDA_INTERMEDIARY_CODE` (regulator-issued, stable, purpose-named — same litmus as INTERMEDIARY_ID) |
| `BJAZ_CLM_SUPP_EXTN` | `IMD_CODE` |

`SUB_CHANNEL_CODE` / `BUSINESS_CHANNEL` stay as `SAT_CHANNEL_DEFINITION` attributes (the sub-channel
grain). This unblocks `SAT_CHANNEL_DEFINITION` and the 19 channel-flag augmentation columns.
Verify `IRDA_INTERMEDIARY_CODE` is always-populated in your sample data before relying on it as the
sole key; if sparse, fall back to `INTERMEDIARY_ID` scoped as the channel node.

**The 12 zero-source satellites:** most are **out-of-scope for Partner** — `SAT_FINTXN_*`,
`SAT_COVERAGE_*`, `SAT_RISK_HEALTH_MEMBER_MEDICAL`, `SAT_RISK_PERSON_INSURED`, `SAT_ASSESSMENT_*`,
`SAT_INSTRUMENT_DEFINITION` belong to the Policy/Claim/Health LOBs and are sourced there, not from
these 30 partner tables. Only `SAT_CHANNEL_DEFINITION` was a real Partner gap, now fixed by the
channel key above. Treat the other 11 as out-of-scope, not misses.

### 4. `AZBJ_ADDRESS_EXTN` — no `HUB_PARTY` key
This table has no explicit party-id column. Candidates: **`UNIQUE_ID`** (most likely the party/customer
key) or it resolves to the party only via **`POLICY_REF` → policy → party**. It does carry proposer
context (`PRPOSER_FLAG`, `PRPOSER_DTLS`) but no proposer id. **Recommendation:** check `UNIQUE_ID` in
sample data — if it's the customer/party identifier, tag it `KEY:HUB_PARTY` and this table joins
`SAT_LNK_ROLE_CUSTOMER` / `SAT_PARTY_CONTACT_ADDRESS_LINK` as a second source. If `UNIQUE_ID` is an
address/row surrogate, this table can't contribute a party key and its address attributes attach via
the policy's party. I did not tag it blindly — needs the sample-data confirm.

### 5. `SAT_LNK_POLICY_PARTY_ROLE.Party Role Type` — now mapped ✅
It **is** in the source: `CLM_INTERESTED_PARTIES.IP_TYPE` is the interested-party role type
(financier / mortgagee / nominee / assignee / …). It was sitting in Augmentation; I've mapped it to
`SAT_LNK_POLICY_PARTY_ROLE.Party Role Type`. So the satellite now has both **Party Role Type**
(`IP_TYPE`) and **Role Sequence** (`IP_NO`, see item 6). The remaining canonical attributes (Role
Category, Attribution %, Effective/End Date, Primary Indicator, Role Status, Appointment Reference)
genuinely have no Partner source — leave unbuilt, as you did.

### 6. Augmentation sheet — non-canonical targets
- **73 link-parented targets** (`SAT_LNK_ROLE_PROVIDER` ×47, `SAT_LNK_ROLE_SURVEYOR` ×5,
  `SAT_LNK_ROLE_AGENT` ×2, `SAT_LNK_ROLE_CUSTOMER` ×1): these targets are **correct** — they're real
  canonical satellites, just parented on `LNK_PARTY_ROLE`, not a hub. This is a **build-side**
  extension (your augmented-track generator needs to handle link-parented satellites, joining via
  `LNK_PARTY_ROLE` = party plays role), not a mapping error. No mapping change; extend the generator
  (same shape as any other link satellite you already build).
- **1 row `CLM_INTERESTED_PARTIES.IP_NO → LNK_PARTY_ROLE` directly** — you're right, that's a link, not
  a satellite. Fixed: retargeted to `SAT_LNK_POLICY_PARTY_ROLE.Role Sequence` (matches
  `OCP_INTERESTED_PARTIES.IP_NO`). Now mapped, out of augmentation.
- **17 `NEW SATELLITE` rows** (Lawyer/advocate ×13, Affinity/association ×4) — modeler decision, see
  Part 2.

**Net workbook change:** 7 edits — PINCODE key ×2, channel key ×3, `IP_TYPE`→Party Role Type,
`IP_NO`→Role Sequence. Mapped 774 → **776**; augmentation 169 → **167**. Validates clean vs
`data_v5a` (0 invalid, 0 collapse). The Column Funnel counts shift by the same 2.

---

## Part 2 — build-side augmented satellites (per policy — NOT a modeler round-trip)

All 167 augmentation columns are **build-side** for Partner. None is critical (no key/grain change,
no shared reference master, and none is used by another LOB *yet*). Build them as `SAT_AUG_*`
satellites in the same pass as the mapped columns — no wait on the modeler.

### P1. Two new (LOB-local) satellites → builder creates as augmented sats
Build-side; do **not** send to the modeler unless/until they recur in another LOB.
- **Lawyer / Advocate role** — grain: party plays lawyer/advocate role (`LNK_PARTY_ROLE`-style); 13
  attrs (Bar Association Name, Enrolment No, Covered Court Loc, Lawyer Type, Date Of Joining, Yr
  Experience, No Of Briefs/Consumer/Junior/Wc/Mact/Companies, Acd Qualification). Source:
  `BJAZ_CLM_SUPP_EXTN`. *(Watch item: a lawyer/advocate role could recur in Motor/Claims — if it
  does, promote to canonical then.)*
- **Affinity / Association Membership** — grain: `HUB_PARTY`; 2 attrs (Aa Membership Number, Aa
  Membership Expiry Date). Source: `AZBJ_PARTNER_EXTN`, `BJAZ_AZBJ_PART_EXT_HIST`.

### P2. 126 missing attributes on existing satellites → augmented sats
Attribute-only gaps on 24 existing satellites (largest: `SAT_LNK_ROLE_PROVIDER` 47,
`SAT_CHANNEL_DEFINITION` 19, `SAT_PARTY_KYC` 13). Carry them on the matching `SAT_AUG_*` beside the
canonical satellite. Full per-row list in the Augmentation sheet.

### P3. 41 possible repeating groups → builder child-key call
Columns colliding with a single-active attribute (bonus variants, BMI/height splits, address line
4/5). Builder's call: add slots, or a multi-active child-keyed augmented sibling — per-row list
flagged with the sibling attribute. No modeler decision needed.

### P4. `LICENSE_NO` dup-check (data-side, already flagged)
`BJAZ_INTERMEDIARY(_HIST).LICENSE_NO` and `BJAZ_CLM_SUPP_EXTN.SURVEYOR_LICENSE_NO` held vs the IRDA
licence sibling — confirm distinct licence vs duplicate in sample data before adding an attribute.

### Genuinely critical → modeler (Partner: NONE)
No Partner item meets the critical bar. If the cross-LOB overlap check (Motor next) matches any of
the above, that item is promoted to the canonical model at that point.
