-- Staging model for source table BJAZ_SPP_MEMBER_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("BMI"::varchar), '') as bmi,
    nullif(trim("CARDIOVASCULAR_DISEASES"::varchar), '') as cardiovascular_diseases,
    nullif(trim("CHOLESTEROL_DISORDER"::varchar), '') as cholesterol_disorder,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    nullif(trim("CRITICAL_ILLNESS"::varchar), '') as critical_illness,
    "CUMULATIVE_AMT"::number as cumulative_amt,
    "CUMULATIVE_BNOUZ_PER"::number as cumulative_bnouz_per,
    nullif(trim("DECEASE_TREATMENT_DTLS"::varchar), '') as decease_treatment_dtls,
    nullif(trim("DIABETES"::varchar), '') as diabetes,
    nullif(trim("HEIGHT_FEET"::varchar), '') as height_feet,
    nullif(trim("HEIGHT_INCHES"::varchar), '') as height_inches,
    nullif(trim("HYPERTENSION"::varchar), '') as hypertension,
    nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
    nullif(trim("OBESITY"::varchar), '') as obesity,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
    nullif(trim("PREEXIST_DICEASE"::varchar), '') as preexist_dicease,
    nullif(trim("RELATION"::varchar), '') as relation,
    "TOT_MEMBER_LOADING"::number as tot_member_loading,
    nullif(trim("WEIGHT"::varchar), '') as weight
    from {{ source('health_raw', 'BJAZ_SPP_MEMBER_DTLS') }}

)

select * from source
