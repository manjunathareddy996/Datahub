# Builder asks -- OPUS Health, central-view rebuild (v4)

This is what the builder could not resolve from the pinned inputs, routed by whose call each item is. The builder raises and leaves: it does not correct the mapping, and it does not settle a question of meaning on anyone's behalf. A builder who resolves a grain question has changed a primary key, and nothing downstream can tell that happened.

No count in this document is restated in prose. Every figure lives in `build_artifacts/BUILD_STATUS.json` and `build_artifacts/reports/`, and is recomputed on every build.

## 0. The first item is not a mapping question

`BUILD_RULES.md` section 6 describes its per-source-table layer architecture as *"Invariant across every build"*: one cast per mapped view, one wide stage per view, and satellites whose payload is the union over all feeders. The rule this build was instructed to follow says the opposite -- a satellite is fed WHOLE by one central view, so it has one feeder by construction and there is nothing to union.

Both cannot hold. This build implements the central-view rule, as instructed, and did **not** edit section 6: a build does not rewrite the law it is judged by. The rule as stated is recorded verbatim in `build_profile.json` under `central_view_rule`, together with the hub and link extension.

Worth recording why this matters beyond this build: the rule was implemented once before, in gen 1's `health_dv_dbt/models/automate_dv/standard/stitched/` views, and was written down nowhere. That is why every build after gen 1 drifted away from it, each one passing its gates. **Whose call:** the user's.

## 1. A correction to a figure this builder already reported

An earlier pass of this rebuild reported that five model hubs -- `HUB_AGREEMENT`, `HUB_FINANCIAL_ACCOUNT`, `HUB_LOSS_EVENT`, `HUB_PAYMENT_INSTRUMENT`, `HUB_REINSURANCE_TREATY` -- were keyed nowhere in the map, and refused a number of satellites and links on that basis. The superseded figures are recorded by reference in `build_artifacts/BUILD_STATUS.json` under `corrections`, rather than restated here: a corrected figure typed into prose goes stale exactly as readily as the wrong one did.

That was wrong, and the fault was the builder's. Key slots come from **two** sources: `resolved_key` in the map, which the profile measures as present on zero legacy rows, and the legacy half's key forms, which exist in no map and are recovered read-only from `health_dv_dbt`'s emitted SQL. The first pass swept only the map. All five hubs are keyed on the legacy half; the real figure is in `BUILD_STATUS.json` under `map_coverage.model_hubs_keyed`. No mapper action is needed on those five.

source: every count in this section is in `build_artifacts/reports/unresolved_register.json`, recomputed each build

It is recorded here rather than quietly fixed because the wrong figure was reported before it was caught, and a zero from a probe that looked in one of two places is indistinguishable from a clean result.

## 2. For the mapper

source: every count in this section is in `build_artifacts/reports/unresolved_register.json`, recomputed each build

### child key leg unresolved

**What it is.** data_7.js declares the satellite multi-active with a child key, and at least one leg of that child key resolves to no column on any table of the satellite's own view. The legs are NOT rendered: a wrong child key is unrecoverable after load.

**What would unblock it.** Map each declared leg to a real column on a table that view joins, or have the modeller narrow the declared child key to the legs the source can supply.

**Affected objects** (full list in the register): `SAT_CASE_EXTERNAL_REF`, `SAT_CLAIM_BILL_DIGITISATION`, `SAT_CLAIM_COMMUNICATION`, `SAT_CLAIM_NOTE`, `SAT_CLAIM_RESERVE`, `SAT_CLAIM_RESERVE_HEAD`, `SAT_COMMON_CONTACT`, `SAT_COVERAGE_SUBLIMIT_SCHEDULE`, `SAT_FINTXN_COMMISSION`, `SAT_FINTXN_RECON_INSTRUMENT`, `SAT_FIN_CHARGE_RATE`, `SAT_LNK_PARTY_ROLE_CORE`, and more

### link leg not staged on its view

**What it is.** The link's view stages no hash key for one of its legs, usually because that hub's key slot on the relevant table is ambiguous. The link is not emitted from a partial grain: a link row with a null leg records a relationship to nothing.

