# DM-H Member Test Plan (History & Change Checks / CDC)

Trimmed, macro-path-based assignment of satellites for the DM-H sign-off checks
(DM-H1..DM-H4). Instead of running all 157 satellites, each of the 3 team members
runs a representative set that, per macro code path, spans both projects
(MAXIMUS / OPUS) and both layers (standard / augmented) where such models exist.

All four checks (DM-H1, DM-H2, DM-H3, DM-H4) are run against EVERY satellite in a
member's list.

## Why these paths

The real logic under test is the satellite-building code path, not the satellite
content. There are five sat-building paths plus one upstream-input path:

| Path | What it exercises |
|------|-------------------|
| `automate_dv.sat` | default single-source, row-level HASHDIFF change detection |
| `sat_multi_source` (plain) | multi-source UNION ALL + LAG HASHDIFF change detection |
| `sat_multi_source` (OBJECT) | `src_object_columns` -> `OBJECT_AGG(table:value)`, different HASHDIFF recompute |
| `ma_sat_multi_source` | multi-active, group-based change detection (`src_cdk`) |
| `automate_dv.ma_sat` | default multi-active |
| `stitch_incremental` (upstream) | watermark window + coalesce priority feeding a sat |

Note on the stitch path: the stitch runs in the UPSTREAM stg2 lineage, so the
satellite macro itself is usually `automate_dv.sat` or `sat_multi_source`. These
sats are grouped under the stitch path because of their stitch-fed lineage, which
is what DM-H's re-load / watermark behaviour depends on.

## Population vs. coverage

| Path | Population (MAXI+OPUS) | Distinct covered | Coverage |
|------|-----------------------|------------------|----------|
| `automate_dv.sat` | 102 | 6 | 6% |
| `sat_multi_source` plain | 39 | 21 | 54% |
| `sat_multi_source` OBJECT | 4 | 4 | 100% |
| `ma_sat_multi_source` | 5 | 5 | 100% |
| `automate_dv.ma_sat` | 7 | 7 | 100% |
| `stitch_incremental` | 15 | 15 | 100% |

## Important: 0-record satellites

Some satellites may have 0 rows loaded. If a member's assigned sat has 0 records,
that sat cannot produce DM-H evidence -- the member must SWAP it for another sat
of the SAME macro path from the remaining pool.

1. Before testing, run `DM-H_ROWCOUNT_CHECK.sql` to see the row count of every
   assigned sat.
2. If an assigned sat shows 0 rows, open `DM-H_REMAINING.md`, find the SAME path,
   and pick an unused sat from the remaining list.
3. Record the swap (old -> new) in your results so the mapping stays traceable.

---

## Path 1 - `automate_dv.sat` (default single-source) - 2 per member

| Member 1 | Member 2 | Member 3 |
|----------|----------|----------|
| sat_common_admin_geography (MAXI std, shared) | sat_common_consent (MAXI std, shared) | sat_common_classification (MAXI std, shared) |
| sat_party_financial_profile (MAXI std) | sat_party_fraud_profile (MAXI std) | sat_party_relationship_profile (MAXI std) |

## Path 2 - `sat_multi_source` plain - 7 per member

| # | Member 1 | Member 2 | Member 3 |
|---|----------|----------|----------|
| 1 | sat_common_address (MAXI std, alias) | sat_common_geo (MAXI std, alias) | sat_party_hierarchy (MAXI std) |
| 2 | sat_party_banking (MAXI std, alias) | sat_party_organisation_profile (MAXI std, alias) | sat_party_agent_licence_line (MAXI std) |
| 3 | sat_party_identity (MAXI std, alias) | sat_party_individual_demographics (MAXI std, alias) | sat_party_payout_profile (MAXI std) |
| 4 | sat_location_profile (MAXI std) | sat_party_consent_mandate (MAXI std) | sat_aug_party_identification (MAXI aug) |
| 5 | sat_party_vehicle_prior_insurance (OPUS std) | sat_party_banking (OPUS std) | sat_party_kyc_reference (OPUS std) |
| 6 | sat_policy_certificate (OPUS std) | sat_party_kyc (OPUS std) | sat_policy_premium_summary (OPUS std) |
| 7 | sat_aug_party (OPUS aug) | sat_aug_kyc_document (OPUS aug) | sat_aug_location (OPUS aug) |

## Path 3 - `sat_multi_source` OBJECT (table:value) - 4 total

| Member 1 | Member 2 | Member 3 |
|----------|----------|----------|
| sat_common_contact (MAXI std, alias) | sat_party_identification (MAXI std, alias) | sat_common_contact (OPUS std) |
| sat_party_identification (OPUS std) | - | - |

## Path 4 - `ma_sat_multi_source` (multi-active) - 5 total

| Member 1 | Member 2 | Member 3 |
|----------|----------|----------|
| sat_lnk_party_role_core (MAXI std, shared) | sat_party_contact_address_link (OPUS std) | sat_policy_classification (OPUS std) |
| sat_party_digital_identity (MAXI std) | sat_aug_policy (OPUS aug) | (reuse sat_lnk_party_role_core) |

## Path 5 - `automate_dv.ma_sat` (default multi-active) - 7 total

| Member 1 | Member 2 | Member 3 |
|----------|----------|----------|
| sat_party_org_directors (MAXI std) | sat_party_provider_capability (MAXI std) | sat_aug_party_legal_panel_role_line (MAXI aug) |
| sat_lnk_claim_party_role (OPUS std) | sat_lnk_policy_party_role (OPUS std) | sat_lnk_party_role_core (OPUS std) |
| sat_party_contact_address_link (MAXI std) | - | - |

## Path 6 - `stitch_incremental` upstream (all OPUS) - 5 per member

| # | Member 1 | Member 2 | Member 3 |
|---|----------|----------|----------|
| 1 | sat_common_address | sat_common_geo | sat_common_classification |
| 2 | sat_policy_header | sat_party_health_profile | sat_provider_banking |
| 3 | sat_party_identity | sat_product_definition | sat_policy_bonus_tracking |
| 4 | sat_common_admin_geography | sat_common_communication_preference | sat_party_claim_history |
| 5 | sat_party_individual_demographics | sat_party_employment | sat_party_organisation_profile |

## Per-member load

| Member | Total models |
|--------|--------------|
| Member 1 | 2 + 7 + 2 + 2 + 3 + 5 = 21 |
| Member 2 | 2 + 7 + 1 + 2 + 2 + 5 = 19 |
| Member 3 | 2 + 7 + 1 + 1 + 2 + 5 = 18 |

Reuse points (data depth limits): `sat_common_contact` (Path 3, M1 & M3),
`sat_lnk_party_role_core` (Path 4, M1 & M3).
