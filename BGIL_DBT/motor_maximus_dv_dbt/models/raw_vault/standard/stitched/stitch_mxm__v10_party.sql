-- CENTRAL VIEW v10_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_RELATION
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_CHANNEL_DEFINITION
--   SAT_MOTOR_AUG_PARTY_IDENTITY
--   SAT_MOTOR_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_CHANNEL_DEFINITION
--   SAT_LNK_POLICY_PARTY_ROLE
--   SAT_PARTY_IDENTITY
--   SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_PARTY_ORGANISATION_PROFILE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_PARTY
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim('GSTIN:' || nullif(trim(t0.bill_raising_party_gstn), '')), 'GSTIN:'), '') as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as AUG_CHANNEL_DEFINITION__NATIONAL_TIE_UP_DETAIL_TEXT,
        cast(null as varchar) as AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE,
        cast(null as varchar) as AUG_PARTY_IDENTITY__AGE_BAND,
        cast(null as varchar) as AUG_PARTY_IDENTITY__ASSOCIATED_INSTITUTION_NAME,
        cast(null as varchar) as AUG_PARTY_IDENTITY__OTHER_PARTY_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT,
        cast(null as varchar) as AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE,
        cast(null as varchar) as AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE,
        cast(null as varchar) as AUG_PARTY_IDENTITY__PERSONAL_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_DATE,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_SECTOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_FIRM_ESTABLISHMENT_YEAR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_ORIGIN_COUNTRY,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_PROJECT_EXPERTISE_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__DIRECTOR_AND_PARTNER_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__OPERATING_AREA_COVERAGE_KILOMETRES,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__OWNERSHIP_TYPE,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__PLACE_OF_OPERATION,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_CHARGE_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_DATE,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_EXPIRY_DATE,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_NUMBER,
        cast(null as varchar) as CHANNEL_DEFINITION__CHANNEL_TYPE,
        cast(null as varchar) as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        cast(null as varchar) as CHANNEL_DEFINITION__SUB_CHANNEL_EFFECTIVE_DATE,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
        cast(null as varchar) as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
        cast(null as varchar) as PARTY_IDENTITY__AGE,
        cast(null as varchar) as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
        cast(null as varchar) as PARTY_IDENTITY__DATE_OF_BIRTH,
        cast(null as varchar) as PARTY_IDENTITY__FIRST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__GENDER_CODE,
        cast(null as varchar) as PARTY_IDENTITY__LAST_NAME,
        cast(null as varchar) as PARTY_IDENTITY__MIDDLE_NAME,
        cast(null as varchar) as PARTY_IDENTITY__NATIONALITY,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        t0.bill_raised_by as PARTY_IDENTITY__PARTY_FULL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_STATUS,
        cast(null as varchar) as PARTY_IDENTITY__PARTY_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTITY__SALUTATION,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__INCOME_BAND,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_CODE,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__CIN_NUMBER,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_CODE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__REGISTERED_OFFICE_COUNTRY,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim('GSTIN:' || nullif(trim(t0.bill_raising_party_gstn), '')), 'GSTIN:'), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim('GSTIN:' || nullif(trim(t0.bill_to_party_gstn), '')), 'GSTIN:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bill_raised_to_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim('GSTIN:' || nullif(trim(t0.bill_to_party_gstn), '')), 'GSTIN:'), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null,
        t0.customer_age_slab as AUG_PARTY_IDENTITY__AGE_BAND,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.enter_dob as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null, null, null, null, null,
        t0.insured_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        t0.name_as_per_pan as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null, null,
        t0.customer_type_retail_or_institutional as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null, null, null,
        t0.customer_income_segment as PARTY_INDIVIDUAL_DEMOGRAPHICS__INCOME_BAND,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null,
        nullif('DL:' || nullif(trim(t0.driver_license_number),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.driver_age as PARTY_IDENTITY__AGE,
        null, null,
        t0.driver_date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null, null, null, null, null, null,
        t0.driver_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('DL:' || nullif(trim(t0.driver_license_number),''), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null,
        nullif('IMD:' || nullif(trim(t0.intermediary_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.intermediary_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('IMD:' || nullif(trim(t0.intermediary_code),''), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null,
        nullif('SUBIMD:' || nullif(trim(t0.sub_imd_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_imd_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('SUBIMD:' || nullif(trim(t0.sub_imd_code),''), '')) is not null

    union all

    -- branch 6: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null,
        nullif('SUPPLIER:' || nullif(trim(t0.workshop_supplier_id),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.workshop_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('SUPPLIER:' || nullif(trim(t0.workshop_supplier_id),''), '')) is not null

    union all

    -- branch 7: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
    select
        null,
        nullif(nullif(trim(t0.partycode),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.firstname as PARTY_IDENTITY__FIRST_NAME,
        null,
        t0.lastname as PARTY_IDENTITY__LAST_NAME,
        t0.middlename as PARTY_IDENTITY__MIDDLE_NAME,
        null, null, null,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_party') }} t0
    where (nullif(nullif(trim(t0.partycode),''), '')) is not null

    union all

    -- branch 8: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
    select
        null,
        nullif(nullif(trim(t0.partycode),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.firstname as PARTY_IDENTITY__FIRST_NAME,
        null,
        t0.lastname as PARTY_IDENTITY__LAST_NAME,
        t0.middlename as PARTY_IDENTITY__MIDDLE_NAME,
        null, null, null,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_party') }} t0
    where (nullif(nullif(trim(t0.partycode),''), '')) is not null

    union all

    -- branch 9: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.party_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.party_code), ''), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.payee_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.payee_code), ''), '')) is not null

    union all

    -- branch 11: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim('REPAIRER:' || nullif(trim(t0.repairer_code), '')), 'REPAIRER:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.repairer_nameod as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim('REPAIRER:' || nullif(trim(t0.repairer_code), '')), 'REPAIRER:'), '')) is not null

    union all

    -- branch 12: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim('SURVEYOR:' || nullif(trim(t0.surveyor_code), '')), 'SURVEYOR:'), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.surveyor_nameod as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim('SURVEYOR:' || nullif(trim(t0.surveyor_code), '')), 'SURVEYOR:'), '')) is not null

    union all

    -- branch 13: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.hospital_id),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.hospital_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_properties_pv') }} t0
    where (nullif(nullif(trim(t0.hospital_id),''), '')) is not null

    union all

    -- branch 14: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS
    select
        null,
        nullif(nullif(trim(t0.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null,
        t0.party_end_date as AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE,
        t0.party_last_modification_date as AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE,
        null,
        t0.registration_date as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        t0.last_name as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        null, null,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        t0.party_start_date as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
        t0.party_status as PARTY_IDENTITY__PARTY_STATUS,
        t0.type_of_party as PARTY_IDENTITY__PARTY_TYPE_CODE,
        t0.title as PARTY_IDENTITY__SALUTATION,
        null, null, null, null, null,
        t0.occupation as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_CODE,
        null, null, null, null, null,
        t0.registration_no as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        null, null, null, null, null,
        t0.type_of_organization as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_member_dtls') }} t0
    where (nullif(nullif(trim(t0.party_code), ''), '')) is not null

    union all

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(j4.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null,
        t0.source_of_proposal as AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.source_of_business as CHANNEL_DEFINITION__CHANNEL_TYPE,
        t0.sub_channel as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_client as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.policy_holder_code), ''), ''), nullif(nullif(trim(t0.imd_code), ''), ''))) is not null

    union all

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null,
        t0.about_insured as AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.source_of_proposal as CHANNEL_DEFINITION__CHANNEL_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.customer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_holder_code), ''), ''), nullif(nullif(trim(t0.imd_code), ''), ''))) is not null

    union all

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null,
        nullif('SP:' || nullif(trim(t0.sp_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sp_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    where (nullif('SP:' || nullif(trim(t0.sp_code), ''), '')) is not null

    union all

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_RELATION
    select
        null,
        nullif(nullif(trim(t0.party_code), ''), '') as PARTY_BK,
        nullif(nullif(trim(j1.policy_number), ''), '') as POLICY_BK,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        nullif(trim(t0.stake_code),'') as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        null,
        t0.party_share_percentage as LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
        t0.stake_code as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
        null, null, null, null, null, null, null, null, null, null,
        t0.party_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_relation') }} t0
    left join {{ ref('stg_mxm__uwr_pd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j1.policy_number), ''), ''), nullif(nullif(trim(t0.party_code), ''), ''))) is not null

    union all

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
    select
        null,
        nullif(nullif(trim(t0.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null,
        t0.party_end_date as AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE,
        t0.party_last_modification_date as AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE,
        null,
        t0.registration_date as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        t0.first_name as PARTY_IDENTITY__FIRST_NAME,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        t0.last_name as PARTY_IDENTITY__LAST_NAME,
        t0.middle_name as PARTY_IDENTITY__MIDDLE_NAME,
        t0.nationality as PARTY_IDENTITY__NATIONALITY,
        null, null,
        t0.business_name as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        t0.party_start_date as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
        t0.party_status as PARTY_IDENTITY__PARTY_STATUS,
        t0.type_of_party as PARTY_IDENTITY__PARTY_TYPE_CODE,
        t0.title as PARTY_IDENTITY__SALUTATION,
        null, null, null, null, null,
        t0.occupation as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_CODE,
        null, null, null, null, null,
        t0.registration_no as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        null, null, null, null, null,
        t0.type_of_organization as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} t0
    where (nullif(nullif(trim(t0.party_code), ''), '')) is not null

    union all

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.agent_channel), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        1 as __LNK_POLICY_PARTY,
        t0.national_tieup_information as AUG_CHANNEL_DEFINITION__NATIONAL_TIE_UP_DETAIL_TEXT,
        null, null,
        t0.institute_name as AUG_PARTY_IDENTITY__ASSOCIATED_INSTITUTION_NAME,
        t0.other_details as AUG_PARTY_IDENTITY__OTHER_PARTY_DETAIL_TEXT,
        null, null, null,
        t0.personal_details as AUG_PARTY_IDENTITY__PERSONAL_DETAIL_TEXT,
        t0.date_of_registration as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_DATE,
        t0.sector_selection as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_SECTOR,
        t0.year_of_establishment_of_contractors_firm as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_FIRM_ESTABLISHMENT_YEAR,
        t0.origin_of_the_contractor as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_ORIGIN_COUNTRY,
        t0.contractors_expertise_in_structureproject as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_PROJECT_EXPERTISE_DESCRIPTION,
        t0.director_and_partner_details as AUG_PARTY_ORGANISATION_PROFILE__DIRECTOR_AND_PARTNER_DETAIL_TEXT,
        t0.infrastructure_subsector as AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR,
        t0.covered_area_in_kms as AUG_PARTY_ORGANISATION_PROFILE__OPERATING_AREA_COVERAGE_KILOMETRES,
        t0.ownership as AUG_PARTY_ORGANISATION_PROFILE__OWNERSHIP_TYPE,
        t0.place_of_operation as AUG_PARTY_ORGANISATION_PROFILE__PLACE_OF_OPERATION,
        t0.is_the_organisation_a_registered_business_trust as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR,
        t0.charge_file_details as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_CHARGE_DETAIL_TEXT,
        t0.are_you_registered_company as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR,
        t0.sez_registration_date as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_DATE,
        t0.sez_expiry_date as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_EXPIRY_DATE,
        t0.sez_registration_no as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_NUMBER,
        t0.partner_type as CHANNEL_DEFINITION__CHANNEL_TYPE,
        t0.sub_channel as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        t0.sub_channel_effective_date as CHANNEL_DEFINITION__SUB_CHANNEL_EFFECTIVE_DATE,
        nullif(trim(t0.party_function),'') as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
        null, null,
        t0.party_function as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
        t0.age as PARTY_IDENTITY__AGE,
        t0.country_of_birth as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
        t0.country_of_residence as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
        t0.date_of_birth as PARTY_IDENTITY__DATE_OF_BIRTH,
        null,
        t0.gender as PARTY_IDENTITY__GENDER_CODE,
        null, null,
        t0.country_of_citizenship as PARTY_IDENTITY__NATIONALITY,
        t0.trade_name as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
        null,
        t0.legal_name_of_business as PARTY_IDENTITY__PARTY_LEGAL_NAME,
        null, null,
        t0.type_of_insured as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null,
        t0.educational_qualification as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        t0.father_name as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
        t0.highest_qualification_details as PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE,
        null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        t0.occupation as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_CODE,
        t0.occupation_list as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        t0.spouse_name as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
        t0.do_you_have_2_wheeler4_wheeler as PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR,
        t0.number_of_years_residing_in_the_city_of_residence as PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY,
        t0.annual_turnover as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
        t0.company_no as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        t0.cin_number as PARTY_ORGANISATION_PROFILE__CIN_NUMBER,
        t0.date_of_registration_or_incorporation as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
        t0.global_co_name as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
        t0.industry_code as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
        t0.type_of_company as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_CODE,
        t0.constitution_of_business as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        t0.msme_classification as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
        t0.msme_applicable as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
        t0.business_details as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
        t0.paid_up_capital as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
        t0.parent_co as PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME,
        t0.origin_of_the_company as PARTY_ORGANISATION_PROFILE__REGISTERED_OFFICE_COUNTRY,
        t0.rec_refresh_at as REC_REFRESH_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.party_code), ''), ''), nullif(nullif(trim(j4.policy_number), ''), ''), nullif(nullif(trim(t0.agent_channel), ''), ''))) is not null

    union all

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null,
        nullif('EMP:' || nullif(trim(t0.bagic_employee_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bagic_employee_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bagic_employee_code), ''), '')) is not null

    union all

    -- branch 22: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null,
        t0.about_insured as AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_imd_code as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.customer_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_holder_code), ''), ''), nullif(nullif(trim(t0.imd_code), ''), ''))) is not null

    union all

    -- branch 23: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null,
        nullif('SP:' || nullif(trim(t0.sp_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sp_name as PARTY_IDENTITY__PARTY_FULL_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    where (nullif('SP:' || nullif(trim(t0.sp_code), ''), '')) is not null

    union all

    -- branch 24: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null,
        t0.source_of_proposal as AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.source_of_business as CHANNEL_DEFINITION__CHANNEL_TYPE,
        t0.sub_channel as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_client as PARTY_IDENTITY__PARTY_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.party_code), ''), ''), nullif(nullif(trim(t0.imd_code), ''), ''))) is not null

    union all

    -- branch 25: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null,
        nullif(nullif(trim(j3.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.profession as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code),''), '')) is not null

)

