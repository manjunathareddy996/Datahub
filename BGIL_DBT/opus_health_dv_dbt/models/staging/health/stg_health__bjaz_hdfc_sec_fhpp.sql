-- Staging for source table BJAZ_HDFC_SEC_FHPP (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("BA_LEAD_NO")), '') as ba_lead_no,
        nullif(trim(to_varchar("BDR_CODE")), '') as bdr_code,
        nullif(trim(to_varchar("CLIENT_ID")), '') as client_id,
        nullif(trim(to_varchar("CUSTOMER_ID")), '') as customer_id,
        nullif(trim(to_varchar("CUSTOMER_NAME")), '') as customer_name,
        nullif(trim(to_varchar("CUSTOMER_TYPE")), '') as customer_type,
        nullif(trim(to_varchar("DOB")), '') as dob,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
        nullif(trim(to_varchar("HEIGHT")), '') as height,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("KGC_PROPOSAL_NUMBER")), '') as kgc_proposal_number,
        nullif(trim(to_varchar("MASTER_POLICY_NO")), '') as master_policy_no,
        nullif(trim(to_varchar("NOMINEE_NAME")), '') as nominee_name,
        nullif(trim(to_varchar("NOMINEE_RELATION")), '') as nominee_relation,
        nullif(trim(to_varchar("NO_OF_DAYS")), '') as no_of_days,
        nullif(trim(to_varchar("NO_OF_YEARS")), '') as no_of_years,
        nullif(trim(to_varchar("PARAM_NAME")), '') as param_name,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("PREEXISTING_DISEASE")), '') as preexisting_disease,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("REFERENCE_ID")), '') as reference_id,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("SM_CODE")), '') as sm_code,
        nullif(trim(to_varchar("SOURCE_NAME")), '') as source_name,
        nullif(trim(to_varchar("SUBIMD_ID")), '') as subimd_id,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("S_ACCOUNT_NUMBER")), '') as s_account_number,
        nullif(trim(to_varchar("TERM_END_DATE")), '') as term_end_date,
        nullif(trim(to_varchar("TERM_START_DATE")), '') as term_start_date,
        nullif(trim(to_varchar("WEIGHT")), '') as weight
    from {{ source('health_raw', 'BJAZ_HDFC_SEC_FHPP') }}

)

select * from source
