-- Staging for source table BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TXT_INSURER")), '') as txt_insurer,
        nullif(trim(to_varchar("REF_NO")), '') as ref_no,
        nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
        nullif(trim(to_varchar("TYPE_OF_POLICY")), '') as type_of_policy,
        nullif(trim(to_varchar("CLASS_OF_VEHICLE")), '') as class_of_vehicle,
        nullif(trim(to_varchar("POLICY_START_DATE")), '') as policy_start_date,
        nullif(trim(to_varchar("POLICY_END_DATE")), '') as policy_end_date,
        nullif(trim(to_varchar("TYPE_OF_TRANSACTION")), '') as type_of_transaction,
        nullif(trim(to_varchar("FINANACIAL_YEAR")), '') as finanacial_year,
        nullif(trim(to_varchar("REGNO")), '') as regno,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("TP_POLICY_FLAG")), '') as tp_policy_flag,
        nullif(trim(to_varchar("LATEST_POLICY")), '') as latest_policy,
        nullif(trim(to_varchar("NCB_PER")), '') as ncb_per,
        nullif(trim(to_varchar("NIL_DEP_FLAG")), '') as nil_dep_flag,
        nullif(trim(to_varchar("IDV")), '') as idv,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("TP_POLICY_START_DATE")), '') as tp_policy_start_date,
        nullif(trim(to_varchar("TP_POLICY_END_DATE")), '') as tp_policy_end_date,
        nullif(trim(to_varchar("OD_POLICY_START_DATE")), '') as od_policy_start_date,
        nullif(trim(to_varchar("OD_POLICY_END_DATE")), '') as od_policy_end_date,
        nullif(trim(to_varchar("MAXIMUSREFNO")), '') as maximusrefno,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("UNIQ_UUI")), '') as uniq_uui,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM') }}

)

select * from source
