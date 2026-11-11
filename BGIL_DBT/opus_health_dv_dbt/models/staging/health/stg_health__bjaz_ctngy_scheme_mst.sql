-- Staging for source table BJAZ_CTNGY_SCHEME_MST (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AUTO_DEBIT")), '') as auto_debit,
        nullif(trim(to_varchar("AUTO_RENEWAL")), '') as auto_renewal,
        nullif(trim(to_varchar("FAMILY_FLOATER")), '') as family_floater,
        nullif(trim(to_varchar("FF_DTLS_ONLY")), '') as ff_dtls_only,
        nullif(trim(to_varchar("HEALTH_PRODUCT")), '') as health_product,
        nullif(trim(to_varchar("NO_OF_MEMBERS")), '') as no_of_members,
        nullif(trim(to_varchar("PARENT_FLAG")), '') as parent_flag,
        nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
        nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
        nullif(trim(to_varchar("SCHEME_DESC")), '') as scheme_desc,
        nullif(trim(to_varchar("SERTAX_FLAG")), '') as sertax_flag
    from {{ source('health_raw', 'BJAZ_CTNGY_SCHEME_MST') }}

)

select * from source
