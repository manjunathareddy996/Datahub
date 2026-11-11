-- Staging for source table BJAZ_HM_ORPHAN_FOLLOW_DTLS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("DOCUMENT_FROM")), '') as document_from,
        nullif(trim(to_varchar("FIR_REM_DATE")), '') as fir_rem_date,
        nullif(trim(to_varchar("FOLLOWUP_ID")), '') as followup_id,
        nullif(trim(to_varchar("FOLLOWUP_REASON")), '') as followup_reason,
        nullif(trim(to_varchar("INTIMATION_DATE")), '') as intimation_date,
        nullif(trim(to_varchar("ORPHAN_ID")), '') as orphan_id,
        nullif(trim(to_varchar("REPLY_DATE")), '') as reply_date,
        nullif(trim(to_varchar("SEC_REM_DATE")), '') as sec_rem_date,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on
    from {{ source('health_raw', 'BJAZ_HM_ORPHAN_FOLLOW_DTLS') }}

)

select * from source
