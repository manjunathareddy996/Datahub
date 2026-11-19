-- Staging for source table BJAZ_WB_CLM_IP_MOT_EXT. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("IP_NO")), '') as ip_no,
        nullif(trim(to_varchar("TP_POLICY_REF")), '') as tp_policy_ref,
        nullif(trim(to_varchar("TP_INS_COMP_NAME")), '') as tp_ins_comp_name,
        nullif(trim(to_varchar("TP_INS_COMP_CONTACT")), '') as tp_ins_comp_contact,
        nullif(trim(to_varchar("TP_INS_COMP_BRANCH")), '') as tp_ins_comp_branch,
        nullif(trim(to_varchar("DRIVING_LICENCE_NO")), '') as driving_licence_no,
        nullif(trim(to_varchar("DRIVING_LICENCE_EXP_DATE")), '') as driving_licence_exp_date,
        nullif(trim(to_varchar("LOC_CODE")), '') as loc_code,
        nullif(trim(to_varchar("COMMENTS")), '') as comments,
        nullif(trim(to_varchar("RELATION_WITH_INS")), '') as relation_with_ins,
        nullif(trim(to_varchar("CLAIMANT_PART_ID")), '') as claimant_part_id,
        nullif(trim(to_varchar("TP_LAWYERS_NAME")), '') as tp_lawyers_name,
        nullif(trim(to_varchar("TP_LAWYERS_PH")), '') as tp_lawyers_ph,
        nullif(trim(to_varchar("OWN_REPAIRER")), '') as own_repairer,
        nullif(trim(to_varchar("SURVEYOR_STAGE")), '') as surveyor_stage,
        nullif(trim(to_varchar("CLM_TYPE")), '') as clm_type,
        nullif(trim(to_varchar("CLAIMANT_STATUS")), '') as claimant_status,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_WB_CLM_IP_MOT_EXT') }}

)

select * from source
