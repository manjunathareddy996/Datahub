-- Staging model for source table CLM_INTERESTED_PARTIES (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    "IP_NO"::number as ip_no,
    "VERSION_NO"::number as version_no,
    "OBJECT_ID"::number as object_id,
    nullif(trim(to_varchar("INS_OBJ_UID")), '') as ins_obj_uid,
    nullif(trim("IP_TYPE"::varchar), '') as ip_type,
    nullif(trim(to_varchar("CLAIMANT")), '') as claimant,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    nullif(trim("OBJECT_TYPE"::varchar), '') as object_type,
    nullif(trim(to_varchar("PART_ID")), '') as part_id,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'CLM_INTERESTED_PARTIES') }}

)

select * from source
