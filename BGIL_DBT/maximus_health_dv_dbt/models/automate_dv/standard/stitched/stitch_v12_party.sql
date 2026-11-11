-- CENTRAL VIEW v12_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_INSTRUMENT_DEFINITION
--   SAT_AUG_PARTY_FINANCIAL_PROFILE
--   SAT_AUG_PARTY_HEALTH_PROFILE
--   SAT_COMMON_ADDRESS
--   SAT_PARTY_CONTACT_ADDRESS_LINK
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_GROUP_CENSUS
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_LOCATION
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address,'') || '#' || coalesce(t0.city1,'') || '#' || coalesce(t0.emiratesstatep,'') || '#' || coalesce(t0.zip_codep,'')), '###'))), '') as LOCATION_BK,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        cast(null as varchar) as PAYMENT_INSTRUMENT_BK,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__CHEQUE_PAYABLE_STATE,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__MANDATE_DEBIT_TYPE,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__MANDATE_MAXIMUM_AMOUNT,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__MANDATE_SIGNED_DATE,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__MANDATE_UNTIL_CANCELLED_INDICATOR,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__MICR_CODE,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__PAYABLE_AT_LOCATION,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__UTILITY_BILLER_CODE,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAILS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CHARGES_FILED_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCKED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCK_REASON,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAILS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_CIN_REFERENCE,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_PROFILE_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__EXEMPTED_INCOME,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__GROSS_INCOME,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME_DECLARED,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__SECONDARY_INCOME_AMOUNT,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__BEER_UNITS_PER_WEEK,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__ICD_DIAGNOSIS_CODE,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK,
        t0.address as COMMON_ADDRESS__ADDRESS_LINE_1,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_2,
        cast(null as varchar) as COMMON_ADDRESS__ADDRESS_LINE_3,
        cast(null as varchar) as COMMON_ADDRESS__BUILDING_NAME,
        cast(null as varchar) as COMMON_ADDRESS__CARE_OF_NAME,
        t0.city1 as COMMON_ADDRESS__CITY,
        cast(null as varchar) as COMMON_ADDRESS__COUNTRY_CODE,
        cast(null as varchar) as COMMON_ADDRESS__COUNTRY_NAME,
        cast(null as varchar) as COMMON_ADDRESS__DISTRICT,
        cast(null as varchar) as COMMON_ADDRESS__DOOR_NUMBER,
        cast(null as varchar) as COMMON_ADDRESS__FLOOR_NUMBER,
        t0.zip_codep as COMMON_ADDRESS__POSTAL_CODE,
        cast(null as varchar) as COMMON_ADDRESS__STATE_CODE,
        t0.emiratesstatep as COMMON_ADDRESS__STATE_NAME,
        cast(null as varchar) as COMMON_ADDRESS__STREET_NAME,
        cast(null as varchar) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        cast(null as varchar) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE,
        cast(null as varchar) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        cast(null as varchar) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        t0.credit_score as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE,
        cast(null as varchar) as PARTY_FINANCIAL_PROFILE__INCOME_SOURCE,
        cast(null as varchar) as PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK,
        cast(null as varchar) as PARTY_GROUP_CENSUS__DESIGNATION_BAND,
        cast(null as varchar) as PARTY_GROUP_CENSUS__EMPLOYEE_ID,
        cast(null as varchar) as PARTY_GROUP_CENSUS__EXIT_DATE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (coalesce(nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.address,'') || '#' || coalesce(t0.city1,'') || '#' || coalesce(t0.emiratesstatep,'') || '#' || coalesce(t0.zip_codep,'')), '###'))), ''))) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.hospital_code,'') || '|' || coalesce(t0.hospital_location,'')), '|'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.hospital_location as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.hospital_code,'') || '|' || coalesce(t0.hospital_location,'')), '|'))), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null, null, null, null, null, null,
        t0.pincode1 as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.emiratesstatep as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim('CHEQUE-SERVICING|' || coalesce(t0.cheque_servicing_state,'')), 'CHEQUE-SERVICING|'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cheque_servicing_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim('CHEQUE-SERVICING|' || coalesce(t0.cheque_servicing_state,'')), 'CHEQUE-SERVICING|'))), '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '') as LOCATION_BK,
        null,
        nullif('DDCHQ:' || nullif(trim(t0.ddcheque_reference),''), '') as PAYMENT_INSTRUMENT_BK,
        null,
        t0.cheque_servicing_state as AUG_INSTRUMENT_DEFINITION__CHEQUE_PAYABLE_STATE,
        null, null, null, null, null,
        t0.payble_at as AUG_INSTRUMENT_DEFINITION__PAYABLE_AT_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null, null, null, null, null, null,
        t0.pincode1 as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.emiratesstatep as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (coalesce(nullif('DDCHQ:' || nullif(trim(t0.ddcheque_reference),''), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), ''))) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
    select
        nullif('IFSC:' || upper(nullif(trim(t0.ifsc_code),'')), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bank_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif('IFSC:' || upper(nullif(trim(t0.ifsc_code),'')), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.city_code as COMMON_ADDRESS__CITY,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null,
        t0.district_code as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        t0.state_code as COMMON_ADDRESS__STATE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.effective_date as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null, null, null, null, null, null,
        t0.pincode1 as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.emiratesstatep as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim('CHEQUE-SERVICING|' || coalesce(t0.cheque_servicing_state,'')), 'CHEQUE-SERVICING|'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cheque_servicing_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim('CHEQUE-SERVICING|' || coalesce(t0.cheque_servicing_state,'')), 'CHEQUE-SERVICING|'))), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(t0.address_of_nominee), ''))), '') as LOCATION_BK,
        nullif(nullif(trim(t0.member_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.spirits_consumption_per_week as AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK,
        null,
        t0.wine_consumption_per_week as AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK,
        t0.address_of_nominee as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_msa_pv') }} t0
    where (coalesce(nullif(md5(normalise(nullif(trim(t0.address_of_nominee), ''))), ''), nullif(nullif(trim(t0.member_code),''), ''))) is not null

    union all

    -- branch 11: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.address_with_pin_code,'')), '|||'))), '') as LOCATION_BK,
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.emp_number as PARTY_GROUP_CENSUS__EMPLOYEE_ID,
        null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.address_with_pin_code,'')), '|||'))), ''), nullif(nullif(trim(t0.policyholder_code),''), ''))) is not null

    union all

    -- branch 12: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.bank_name,'') || '|' || coalesce(t0.branch_name_out,'') || '|' || coalesce(t0.bank_branch_address,'') || '|' || coalesce(t0.bank_city,'')), '|||'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.bank_branch_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null,
        t0.bank_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.bank_name,'') || '|' || coalesce(t0.branch_name_out,'') || '|' || coalesce(t0.bank_branch_address,'') || '|' || coalesce(t0.bank_city,'')), '|||'))), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.door,'') || '#' || coalesce(t0.district_name,'') || '#' || coalesce(t0.policyholder_city,'') || '#' || coalesce(t0.policyholder_zip_code,'')), '###'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.district_name as COMMON_ADDRESS__DISTRICT,
        t0.door as COMMON_ADDRESS__DOOR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.door,'') || '#' || coalesce(t0.district_name,'') || '#' || coalesce(t0.policyholder_city,'') || '#' || coalesce(t0.policyholder_zip_code,'')), '###'))), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.policyholder_door,'') || '#' || coalesce(t0.policyholder_floor,'') || '#' || coalesce(t0.policyholder_stair,'') || '#' || coalesce(t0.policyholder_road,'') || '#' || coalesce(t0.policyholder_additional_space_for_road,'') || '#' || coalesce(t0.policyholder_city,'') || '#' || coalesce(t0.policyholder_province,'') || '#' || coalesce(t0.policyholder_zip_code,'') || '#' || coalesce(t0.policyholder_country,'')), '########'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.policyholder_additional_space_for_road as COMMON_ADDRESS__ADDRESS_LINE_2,
        null,
        t0.policyholder_stair as COMMON_ADDRESS__BUILDING_NAME,
        null,
        t0.policyholder_city as COMMON_ADDRESS__CITY,
        null,
        t0.policyholder_country as COMMON_ADDRESS__COUNTRY_NAME,
        null,
        t0.policyholder_door as COMMON_ADDRESS__DOOR_NUMBER,
        t0.policyholder_floor as COMMON_ADDRESS__FLOOR_NUMBER,
        t0.policyholder_zip_code as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.policyholder_province as COMMON_ADDRESS__STATE_NAME,
        t0.policyholder_road as COMMON_ADDRESS__STREET_NAME,
        null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.policyholder_door,'') || '#' || coalesce(t0.policyholder_floor,'') || '#' || coalesce(t0.policyholder_stair,'') || '#' || coalesce(t0.policyholder_road,'') || '#' || coalesce(t0.policyholder_additional_space_for_road,'') || '#' || coalesce(t0.policyholder_city,'') || '#' || coalesce(t0.policyholder_province,'') || '#' || coalesce(t0.policyholder_zip_code,'') || '#' || coalesce(t0.policyholder_country,'')), '########'))), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_UWR_VW_DATA_MEMBERS_BENEFITS_ATTRIBUTES_PIVOT_VW
    select
        nullif('LOC:MEMBER_RESIDENTIAL:' || md5(normalise(nullif(trim(coalesce(t0.complete_homeresidential_address,'') || '|' || coalesce(t0.pin_code,'')), '|'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.complete_homeresidential_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_benefits_attrs_pv') }} t0
    where (nullif('LOC:MEMBER_RESIDENTIAL:' || md5(normalise(nullif(trim(coalesce(t0.complete_homeresidential_address,'') || '|' || coalesce(t0.pin_code,'')), '|'))), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(t0.address_of_nominee), ''))), '') as LOCATION_BK,
        nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.exempted_income as AUG_PARTY_FINANCIAL_PROFILE__EXEMPTED_INCOME,
        t0.gross_income as AUG_PARTY_FINANCIAL_PROFILE__GROSS_INCOME,
        null, null, null, null, null,
        t0.beer_consumption_per_week as AUG_PARTY_HEALTH_PROFILE__BEER_UNITS_PER_WEEK,
        null, null,
        t0.spirits_consumption_per_week as AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK,
        null,
        t0.wine_consumption_per_week as AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK,
        t0.address_of_nominee as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_income as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
        null, null,
        coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''), nullif(trim(t0.member_code),'')) as PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK,
        null,
        t0.employee_id as PARTY_GROUP_CENSUS__EMPLOYEE_ID,
        null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd_msa') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd_multiset_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_memd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j4.KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim((case when x1._N = 1 then x1._V end)),''),nullif(trim(t0.member_code),'')), ''), nullif(md5(normalise(nullif(trim(t0.address_of_nominee), ''))), ''))) is not null

    union all

    -- branch 17: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(t0.bank_branch_address), ''))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.bank_branch_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_msa_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(t0.bank_branch_address), ''))), '')) is not null

    union all

    -- branch 18: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.city_code as COMMON_ADDRESS__CITY,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null, null, null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        t0.state_code as COMMON_ADDRESS__STATE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 19: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.effective_date as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_members_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 20: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), '') as LOCATION_BK,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.filed_it_last_2_years as AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR,
        t0.lower_tds_certificate as AUG_PARTY_FINANCIAL_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE,
        t0.monthly_gross_income as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME,
        t0.monthly_income as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME_DECLARED,
        t0.income2 as AUG_PARTY_FINANCIAL_PROFILE__SECONDARY_INCOME_AMOUNT,
        null,
        t0.location_of_disability as AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION,
        t0.icd as AUG_PARTY_HEALTH_PROFILE__ICD_DIAGNOSIS_CODE,
        null,
        t0.surgery_details as AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION,
        null,
        t0.correspondence_local_address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.correspondence_local_address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.correspondence_local_address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.correspondence_local_address_city_town_village as COMMON_ADDRESS__CITY,
        null,
        t0.correspondence_local_address_country as COMMON_ADDRESS__COUNTRY_NAME,
        t0.correspondence_local_address_district as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.local_address_pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.correspondence_local_address_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null,
        nullif(trim(j2.party_code),'') as PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK,
        null, null,
        t0.last_working_day as PARTY_GROUP_CENSUS__EXIT_DATE,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), ''), nullif(nullif(trim(j2.party_code),''), ''))) is not null

    union all

    -- branch 21: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.country,'')), ''))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.country,'')), ''))), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.current_permanent_overseas_address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.current_permanent_overseas_address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.current_permanent_overseas_address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.current_permanent_overseas_address_city_town_village as COMMON_ADDRESS__CITY,
        null,
        t0.current_permanent_overseas_address_country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null,
        t0.current_permanent_overseas_address_pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.current_permanent_overseas_address_state_ut as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), '')) is not null

    union all

    -- branch 23: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.our_office_address,'')), ''))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.our_office_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.our_office_address,'')), ''))), '')) is not null

    union all

    -- branch 24: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim('BANK-BRANCH|' || coalesce(t0.bank_ifsc_code,'') || '|' || coalesce(t0.bank_city,'') || '|' || coalesce(t0.branch_name_out,'')), 'BANK-BRANCH|||'))), '') as LOCATION_BK,
        null,
        nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number),'') ,'ACCT:' || nullif(trim(t0.account_number),'') ), '') as PAYMENT_INSTRUMENT_BK,
        null, null,
        t0.debit_type as AUG_INSTRUMENT_DEFINITION__MANDATE_DEBIT_TYPE,
        t0.an_amount_of_rupees as AUG_INSTRUMENT_DEFINITION__MANDATE_MAXIMUM_AMOUNT,
        t0.date1 as AUG_INSTRUMENT_DEFINITION__MANDATE_SIGNED_DATE,
        t0.until_cancelled as AUG_INSTRUMENT_DEFINITION__MANDATE_UNTIL_CANCELLED_INDICATOR,
        null, null,
        t0.utility_code as AUG_INSTRUMENT_DEFINITION__UTILITY_BILLER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.bank_city as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (coalesce(nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number),'') ,'ACCT:' || nullif(trim(t0.account_number),'') ), ''), nullif(md5(normalise(nullif(trim('BANK-BRANCH|' || coalesce(t0.bank_ifsc_code,'') || '|' || coalesce(t0.bank_city,'') || '|' || coalesce(t0.branch_name_out,'')), 'BANK-BRANCH|||'))), ''))) is not null

    union all

    -- branch 25: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null,
        nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number1),'') ,'ACCT:' || nullif(trim(t0.account_number1),'') ), '') as PAYMENT_INSTRUMENT_BK,
        null, null,
        t0.debit_type1 as AUG_INSTRUMENT_DEFINITION__MANDATE_DEBIT_TYPE,
        t0.an_amount_of_rupees1 as AUG_INSTRUMENT_DEFINITION__MANDATE_MAXIMUM_AMOUNT,
        t0.date2 as AUG_INSTRUMENT_DEFINITION__MANDATE_SIGNED_DATE,
        t0.until_cancelled1 as AUG_INSTRUMENT_DEFINITION__MANDATE_UNTIL_CANCELLED_INDICATOR,
        null, null,
        t0.utility_code1 as AUG_INSTRUMENT_DEFINITION__UTILITY_BILLER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('UMRN:' || nullif(trim(t0.reference_number1),'') ,'ACCT:' || nullif(trim(t0.account_number1),'') ), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.city_code as COMMON_ADDRESS__CITY,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null,
        t0.district_code as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        t0.state_code as COMMON_ADDRESS__STATE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''))) is not null

    union all

    -- branch 27: MAXI_HLTH_UWR_VW_DATA_PROPOSER_ADDRESS_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.effective_date as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_proposer_address_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_proposer_address') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('UWR-PROPOSER:' || nullif(trim(j2.proposal_number),''), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''))) is not null

    union all

    -- branch 28: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.address_line1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.address_line2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.address_line3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.city_code as COMMON_ADDRESS__CITY,
        t0.country_code as COMMON_ADDRESS__COUNTRY_CODE,
        null, null, null, null,
        t0.pin_code as COMMON_ADDRESS__POSTAL_CODE,
        t0.state_code as COMMON_ADDRESS__STATE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 29: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_CONTACT_DETAILS
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), '') as LOCATION_BK,
        nullif(nullif(trim(j1.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.effective_date as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE,
        t0.type_of_contact as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        null, null, null, null, null, null, null,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_contact_dtls') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line1,'') || '#' || coalesce(t0.address_line2,'') || '#' || coalesce(t0.address_line3,'') || '#' || coalesce(t0.city_code,'') || '#' || coalesce(t0.state_code,'') || '#' || coalesce(t0.pin_code,'') || '#' || coalesce(t0.country_code,'')), '######'))), ''), nullif(nullif(trim(j1.party_code),''), ''))) is not null

    union all

    -- branch 30: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), '') as LOCATION_BK,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.banking_details as AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAILS_DESCRIPTION,
        t0.charge_file_details as AUG_PARTY_FINANCIAL_PROFILE__CHARGES_FILED_DESCRIPTION,
        t0.cheque_receipting_blocked as AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCKED_INDICATOR,
        t0.remarks_for_cheque_receipting_blocked as AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCK_REASON,
        t0.credit_card_details as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAILS_DESCRIPTION,
        t0.credit_limit_cin_no as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_CIN_REFERENCE,
        t0.credit_details as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_PROFILE_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.surgery_details as AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION,
        null,
        t0.correspondence_local_address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.correspondence_local_address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.correspondence_local_address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null,
        t0.addressee as COMMON_ADDRESS__CARE_OF_NAME,
        t0.correspondence_local_address_city_town_village as COMMON_ADDRESS__CITY,
        null,
        t0.correspondence_local_address_country as COMMON_ADDRESS__COUNTRY_NAME,
        t0.correspondence_local_address_district as COMMON_ADDRESS__DISTRICT,
        null, null,
        t0.local_address_pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.correspondence_local_address_state as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null,
        t0.income_source as PARTY_FINANCIAL_PROFILE__INCOME_SOURCE,
        null,
        t0.employee_grade as PARTY_GROUP_CENSUS__DESIGNATION_BAND,
        t0.staff_number as PARTY_GROUP_CENSUS__EMPLOYEE_ID,
        null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), ''), nullif(nullif(trim(j2.party_code),''), ''))) is not null

    union all

    -- branch 31: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.current_permanent_overseas_address_line_1 as COMMON_ADDRESS__ADDRESS_LINE_1,
        t0.current_permanent_overseas_address_line_2 as COMMON_ADDRESS__ADDRESS_LINE_2,
        t0.current_permanent_overseas_address_line_3 as COMMON_ADDRESS__ADDRESS_LINE_3,
        null, null,
        t0.current_permanent_overseas_address_city_town_village as COMMON_ADDRESS__CITY,
        null,
        t0.current_permanent_overseas_address_country as COMMON_ADDRESS__COUNTRY_NAME,
        null, null, null,
        t0.current_permanent_overseas_address_pin_code as COMMON_ADDRESS__POSTAL_CODE,
        null,
        t0.current_permanent_overseas_address_state_ut as COMMON_ADDRESS__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), '')) is not null

    union all

    -- branch 32: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.our_office_address,'')), ''))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.our_office_address as COMMON_ADDRESS__ADDRESS_LINE_1,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.our_office_address,'')), ''))), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), '') as LOCATION_BK,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.current_permanent_overseas_address_type as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null,
        t0.current_permanent_overseas_address_type as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
        null, null, null, null, null, null, null,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), ''), nullif(nullif(trim(j2.party_code),''), ''))) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_VIEW_COLLECTIONS_ADDITIONAL_DETAILS_PIVOT_VW
    select
        nullif('LOC:' || md5(normalise(nullif(trim(coalesce(t0.city_name,'')), ''))), '') as LOCATION_BK,
        null,
        nullif('UWR_COLL_INSTR:' || md5(normalise(nullif(trim(coalesce(t0.card_numberlast_4_digits,'') || '#' || coalesce(t0.card_type,'') || '#' || coalesce(t0.issuing_bank,'') || '#' || coalesce(t0.ifsc_code,'') || '#' || coalesce(t0.payer_bank_account_no,'') || '#' || coalesce(t0.micr_code,'')), '#####'))), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null,
        t0.micr_code as AUG_INSTRUMENT_DEFINITION__MICR_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.city_name as COMMON_ADDRESS__CITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_view_collections_additional_dtls_pv') }} t0
    where (coalesce(nullif('LOC:' || md5(normalise(nullif(trim(coalesce(t0.city_name,'')), ''))), ''), nullif('UWR_COLL_INSTR:' || md5(normalise(nullif(trim(coalesce(t0.card_numberlast_4_digits,'') || '#' || coalesce(t0.card_type,'') || '#' || coalesce(t0.issuing_bank,'') || '#' || coalesce(t0.ifsc_code,'') || '#' || coalesce(t0.payer_bank_account_no,'') || '#' || coalesce(t0.micr_code,'')), '#####'))), ''))) is not null

)

