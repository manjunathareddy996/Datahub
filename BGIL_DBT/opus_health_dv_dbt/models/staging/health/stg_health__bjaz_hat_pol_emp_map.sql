-- Staging for source table BJAZ_HAT_POL_EMP_MAP (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACCESS_CODE")), '') as access_code,
        nullif(trim(to_varchar("DISCLAIMER_INDICATOR")), '') as disclaimer_indicator,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("EMP_CODE")), '') as emp_code,
        nullif(trim(to_varchar("MAIL_INDICATOR")), '') as mail_indicator,
        nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
        nullif(trim(to_varchar("STATUS")), '') as status
    from {{ source('health_raw', 'BJAZ_HAT_POL_EMP_MAP') }}

)

select * from source
