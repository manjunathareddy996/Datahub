# Partner LOB — follow-up to mapper feedback round 2

Response to `docs/MAPPER_REPLIES_PARTNER.md`. Everything in that reply was implemented except
two items, both held back because the underlying data doesn't support what was asked — not a
disagreement, a data-quality catch. Also flagging one bug found independently while
implementing item 3 (the channel key).

## Implemented as specified
- `PINCODE → HUB_LOCATION` key tag (both pincode tables).
- `HUB_DISTRIBUTION_CHANNEL` key: `INTERMEDIARY_ID` fallback for `BJAZ_INTERMEDIARY`/`_HIST`
  (confirmed `IRDA_INTERMEDIARY_CODE` is too sparse — 0 and 10 non-null respectively out of
  ~10,000 sample rows, matching your own caveat), `IMD_CODE` for `BJAZ_CLM_SUPP_EXTN`. Built
  `HUB_DISTRIBUTION_CHANNEL` as a standard-model hub (not augmented) since the key is now
  real; `SAT_AUG_CHANNEL` carries the attribute columns.
- `CONTRACT_ID‖MEMBER_NO`/`MEM_SEQNO` composite: implemented as a **multi-active satellite
  child key**, not a hub-key composite. `SAT_AUG_POLICY` rebuilt from `sat()` to `ma_sat()`
  with `MEMBER_SEQUENCE` as the child key (real member number where the table has one, a `0`
  placeholder otherwise) — `HUB_POLICY` itself stays keyed on `CONTRACT_ID` alone, matching
  every other Partner table's grain. Modeling this as a hub-key composite instead would have
  put member-grain and contract-grain tables on two different hash values for the same real
  policy.
- The 5 policy-grain-alone tables (`CONTRACT_ID` only): key added to the registry.
- Link-parented `SAT_LNK_ROLE_*` augmentation targets: built as `SAT_AUG_LNK_ROLE_PROVIDER/
  SURVEYOR/AGENT/CUSTOMER`, reusing each table's existing role-special `PARTY_HKEY` formula.
- 2 new LOB-local satellites: `SAT_AUG_LAWYER_ADVOCATE_ROLE`, `SAT_AUG_AFFINITY_MEMBERSHIP`.
- P4 licence dup-check: `BJAZ_INTERMEDIARY(_HIST).LICENSE_NO` vs `IRDA_LICENSE_NO` — confirmed
  **distinct** (different format, different population rate in sample data); kept both.
  `BJAZ_CLM_SUPP_EXTN.LICENSE_NO` vs `SURVEYOR_LICENSE_NO` — these look like the **same**
  fact (`"IRDA/IND/SLA-nnnnn"` format on both; `SURVEYOR_LICENSE_NO` far more populated) —
  dropped `LICENSE_NO` from the augmented satellite rather than double-count it.

## Not implemented — data doesn't support it

**1. `CLM_INTERESTED_PARTIES.IP_TYPE`/`IP_NO` → `SAT_LNK_POLICY_PARTY_ROLE` (your item 5).**
`CLM_INTERESTED_PARTIES` only carries a verified key to `HUB_CLAIM` (`CLAIM_ID`) and
`HUB_PARTY` (`PART_ID`/`CLAIMANT`) — there is no `CONTRACT_ID` or any other policy-identifying
column on this table. `SAT_LNK_POLICY_PARTY_ROLE` is parented on `LNK_POLICY_PARTY`, which
needs a `POLICY_HKEY`. Building this would require either a genuine claim→policy join (not
present as a verified key anywhere) or re-scoping to a claim-parented link instead. `IP_TYPE`
here looks like it describes a **claim-time** interested-party role (financier / mortgagee /
assignee against a specific claim), not a **policy-time** one — a real, distinct fact, just
not the same fact as `SAT_LNK_POLICY_PARTY_ROLE`. Left unbuilt; `SAT_LNK_POLICY_PARTY_ROLE`
still has Role Sequence only (from `OCP_INTERESTED_PARTIES`), Party Role Type still unmapped.
**Question**: is there a `CLM_INTERESTED_PARTIES` → policy path we're missing (e.g. via
`CLAIM_ID` → policy), or is `IP_TYPE` genuinely a claim-role fact that belongs on a different
(possibly new) claim-parented satellite instead?

**2. `AZBJ_ADDRESS_EXTN.UNIQUE_ID` as a `HUB_PARTY` key (your item 4).** Checked in sample
data: `UNIQUE_ID` has only **3 non-null values out of ~10,000 rows** — far too sparse to
function as a party identifier for this table. `ADD_ID` (fully populated, 10,000/10,000) is
present but reads as an address-row surrogate, not a party key (matches the shape of every
other row-surrogate column we've flagged and rejected this build, e.g. `OBJECT_ID`). This
table still cannot contribute a party key with the columns available — `SAT_LNK_ROLE_
CUSTOMER` and `SAT_PARTY_CONTACT_ADDRESS_LINK` remain built from `BJAZ_CP_ADDRESS_LINK` only.

## Bug found independently (not from your reply)

`SAT_LNK_ROLE_SURVEYOR`'s `IRDAI_SURVEYOR_LICENCE_NUMBER` attribute was sourced from
`BJAZ_CLM_SUPP_EXTN.IRDA_LICENSE` — sample data shows this column only ever holds `Y`/`N`, a
flag, not a licence number. The real licence value is `SURVEYOR_LICENSE_NO` (format
`"IRDA/IND/SLA-nnnnn"`, 2,477 vs 231 non-null in sample). Re-pointed in the standard-model
build (`stg2_rolesat_bjaz_clm_supp_extn__lnk_role_surveyor.sql`). `IRDA_LICENSE` itself (the
Y/N flag) has no canonical attribute to attach to — flagging in case it's meant to be
something like a "Has IRDA Licence" indicator on a future satellite revision.