select
    LOCATION_BK,
    PARTY_BK,
    PAYMENT_INSTRUMENT_BK,
    __LNK_PARTY_LOCATION,
    first_value(AUG_INSTRUMENT_DEFINITION__CHEQUE_PAYABLE_STATE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__CHEQUE_PAYABLE_STATE,
    first_value(AUG_INSTRUMENT_DEFINITION__MANDATE_DEBIT_TYPE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__MANDATE_DEBIT_TYPE,
    first_value(AUG_INSTRUMENT_DEFINITION__MANDATE_MAXIMUM_AMOUNT) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__MANDATE_MAXIMUM_AMOUNT,
    first_value(AUG_INSTRUMENT_DEFINITION__MANDATE_SIGNED_DATE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__MANDATE_SIGNED_DATE,
    first_value(AUG_INSTRUMENT_DEFINITION__MANDATE_UNTIL_CANCELLED_INDICATOR) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__MANDATE_UNTIL_CANCELLED_INDICATOR,
    first_value(AUG_INSTRUMENT_DEFINITION__MICR_CODE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__MICR_CODE,
    first_value(AUG_INSTRUMENT_DEFINITION__PAYABLE_AT_LOCATION) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__PAYABLE_AT_LOCATION,
    first_value(AUG_INSTRUMENT_DEFINITION__UTILITY_BILLER_CODE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__UTILITY_BILLER_CODE,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAILS_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAILS_DESCRIPTION,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CHARGES_FILED_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CHARGES_FILED_DESCRIPTION,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCKED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCKED_INDICATOR,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCK_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CHEQUE_RECEIPTING_BLOCK_REASON,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAILS_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAILS_DESCRIPTION,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_CIN_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_CIN_REFERENCE,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CREDIT_PROFILE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_PROFILE_DESCRIPTION,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__EXEMPTED_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__EXEMPTED_INCOME,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__GROSS_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__GROSS_INCOME,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_LAST_TWO_YEARS_INDICATOR,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME_DECLARED) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME_DECLARED,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__SECONDARY_INCOME_AMOUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__SECONDARY_INCOME_AMOUNT,
    first_value(AUG_PARTY_HEALTH_PROFILE__BEER_UNITS_PER_WEEK) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__BEER_UNITS_PER_WEEK,
    first_value(AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION,
    first_value(AUG_PARTY_HEALTH_PROFILE__ICD_DIAGNOSIS_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__ICD_DIAGNOSIS_CODE,
    first_value(AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__SPIRITS_UNITS_PER_WEEK,
    first_value(AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__SURGERY_HISTORY_DESCRIPTION,
    first_value(AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__WINE_UNITS_PER_WEEK,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_1) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_1,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_2) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_2,
    first_value(COMMON_ADDRESS__ADDRESS_LINE_3) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__ADDRESS_LINE_3,
    first_value(COMMON_ADDRESS__BUILDING_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__BUILDING_NAME,
    first_value(COMMON_ADDRESS__CARE_OF_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__CARE_OF_NAME,
    first_value(COMMON_ADDRESS__CITY) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__CITY,
    first_value(COMMON_ADDRESS__COUNTRY_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__COUNTRY_CODE,
    first_value(COMMON_ADDRESS__COUNTRY_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__COUNTRY_NAME,
    first_value(COMMON_ADDRESS__DISTRICT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__DISTRICT,
    first_value(COMMON_ADDRESS__DOOR_NUMBER) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__DOOR_NUMBER,
    first_value(COMMON_ADDRESS__FLOOR_NUMBER) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__FLOOR_NUMBER,
    first_value(COMMON_ADDRESS__POSTAL_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__POSTAL_CODE,
    first_value(COMMON_ADDRESS__STATE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STATE_CODE,
    first_value(COMMON_ADDRESS__STATE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STATE_NAME,
    first_value(COMMON_ADDRESS__STREET_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADDRESS__STREET_NAME,
    PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
    first_value(PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE) ignore nulls over (partition by LOCATION_BK, PARTY_BK, PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_FROM_DATE,
    first_value(PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE) ignore nulls over (partition by LOCATION_BK, PARTY_BK, PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE,
    first_value(PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__ANNUAL_INCOME,
    first_value(PARTY_FINANCIAL_PROFILE__CREDIT_SCORE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE,
    first_value(PARTY_FINANCIAL_PROFILE__INCOME_SOURCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__INCOME_SOURCE,
    PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK,
    first_value(PARTY_GROUP_CENSUS__DESIGNATION_BAND) ignore nulls over (partition by PARTY_BK, PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_GROUP_CENSUS__DESIGNATION_BAND,
    first_value(PARTY_GROUP_CENSUS__EMPLOYEE_ID) ignore nulls over (partition by PARTY_BK, PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_GROUP_CENSUS__EMPLOYEE_ID,
    first_value(PARTY_GROUP_CENSUS__EXIT_DATE) ignore nulls over (partition by PARTY_BK, PARTY_GROUP_CENSUS__MEMBER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_GROUP_CENSUS__EXIT_DATE
from merged
