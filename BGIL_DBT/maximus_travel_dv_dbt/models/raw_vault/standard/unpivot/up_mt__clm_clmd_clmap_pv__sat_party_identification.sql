{{ config(materialized='view') }}

-- UNPIVOT for SAT_PARTY_IDENTIFICATION from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- one row PER INSTANCE: 8 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by IDENTIFICATION_TYPE_CODE.
-- The hash is taken once, downstream, by stg2_mt_up__clm_clmd_clmap_pv__sat_party_identification.
--
-- Payload is null-padded to the SATELLITE's full payload (25 column(s)), not to this
-- feeder's columns, so every feeder of SAT_PARTY_IDENTIFICATION is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   aadhaar                                  1 attribute(s)
--   ckyc                                     1 attribute(s)
--   generic_declared_id                      1 attribute(s)
--   gstin                                    1 attribute(s)
--   pan                                      1 attribute(s)
--   pan_insured                              1 attribute(s)
--   passport                                 1 attribute(s)
--   voter_id                                 1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'AADHAAR' as IDENTIFICATION_TYPE_CODE,
        insured_aadhar_number as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        cast(null as varchar) as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where insured_aadhar_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'CKYC' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        enter_ckyc_no as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        cast(null as varchar) as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where enter_ckyc_no is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'GENERIC_DECLARED_ID' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        identification_number as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        cast(null as varchar) as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where identification_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'GSTIN' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        gstn_number as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        cast(null as varchar) as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where gstn_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'PAN' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        pan_number as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where pan_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'PAN_INSURED' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        insured_pan_number as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where insured_pan_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'') as PARTY_BK__INSURED_CUSTOMER,
        'PASSPORT' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        cast(null as varchar) as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        passport_number as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        cast(null as varchar) as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where passport_number is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'') as PARTY_BK__CLAIMANT_CUSTOMER,
        'VOTER_ID' as IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as AADHAAR_NUMBER,
        cast(null as varchar) as AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as AGE_PROOF_TYPE,
        cast(null as varchar) as CIN_NUMBER,
        cast(null as varchar) as CKYC_NUMBER,
        cast(null as varchar) as DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as EIA_NUMBER,
        cast(null as varchar) as GSTIN,
        cast(null as varchar) as GST_REGISTRATION_STATUS,
        cast(null as varchar) as GST_TAXPAYER_TYPE,
        cast(null as varchar) as IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as IDENTIFICATION_NUMBER,
        cast(null as varchar) as IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as NREGA_CARD_NUMBER,
        cast(null as varchar) as OVD_CATEGORY,
        cast(null as varchar) as PAN_NUMBER,
        cast(null as varchar) as PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PASSPORT_NUMBER,
        cast(null as varchar) as TAN_NUMBER,
        enter_voter_id as VOTER_ID_NUMBER,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    where enter_voter_id is not null
