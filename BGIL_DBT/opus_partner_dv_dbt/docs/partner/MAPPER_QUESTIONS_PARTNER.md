# Mapper follow-up: Partner LOB build

Issues found while building `partner_dv_dbt` from `Partner_SourceToModel_Mapping.xlsx` +
`EMPOWER_INGESTION_MASTER.json` + `SF_OPUS_GG_DWHSTAGE_Sample_Data_V2.xlsx`. Grouped by what
kind of decision is needed.

## 1. Discovered key needs an explicit tag

`BJAZ_PINCODE` and `BJAZ_PINCODE_MASTER` — `PINCODE` was used as a `HUB_LOCATION` key
(matches the same discovered-key pattern used elsewhere in the mapping), but neither table
has an explicit `KEY:HUB_LOCATION` tag on that column in the mapping. Please confirm and add
the tag so this isn't re-derived by inference next time.

## 2. Composite keys evaluated and NOT applied — please confirm or correct

9 tables carry a `CONTRACT_ID` + `OBJECT_ID` (+ sometimes `VERSION_NO`) column combination
that looked like a plausible composite key from the primary-key reference file structure
alone. Checking real sample values in `SF_OPUS_GG_DWHSTAGE_Sample_Data_V2.xlsx` changed that
conclusion: `OBJECT_ID` values look like large, source-system-internal surrogate IDs (not
stable/re-derivable across reloads), which fails the composite-key litmus test (a key must
be stable, not just locally unique at a point in time). Where a `MEMBER_NO`-style column is
also present, it looks like a genuine small per-policy sequence and would be a safer
candidate — but that's a judgment call, not applied unilaterally here.

**Not applied — flagged for mapper judgment**, not built into any hub/link in this project:
the 9 affected tables (list available on request / in the build's discovered-key working
notes) all carry this pattern. Applying any of them requires the mapper to confirm
`OBJECT_ID` (or the alternative `MEMBER_NO`) as a real, stable identifier for that table.

**Applied** (for contrast, one case that *did* pass the same check): `BJAZ_INTERMEDIARY.
INTERMEDIARY_ID → HUB_AGREEMENT` — confirmed via sample data as a dedicated, always-
populated, purpose-named ID space. Used as a discovered key in the standard-model build.

## 3. Tables with no verified key to a satellite's required hub

`SAT_CHANNEL_DEFINITION` (parent `HUB_DISTRIBUTION_CHANNEL`) and `SAT_AGREEMENT_DEFINITION`
(parent `HUB_AGREEMENT`, for `BJAZ_INTERMEDIARY_HIST` specifically) each have real,
mapper-flagged columns in the Augmentation sheet — but the source tables carrying those
columns (`BJAZ_INTERMEDIARY`, `AZBJ_PARTNER_EXTN`, `BJAZ_AZBJ_PART_EXT_HIST`,
`BJAZ_CLM_SUPP_EXTN`, `BJAZ_INTERMEDIARY_HIST`, and others — 38 columns total across both
satellites) don't carry a verified key to the required parent hub. `HUB_DISTRIBUTION_CHANNEL`
in particular has **zero** verified Partner keys anywhere in the mapping — this is a bigger
gap than any one attribute; it's a missing key for the whole hub in this LOB. If a channel/
sub-channel code exists somewhere in these tables that should serve as the `HUB_DISTRIBUTION_
CHANNEL` key, please point us at it.

Related — 12 satellites total have zero buildable source in Partner's mapping:
`SAT_INSTRUMENT_DEFINITION`, `SAT_CHANNEL_DEFINITION`, `SAT_FINTXN_PREMIUM`,
`SAT_FINTXN_HEADER`, `SAT_RISK_HEALTH_MEMBER_MEDICAL`, `SAT_COVERAGE_MEMBER_BENEFIT`,
`SAT_FINTXN_TAX`, `SAT_COVERAGE_CONDITIONS`, `SAT_COVERAGE_LIMITS`, `SAT_ASSESSMENT_MEDICAL`,
`SAT_ASSESSMENT_HEADER`, `SAT_RISK_PERSON_INSURED`.

## 4. Missing key blocks an existing satellite

`AZBJ_ADDRESS_EXTN` has no mapped `HUB_PARTY` key. It's the only other table besides
`BJAZ_CP_ADDRESS_LINK` that carries address-usage-link attributes, so this blocks its
contribution to `SAT_LNK_ROLE_CUSTOMER` and `SAT_PARTY_CONTACT_ADDRESS_LINK` — both were
built from `BJAZ_CP_ADDRESS_LINK` alone. If `AZBJ_ADDRESS_EXTN` has a party key we're
missing, both satellites would gain a second contributing table.

## 5. Core attribute genuinely unmapped

`SAT_LNK_POLICY_PARTY_ROLE`'s defining attribute, **"Party Role Type"** (policyholder /
insured / agent / nominee / etc.), is not mapped anywhere in Partner's source. Only "Role
Sequence" (`OCP_INTERESTED_PARTIES.IP_NO`) is mapped. The satellite was built with Role
Sequence as the sole childkey — every other canonical attribute (Party Role Type itself,
Role Category, Attribution Percentage, Role Effective/End Date, Primary Indicator, Role
Status, Appointment Reference) is left unbuilt rather than fabricated.

## 6. Augmentation sheet — non-canonical `Target Satellite` values (111 of 169 rows)

The Augmentation (modeler) sheet's `Target Satellite` column has three categories of value
that don't map to a directly-buildable hub-parented satellite in this build:

- **Link-parented targets (73 rows: 47 `SAT_LNK_ROLE_PROVIDER`, 5 `SAT_LNK_ROLE_SURVEYOR`, 2
  `SAT_LNK_ROLE_AGENT`, 1 `SAT_LNK_ROLE_CUSTOMER`)** — these are real canonical satellites,
  but they're parented on a link (`LNK_PARTY_ROLE`), not a hub. This build's augmented-track
  generator only handles hub-parented satellites; extending it to link-parented augmented
  satellites is a reasonable next step but wasn't attempted here — flagging rather than
  guessing at the join.
- **1 row targets `LNK_PARTY_ROLE` directly** (`CLM_INTERESTED_PARTIES.IP_NO`, proposed
  attribute "Interested Party Sequence") — that's a link code, not a satellite. Likely meant
  one of the `SAT_LNK_ROLE_*` satellites above; please confirm which.
- **17 rows are explicitly typed `NEW SATELLITE`**, proposing satellite names that don't
  exist in `data_5a.js` at all: `Lawyer / advocate role satellite` (13 rows) and `Affinity /
  association membership satellite` (4 rows). These need a formal model decision from the
  modeler — a new canonical satellite added to `data_5a.js` — before they can be built, the
  same way `SAT_LNK_POLICY_PARTY_ROLE` needed a model confirmation (M2, Health build) before
  it could be built there.

Of the 169 augmentation rows, 58 were built as-is into 4 augmented satellites (`SAT_AUG_
PARTY`, `SAT_AUG_POLICY`, `SAT_AUG_LOCATION`, `SAT_AUG_AGREEMENT`) — see `README.md`'s Known
gaps section for the per-satellite attribute/table counts.
