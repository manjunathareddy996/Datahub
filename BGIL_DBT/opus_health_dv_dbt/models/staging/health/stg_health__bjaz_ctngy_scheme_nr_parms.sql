-- Staging for source table BJAZ_CTNGY_SCHEME_NR_PARMS (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("DISPLAY_CVR_VALIDATE")), '') as display_cvr_validate,
        nullif(trim(to_varchar("ISALPHA")), '') as isalpha,
        nullif(trim(to_varchar("IS_NRSEARCH")), '') as is_nrsearch,
        nullif(trim(to_varchar("IS_POST_UPDATEYN")), '') as is_post_updateyn,
        nullif(trim(to_varchar("MAXLENGTH")), '') as maxlength,
        nullif(trim(to_varchar("MEM_PARAM_REF")), '') as mem_param_ref,
        nullif(trim(to_varchar("MINLENGTH")), '') as minlength,
        nullif(trim(to_varchar("NIL_ENDORSE_YN")), '') as nil_endorse_yn,
        nullif(trim(to_varchar("NIL_END_PARAM_REF")), '') as nil_end_param_ref,
        nullif(trim(to_varchar("PARAM_DATA_TYPE")), '') as param_data_type,
        nullif(trim(to_varchar("PARAM_ID")), '') as param_id,
        nullif(trim(to_varchar("PARAM_LIST_VAL")), '') as param_list_val,
        nullif(trim(to_varchar("PARAM_REF")), '') as param_ref,
        nullif(trim(to_varchar("PARAM_REF_LABEL")), '') as param_ref_label,
        nullif(trim(to_varchar("PLAN_IDS")), '') as plan_ids,
        nullif(trim(to_varchar("POST_UPDATE")), '') as post_update,
        nullif(trim(to_varchar("PRINT_SINGLE_MEMBER")), '') as print_single_member,
        nullif(trim(to_varchar("PRINT_YN")), '') as print_yn,
        nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
        nullif(trim(to_varchar("SCHEME_VERSION")), '') as scheme_version,
        nullif(trim(to_varchar("SECTION_ID")), '') as section_id,
        nullif(trim(to_varchar("TRANSSCRIPT_PARAM_REF")), '') as transscript_param_ref,
        nullif(trim(to_varchar("VALIDATE_STOP_VALUE")), '') as validate_stop_value,
        nullif(trim(to_varchar("VALIDATE_STOP_Y_N")), '') as validate_stop_y_n
    from {{ source('health_raw', 'BJAZ_CTNGY_SCHEME_NR_PARMS') }}

)

select * from source
