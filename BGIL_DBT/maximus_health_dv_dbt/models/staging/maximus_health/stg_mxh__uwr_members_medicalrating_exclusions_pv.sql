-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("APPLICABILITY_RB")), '') as applicability_rb,
        nullif(trim(to_varchar("ARTHRITIS_RB")), '') as arthritis_rb,
        nullif(trim(to_varchar("ASTHMA_RB")), '') as asthma_rb,
        nullif(trim(to_varchar("CARDIOVASCULAR_RB")), '') as cardiovascular_rb,
        nullif(trim(to_varchar("COL_REQUIRED_RB")), '') as col_required_rb,
        nullif(trim(to_varchar("DIABETES_RB")), '') as diabetes_rb,
        nullif(trim(to_varchar("ECG_DEVIATION_RB")), '') as ecg_deviation_rb,
        nullif(trim(to_varchar("HYPERLIPIDAEMIA_RB")), '') as hyperlipidaemia_rb,
        nullif(trim(to_varchar("HYPERTENSION_RB")), '') as hypertension_rb,
        nullif(trim(to_varchar("OBESITY_RB")), '') as obesity_rb,
        nullif(trim(to_varchar("ONLY_2D_ECO_RB")), '') as only_2d_eco_rb,
        nullif(trim(to_varchar("OTHERS_RB")), '') as others_rb,
        nullif(trim(to_varchar("OTHER_DETAILS_1")), '') as other_details_1,
        nullif(trim(to_varchar("THYROID_RB")), '') as thyroid_rb
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEDICALRATING_EXCLUSIONS_PIVOT_VW') }}

)

select * from source
