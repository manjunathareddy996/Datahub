-- Staging model for source table BA_TRV_PLAN_MST_MV (Travel LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health/Partner LOB builds.
-- Types read from OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv (real Snowflake DESCRIBE-style
-- metadata, supplied by the mapper) -- not inferred.

with source as (

    select
    nullif(trim(to_varchar("ACTIVE_STATUS")), '') as active_status,
    nullif(trim(to_varchar("AGE_BYPASS_YN")), '') as age_bypass_yn,
    nullif(trim(to_varchar("AREA_CODE_NOS")), '') as area_code_nos,
    nullif(trim(to_varchar("CFT_MST_COMP_REF")), '') as cft_mst_comp_ref,
    nullif(trim(to_varchar("CFT_MST_CONTRACT_ID")), '') as cft_mst_contract_id,
    nullif(trim(to_varchar("CFT_MST_POLICY_REF")), '') as cft_mst_policy_ref,
    nullif(trim(to_varchar("CFT_YN")), '') as cft_yn,
    nullif(trim(to_varchar("FAMILY_PLAN_YN")), '') as family_plan_yn,
    nullif(trim(to_varchar("MULTI_YEAR_YN")), '') as multi_year_yn,
    nullif(trim(to_varchar("PDF_FILENAME")), '') as pdf_filename,
    nullif(trim(to_varchar("PLAN_CATEGORY_NAME")), '') as plan_category_name,
    "PLAN_CATEGORY_NO"::number as plan_category_no,
    nullif(trim(to_varchar("PLAN_DISP_NAME")), '') as plan_disp_name,
    "PLAN_MAX_AGE_TO"::number as plan_max_age_to,
    "PLAN_MAX_DAYS"::number as plan_max_days,
    "PLAN_MIN_AGE_FROM"::number as plan_min_age_from,
    "PLAN_MIN_DAYS"::number as plan_min_days,
    nullif(trim(to_varchar("PLAN_NAME")), '') as plan_name,
    nullif(trim(to_varchar("PLAN_NO")), '') as plan_no,
    nullif(trim(to_varchar("PLAN_SUM_INSURED")), '') as plan_sum_insured,
    "PRODUCT_4DIGIT_CODE"::number as product_4digit_code,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('travel_raw', 'BA_TRV_PLAN_MST_MV') }}

)

select * from source
