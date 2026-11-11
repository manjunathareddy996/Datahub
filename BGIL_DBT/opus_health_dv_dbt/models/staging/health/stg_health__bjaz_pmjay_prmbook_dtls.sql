-- Staging for source table BJAZ_PMJAY_PRMBOOK_DTLS (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("BUSINESS_FLG")), '') as business_flg,
        nullif(trim(to_varchar("ENDTPASS_ON")), '') as endtpass_on,
        nullif(trim(to_varchar("ENDT_EFF_DATE")), '') as endt_eff_date,
        nullif(trim(to_varchar("ENDT_NO")), '') as endt_no,
        nullif(trim(to_varchar("ENDT_TYPE")), '') as endt_type,
        nullif(trim(to_varchar("FAMILY_COVERED")), '') as family_covered,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("PER_FAMILY_PRM")), '') as per_family_prm,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("TOT_FAMILY_PRM")), '') as tot_family_prm
    from {{ source('health_raw', 'BJAZ_PMJAY_PRMBOOK_DTLS') }}

)

select * from source
