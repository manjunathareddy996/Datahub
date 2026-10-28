# DM-H Remaining (Spare) Satellites — swap pool for 0-record cases

If an assigned satellite in `DM-H_MEMBER_PLAN.md` has 0 rows (confirm with
`DM-H_ROWCOUNT_CHECK.sql`), pick a replacement from the SAME macro path below.
Always swap within the same path so the code-path coverage is preserved.

Paths with 0 remaining (OBJECT, ma_sat_multi_source, automate_dv.ma_sat,
stitch_incremental) are already fully assigned — if one of those has 0 rows,
there is no same-path spare; note it as NOT TESTABLE (no loaded data) in results.

---

## Path 1 - `automate_dv.sat` (96 spare of 102)

### MAXIMUS - standard
- sat_channel_definition
- sat_common_communication_preference
- sat_document_definition
- sat_instrument_definition
- sat_lnk_role_agent
- sat_lnk_role_customer
- sat_lnk_role_employee
- sat_lnk_role_investigator
- sat_lnk_role_nominee_beneficiary
- sat_lnk_role_provider
- sat_lnk_role_surveyor
- sat_org_unit_definition
- sat_org_unit_licence
- sat_party_aml_screening
- sat_party_employment
- sat_party_health_profile
- sat_party_kyc
- sat_party_legal_panel
- sat_party_onboarding_journey
- sat_product_definition
- sat_provider_banking
- sat_provider_quality
- sat_provider_tariff

### MAXIMUS - augmented
- sat_aug_common_address
- sat_aug_common_admin_geography
- sat_aug_common_classification
- sat_aug_common_communication_preference
- sat_aug_common_contact
- sat_aug_common_geo
- sat_aug_instrument_definition
- sat_aug_lnk_party_role_core
- sat_aug_lnk_role_agent
- sat_aug_lnk_role_customer
- sat_aug_lnk_role_nominee_beneficiary
- sat_aug_lnk_role_provider
- sat_aug_lnk_role_surveyor
- sat_aug_party_agent_production
- sat_aug_party_amendment_endorsement
- sat_aug_party_claim_history
- sat_aug_party_contact_address_link
- sat_aug_party_correspondence
- sat_aug_party_credit_control_payment_terms
- sat_aug_party_digital_identity
- sat_aug_party_driving
- sat_aug_party_employment
- sat_aug_party_financial_profile
- sat_aug_party_fraud_profile
- sat_aug_party_group_scheme
- sat_aug_party_health_profile
- sat_aug_party_hierarchy
- sat_aug_party_interaction
- sat_aug_party_kyc
- sat_aug_party_legal_panel
- sat_aug_party_marketing
- sat_aug_party_onboarding_journey
- sat_aug_party_org_directors
- sat_aug_party_organisation_profile
- sat_aug_party_preference_profile
- sat_aug_party_provider_capability
- sat_aug_party_record_remarks
- sat_aug_party_relationship_profile
- sat_aug_party_service_engagement_terms
- sat_aug_party_source_property_set_record_governance
- sat_aug_party_suspension_negative_action
- sat_aug_party_vehicle_owner
- sat_aug_provider_banking
- sat_aug_provider_quality
- sat_aug_provider_tariff

### OPUS - standard
- sat_agreement_commercial_terms
- sat_agreement_definition
- sat_common_admin_geography
- sat_common_classification
- sat_common_communication_preference
- sat_common_consent
- sat_common_geo
- sat_lnk_role_agent
- sat_lnk_role_customer
- sat_lnk_role_surveyor
- sat_party_aml_screening
- sat_party_claim_history
- sat_party_employment
- sat_party_group_household
- sat_policy_bonus_tracking
- sat_policy_coverage_schedule
- sat_policy_endorsement
- sat_policy_header
- sat_product_definition
- sat_provider_banking
- sat_provider_tariff

### OPUS - augmented
- sat_aug_affinity_membership
- sat_aug_agreement
- sat_aug_kyc_policy
- sat_aug_lawyer_advocate_role
- sat_aug_lnk_role_agent
- sat_aug_lnk_role_customer
- sat_aug_lnk_role_surveyor

## Path 2 - `sat_multi_source` plain (18 spare of 39)

### MAXIMUS - augmented
- sat_aug_party_banking
- sat_aug_party_identity
- sat_aug_party_individual_demographics
- sat_aug_party_payout_profile

### OPUS - standard
- sat_common_address
- sat_document_definition
- sat_lnk_role_nominee_beneficiary
- sat_lnk_role_provider
- sat_party_group_census
- sat_party_health_profile
- sat_party_identity
- sat_party_individual_demographics
- sat_party_organisation_profile
- sat_policy_premium_head

### OPUS - augmented
- sat_aug_channel
- sat_aug_kyc_location
- sat_aug_kyc_party
- sat_aug_lnk_role_provider

## Path 3 - `sat_multi_source` OBJECT (0 spare of 4)
Fully assigned. No same-path spare.

## Path 4 - `ma_sat_multi_source` (0 spare of 5)
Fully assigned. No same-path spare.

## Path 5 - `automate_dv.ma_sat` (0 spare of 7)
Fully assigned. No same-path spare.

## Path 6 - `stitch_incremental` upstream (0 spare of 15)
Fully assigned. No same-path spare.
