-- Staging for source table BJAZ_HM_PREAUTH_ENHANCE (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLID")), '') as clid,
        nullif(trim(to_varchar("ENHANCE_REF_ID")), '') as enhance_ref_id,
        nullif(trim(to_varchar("ENHANCE_REQUEST")), '') as enhance_request,
        nullif(trim(to_varchar("EXPECTED_DOD")), '') as expected_dod,
        nullif(trim(to_varchar("HOSP_ID")), '') as hosp_id,
        nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no,
        nullif(trim(to_varchar("PATIENT_ID_CARD")), '') as patient_id_card,
        nullif(trim(to_varchar("TRANS_AMOUNT")), '') as trans_amount
    from {{ source('health_raw', 'BJAZ_HM_PREAUTH_ENHANCE') }}

)

select * from source
