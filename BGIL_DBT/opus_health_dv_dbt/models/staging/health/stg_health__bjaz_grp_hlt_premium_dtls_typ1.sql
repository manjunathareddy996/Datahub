-- Staging for source table BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1 (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ABOVE_80")), '') as above_80,
        nullif(trim(to_varchar("AGE_0_25")), '') as age_0_25,
        nullif(trim(to_varchar("AGE_26_35")), '') as age_26_35,
        nullif(trim(to_varchar("AGE_36_45")), '') as age_36_45,
        nullif(trim(to_varchar("AGE_46_55")), '') as age_46_55,
        nullif(trim(to_varchar("AGE_56_65")), '') as age_56_65,
        nullif(trim(to_varchar("AGE_66_70")), '') as age_66_70,
        nullif(trim(to_varchar("AGE_71_75")), '') as age_71_75,
        nullif(trim(to_varchar("AGE_76_80")), '') as age_76_80,
        nullif(trim(to_varchar("PPP_TYPE")), '') as ppp_type,
        nullif(trim(to_varchar("PREMIUM_TYPE")), '') as premium_type,
        nullif(trim(to_varchar("QUOTE_NO")), '') as quote_no,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("SI_AGE_BAND")), '') as si_age_band,
        nullif(trim(to_varchar("SOURCE_NAME")), '') as source_name
    from {{ source('health_raw', 'BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1') }}

)

select * from source