**What would unblock it.** Disambiguate the leg hub's key slot on a table that view joins.

**Affected objects** (full list in the register): `LNK_CHANNEL_ORG_UNIT`, `LNK_CLAIM_COVERAGE`, `LNK_CLAIM_DOCUMENT`, `LNK_COVERAGE_HIERARCHY`, `LNK_LOSS_EVENT_LOCATION`, `LNK_ORG_UNIT_HIERARCHY`, `LNK_ORG_UNIT_LOCATION`, `LNK_PARTY_ORG_UNIT`, `LNK_POLICY_COVERAGE`, `LNK_POLICY_COVERAGE_RISK`, `LNK_POLICY_ORG_UNIT`, `LNK_PRODUCT_COVERAGE`

### payload withheld table not joinable

**What it is.** Attributes of this satellite sit on a table refused from its own view's join, so they are withheld rather than multiplied in by a cross join.

**What would unblock it.** Same fix as the join-path item: give the table a shared key, or confirm the attributes are dropped.

**Affected objects** (full list in the register): `SAT_CASE_EXTERNAL_REF`, `SAT_CLAIM_HEADER`, `SAT_LNK_PARTY_ROLE_CORE`, `SAT_PARTY_HEALTH_PROFILE`, `SAT_PRODUCT_EXCLUSION_CATALOGUE`

### proposed satellite anchor not staged

**What it is.** A proposed payload could not be keyed: no hash key for its anchor is staged on its view.

**What would unblock it.** Supply a key expression for that hub on a table the view joins.

**Affected objects** (full list in the register): `SAT_COMMON_GEO`, `SAT_COVERAGE_CONDITIONS`, `SAT_COVERAGE_LIVES_COUNT`, `SAT_COVERAGE_MEMBER_BENEFIT`, `SAT_COVERAGE_SUBLIMIT_SCHEDULE`, `SAT_LOCATION_PROFILE`

### satellite anchor key not staged

**What it is.** The satellite's own central view stages no hash key for its anchor hub, so it cannot be keyed from the view it is built on.

**What would unblock it.** Supply a key expression for that hub on a table the view joins.

**Affected objects** (full list in the register): `SAT_COMMON_GEO`, `SAT_COVERAGE_CONDITIONS`, `SAT_COVERAGE_LIVES_COUNT`, `SAT_COVERAGE_MEMBER_BENEFIT`, `SAT_COVERAGE_SUBLIMIT_SCHEDULE`, `SAT_LOCATION_PROFILE`

### satellite has no renderable payload on its view

**What it is.** The satellite's own central view rendered none of its attributes, so there is nothing to hash and no satellite is emitted.

**What would unblock it.** Check the attribute names against data_7.js; an attribute recorded as a descriptive phrase is not rendered into a column.

**Affected objects** (full list in the register): `SAT_CASE_EXTERNAL_REF`, `SAT_PRODUCT_EXCLUSION_CATALOGUE`

### source table grouped but never joined

**What it is.** The plan grouped this table into one or more views because a satellite needs its columns, but every one of those views refused it from its join. Nothing reads it, so no staging model is emitted for it -- an unread staging model is dead code that reads as work (source: build_profile.json and BUILD_STATUS.json cross_build_facts, for how many a sibling build shipped).

**What would unblock it.** Resolve the join-path or ambiguous-slot item registered against the same table, and it will be staged and joined on the next build.

**Affected objects** (full list in the register): `BJAZ_HM_CLAIM_STATUS_DASH_APP`, `BJAZ_HM_EXCLUSION_MASTER`, `BJAZ_HM_INWARD_OMNI_MAPPING`

## 3. For the modeller

source: every count in this section is in `build_artifacts/reports/unresolved_register.json`, recomputed each build

### payload column is also a child key leg

**What it is.** A column is both a child-key leg and a payload attribute of the same satellite. The leg is kept because it is part of the grain; the payload copy is withheld rather than selected twice.

