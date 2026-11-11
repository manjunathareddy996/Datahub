-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("CCP_1")), '') as ccp_1,
        nullif(trim(to_varchar("CCP_2")), '') as ccp_2,
        nullif(trim(to_varchar("CHLP_1")), '') as chlp_1,
        nullif(trim(to_varchar("CHLP_2")), '') as chlp_2,
        nullif(trim(to_varchar("CRITICARE")), '') as criticare,
        nullif(trim(to_varchar("CRITICARE_1")), '') as criticare_1,
        nullif(trim(to_varchar("GLOBALSET")), '') as globalset,
        nullif(trim(to_varchar("HERIZON_CARE_PLAN_1")), '') as herizon_care_plan_1,
        nullif(trim(to_varchar("HERIZON_CARE_PLAN_2")), '') as herizon_care_plan_2,
        nullif(trim(to_varchar("HERIZON_CARE_PLAN_3")), '') as herizon_care_plan_3,
        nullif(trim(to_varchar("INFINITY_1")), '') as infinity_1,
        nullif(trim(to_varchar("INFINITY_2")), '') as infinity_2,
        nullif(trim(to_varchar("NIDAAN_SWASTHYA_1")), '') as nidaan_swasthya_1,
        nullif(trim(to_varchar("PORT_SET")), '') as port_set,
        nullif(trim(to_varchar("SET1")), '') as set1,
        nullif(trim(to_varchar("VHC")), '') as vhc,
        nullif(trim(to_varchar("WOMEN_SPECIFIC_CRITICAL_ILLNESS_1")), '') as women_specific_critical_illness_1,
        nullif(trim(to_varchar("WOMEN_SPECIFIC_CRITICAL_ILLNESS_2")), '') as women_specific_critical_illness_2
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_PPC_PACKAGE_PIVOT_VW') }}

)

select * from source
