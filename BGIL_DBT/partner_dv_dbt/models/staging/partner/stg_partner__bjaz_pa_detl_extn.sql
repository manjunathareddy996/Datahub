-- Staging model for source table BJAZ_PA_DETL_EXTN (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim("ACTION_CODE"::varchar), '') as action_code,
    "VERSION_NO"::number as version_no,
    "OBJECT_ID"::number as object_id,
    nullif(trim("TOP_INDICATOR"::varchar), '') as top_indicator,
    "PREVIOUS_VERSION"::number as previous_version,
    "REVERSING_VERSION"::number as reversing_version,
    nullif(trim("CONTRACT_ID"::varchar), '') as contract_id,
    "LOAD_RATE"::number as load_rate,
    "LOAD_AMT"::number as load_amt,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim("AGE"::varchar), '') as age,
    nullif(trim("RISK_CLASS"::varchar), '') as risk_class,
    "SUM_INSU_BASIC"::number as sum_insu_basic,
    "SUM_INSU_WIDER"::number as sum_insu_wider,
    "SUM_INSU_COMP"::number as sum_insu_comp,
    nullif(trim("MEDICAL_EXP"::varchar), '') as medical_exp,
    nullif(trim("MEDICAL_CON"::varchar), '') as medical_con,
    "REF_NO"::number as ref_no,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("CUMMULATIVE_BONUS"::varchar), '') as cummulative_bonus,
    nullif(trim("ASSIGNEE"::varchar), '') as assignee,
    "CUMMULATIVE_AMT"::number as cummulative_amt,
    "DOB"::timestamp_ntz as dob,
    nullif(trim("PARTNER_ID"::varchar), '') as partner_id,
    nullif(trim("FIRST_POLICY_REF"::varchar), '') as first_policy_ref,
    "INCEPTION_DATE"::timestamp_ntz as inception_date,
    nullif(trim("CUMM_BONUS_COMP"::varchar), '') as cumm_bonus_comp,
    nullif(trim("CUMM_BONUS_WIDER"::varchar), '') as cumm_bonus_wider,
    "CUMM_BONUS_AMT_WIDER"::number as cumm_bonus_amt_wider,
    "CUMM_BONUS_AMT_COMP"::number as cumm_bonus_amt_comp,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'BJAZ_PA_DETL_EXTN') }}

)

select * from source
