-- Staging for source table BJAZ_HM_PREAUTH_QUERY (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLID")), '') as clid,
        nullif(trim(to_varchar("HOSP_ID")), '') as hosp_id,
        nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
        nullif(trim(to_varchar("PATIENT_ID_CARD")), '') as patient_id_card,
        nullif(trim(to_varchar("QUERY_REF_ID")), '') as query_ref_id,
        nullif(trim(to_varchar("QUERY_REPLY")), '') as query_reply
    from {{ source('health_raw', 'BJAZ_HM_PREAUTH_QUERY') }}

)

select * from source