**What would unblock it.** Confirm the column belongs in the grain and not also in the payload, or rename one.

**Affected objects** (full list in the register): `SAT_CLAIM_BENEFIT_HEAD`, `SAT_CLAIM_COMMUNICATION`, `SAT_CLAIM_PROVIDER_BILLING`, `SAT_DOCUMENT_CHECKLIST`, `SAT_FINTXN_TAX`, `SAT_LNK_POLICY_PARTY_ROLE`, `SAT_PARTY_BANKING`, `SAT_POLICY_CERTIFICATE`, `SAT_POLICY_CLASSIFICATION`, `SAT_POLICY_COVERAGE_SCHEDULE`, `SAT_POLICY_ENDORSEMENT`, `SAT_POLICY_INSTALMENT_SCHEDULE`, and more

### proposed satellite has no central view

**What it is.** The map proposes attributes for a satellite that no central view feeds, so there is nothing to propose them FROM.

**What would unblock it.** Either ratify the satellite in data_7.js so it acquires an anchor and a view, or withdraw the proposal.

**Affected objects** (full list in the register): `Product Configuration Parameter (name/value)`, `REF_BANK_BRANCH_IFSC`, `REF_DISEASE_ICD`, `REF_MEDICAL_CHARGE_HEAD`, `REF_MEDICAL_PROCEDURE`, `REF_ROOM_CATEGORY`, `SAT_AGREEMENT_PERIOD`, `SAT_AGREEMENT_PROVIDER_DISCOUNT_LINE (multi-active)`, `SAT_AGREEMENT_SERVICE_SCOPE (multi-active: one active row per service in the TPA agreement scope)`, `SAT_ASSESSMENT_DIAGNOSIS (medical diagnosis / ICD lines per assessment, multi-active)`, `SAT_ASSESSMENT_FRAUD_INVESTIGATION`, `SAT_ASSESSMENT_RISK_RULE_DEFINITION`, and more

## 4. For the source owner

source: every count in this section is in `build_artifacts/reports/unresolved_register.json`, recomputed each build

### undefined udf normalise

**What it is.** normalise() appears verbatim inside map-supplied content-hash key expressions and is defined nowhere in this project or in either original project.

**What would unblock it.** Create the UDF in the warehouse, or have the mapper replace the expressions. The builder did not rewrite them, because a tidied key is a different key and would not reproduce legacy's hash values.

**Affected objects** (full list in the register): `normalise()`

## 5. What the builder decided, and how to overrule each one

Each of these is a RENDERING choice the builder is entitled to make. None is a question of meaning. Each is named so it can be overruled in one place.

| Decision | Where it lives | Overrule by |
| --- | --- | --- |
| Run precedence for a sideways merge: v2 > legacy > delta3 | `hcon4_emit.RUN_RANK` | change that mapping |
| A link is placed on the SMALLEST view carrying all its legs | `hcon4_plan.build_plan`, link placement | change the `min()` key |
| A rule-4 pull-in takes the most-populated key registry for the hub | `hcon4_plan.build_plan`, candidate scoring | change the sort key; alternatives not taken are recorded per satellite in `stitch_plan.json` |
| Every column is cast to varchar | `gen_hcon4_staging.py` | supply a datatype catalogue; the bundle carries none, and a type inferred from a column name is a fabricated datum |
| A child-key leg that is also a payload attribute keeps the LEG | `gen_hcon4_vault.py` | reverse it, or rename one of the two |

## 6. What was verified, and what was not

Results are in `build_artifacts/reports/verification.json`, with four outcomes per check -- PASS, FAIL, NOT RUN, DID NOT COMPLETE -- each carrying the population it ran over. A PASS over an empty population is reported as NOT RUN.

Three of this architecture's assumptions are facts about DATA, not about SQL, so no generator can verify them. They are emitted as runtime assertions in `models/assertions/` instead of being assumed: whether each central view holds the grain its dedupe claims, whether a satellite lost its payload to the hashdiff guard, and whether any satellite row is orphaned from its hub. Their count is in `BUILD_STATUS.json`.

