-- Staging model for source table BJAZ_ECARD_POL_DTLS_CONFIG (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ALWNAT_DTLS"::varchar), '') as alwnat_dtls,
    nullif(trim("COMP_CNTRPER"::varchar), '') as comp_cntrper,
    nullif(trim("COMP_CONTR"::varchar), '') as comp_contr,
    nullif(trim("CORPORATE_NAME"::varchar), '') as corporate_name,
    "DEACTIVE_POL_DATE"::timestamp_ntz as deactive_pol_date,
    "NATADD_BRNCHLD_DAY"::number as natadd_brnchld_day,
    "NATADD_SPOUSE_DAY"::number as natadd_spouse_day,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("POLICY_STATUS"::varchar), '') as policy_status,
    nullif(trim("POLICY_TYPE"::varchar), '') as policy_type,
    nullif(trim("POL_TYPE"::varchar), '') as pol_type,
    nullif(trim("PREM_CAL_1"::varchar), '') as prem_cal_1,
    nullif(trim("PREM_CAL_2"::varchar), '') as prem_cal_2,
    nullif(trim("PREM_CAL_3"::varchar), '') as prem_cal_3,
    nullif(trim(to_varchar("QUOTE_REF")), '') as quote_ref,
    nullif(trim("QUOTE_STATUS"::varchar), '') as quote_status,
    "RISK_EXPIRY_DATE"::timestamp_ntz as risk_expiry_date,
    "RISK_INCEPTION_DATE"::timestamp_ntz as risk_inception_date
    from {{ source('health_raw', 'BJAZ_ECARD_POL_DTLS_CONFIG') }}

)

select * from source