select
    DISTRIBUTION_CHANNEL_BK,
    PARTY_BK,
    POLICY_BK,
    __LNK_POLICY_PARTY,
    first_value(AUG_CHANNEL_DEFINITION__NATIONAL_TIE_UP_DETAIL_TEXT) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_DEFINITION__NATIONAL_TIE_UP_DETAIL_TEXT,
    first_value(AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_DEFINITION__SOLICITATION_TYPE,
    first_value(AUG_PARTY_IDENTITY__AGE_BAND) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__AGE_BAND,
    first_value(AUG_PARTY_IDENTITY__ASSOCIATED_INSTITUTION_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__ASSOCIATED_INSTITUTION_NAME,
    first_value(AUG_PARTY_IDENTITY__OTHER_PARTY_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__OTHER_PARTY_DETAIL_TEXT,
    first_value(AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__PARTY_DESCRIPTION_TEXT,
    first_value(AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__PARTY_RECORD_END_DATE,
    first_value(AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__PARTY_RECORD_LAST_MODIFIED_DATE,
    first_value(AUG_PARTY_IDENTITY__PERSONAL_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTITY__PERSONAL_DETAIL_TEXT,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_DATE,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_SECTOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_SECTOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_FIRM_ESTABLISHMENT_YEAR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_FIRM_ESTABLISHMENT_YEAR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_ORIGIN_COUNTRY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_ORIGIN_COUNTRY,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_PROJECT_EXPERTISE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__CONTRACTOR_PROJECT_EXPERTISE_DESCRIPTION,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__DIRECTOR_AND_PARTNER_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__DIRECTOR_AND_PARTNER_DETAIL_TEXT,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__OPERATING_AREA_COVERAGE_KILOMETRES) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__OPERATING_AREA_COVERAGE_KILOMETRES,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__OWNERSHIP_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__OWNERSHIP_TYPE,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__PLACE_OF_OPERATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__PLACE_OF_OPERATION,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_CHARGE_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_CHARGE_DETAIL_TEXT,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_DATE,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_EXPIRY_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_EXPIRY_DATE,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__SEZ_REGISTRATION_NUMBER,
    first_value(CHANNEL_DEFINITION__CHANNEL_TYPE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__CHANNEL_TYPE,
    first_value(CHANNEL_DEFINITION__SUB_CHANNEL_CODE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__SUB_CHANNEL_CODE,
    first_value(CHANNEL_DEFINITION__SUB_CHANNEL_EFFECTIVE_DATE) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CHANNEL_DEFINITION__SUB_CHANNEL_EFFECTIVE_DATE,
    LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK,
    LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK,
    first_value(LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE) ignore nulls over (partition by PARTY_BK, POLICY_BK, LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE,
    first_value(LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE) ignore nulls over (partition by PARTY_BK, POLICY_BK, LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE_CK, LNK_POLICY_PARTY_ROLE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE,
    first_value(PARTY_IDENTITY__AGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__AGE,
    first_value(PARTY_IDENTITY__COUNTRY_OF_BIRTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__COUNTRY_OF_BIRTH,
    first_value(PARTY_IDENTITY__COUNTRY_OF_RESIDENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__COUNTRY_OF_RESIDENCE,
    first_value(PARTY_IDENTITY__DATE_OF_BIRTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__DATE_OF_BIRTH,
    first_value(PARTY_IDENTITY__FIRST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__FIRST_NAME,
    first_value(PARTY_IDENTITY__GENDER_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__GENDER_CODE,
    first_value(PARTY_IDENTITY__LAST_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__LAST_NAME,
    first_value(PARTY_IDENTITY__MIDDLE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__MIDDLE_NAME,
    first_value(PARTY_IDENTITY__NATIONALITY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__NATIONALITY,
    first_value(PARTY_IDENTITY__PARTY_DISPLAY_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_DISPLAY_NAME,
    first_value(PARTY_IDENTITY__PARTY_FULL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_FULL_NAME,
    first_value(PARTY_IDENTITY__PARTY_LEGAL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_LEGAL_NAME,
    first_value(PARTY_IDENTITY__PARTY_ORIGINATION_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_ORIGINATION_DATE,
    first_value(PARTY_IDENTITY__PARTY_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_STATUS,
    first_value(PARTY_IDENTITY__PARTY_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__PARTY_TYPE_CODE,
    first_value(PARTY_IDENTITY__SALUTATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTITY__SALUTATION,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__INCOME_BAND) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__INCOME_BAND,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_CODE,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__OCCUPATION_DESCRIPTION,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY,
    first_value(PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
    first_value(PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
    first_value(PARTY_ORGANISATION_PROFILE__CIN_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__CIN_NUMBER,
    first_value(PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
    first_value(PARTY_ORGANISATION_PROFILE__GROUP_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
    first_value(PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
    first_value(PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_CODE,
    first_value(PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
    first_value(PARTY_ORGANISATION_PROFILE__MSME_CATEGORY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
    first_value(PARTY_ORGANISATION_PROFILE__MSME_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
    first_value(PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
    first_value(PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
    first_value(PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME,
    first_value(PARTY_ORGANISATION_PROFILE__REGISTERED_OFFICE_COUNTRY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__REGISTERED_OFFICE_COUNTRY,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on PARTY_BK (SAT_LNK_POLICY_PARTY_ROLE):
    -- one load time per PARTY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.LNK_POLICY_PARTY_ROLE__ATTRIBUTION_PERCENTAGE, m.LNK_POLICY_PARTY_ROLE__PARTY_ROLE_TYPE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME
from merged m
