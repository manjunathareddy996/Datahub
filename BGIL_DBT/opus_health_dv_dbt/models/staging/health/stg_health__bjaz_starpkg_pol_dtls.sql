-- Staging for source table BJAZ_STARPKG_POL_DTLS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("BUSS_TYPE")), '') as buss_type,
        nullif(trim(to_varchar("CB_AMT")), '') as cb_amt,
        nullif(trim(to_varchar("CB_PER")), '') as cb_per,
        nullif(trim(to_varchar("CI_LOAD")), '') as ci_load,
        nullif(trim(to_varchar("COMM_DISC")), '') as comm_disc,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("CO_PYMT")), '') as co_pymt,
        nullif(trim(to_varchar("DMS_COMMIT_TIMESTAMP")), '') as dms_commit_timestamp,
        nullif(trim(to_varchar("DMS_H_CHANGE_SEQ")), '') as dms_h_change_seq,
        nullif(trim(to_varchar("DMS_H_STREAM_POSITION")), '') as dms_h_stream_position,
        nullif(trim(to_varchar("DMS_H_USER")), '') as dms_h_user,
        nullif(trim(to_varchar("DMS_TIMESTAMP")), '') as dms_timestamp,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_CREATED_BY")), '') as inc_job_created_by,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("INC_JOB_UPDATED_AT")), '') as inc_job_updated_at,
        nullif(trim(to_varchar("INC_JOB_UPDATED_BY")), '') as inc_job_updated_by,
        nullif(trim(to_varchar("MONTHLY_INCOME")), '') as monthly_income,
        nullif(trim(to_varchar("NO_OF_DEPENDENTS")), '') as no_of_dependents,
        nullif(trim(to_varchar("OP")), '') as op,
        nullif(trim(to_varchar("OTHER_CONDITION")), '') as other_condition,
        nullif(trim(to_varchar("POL_EFF_END_DATE")), '') as pol_eff_end_date,
        nullif(trim(to_varchar("POL_EFF_START_DATE")), '') as pol_eff_start_date,
        nullif(trim(to_varchar("POL_EFF_TIME")), '') as pol_eff_time,
        nullif(trim(to_varchar("POL_EFF_YEARS")), '') as pol_eff_years,
        nullif(trim(to_varchar("PROD_CODE")), '') as prod_code,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("TOTAL_PREM")), '') as total_prem,
        nullif(trim(to_varchar("TOTAL_SI")), '') as total_si,
        nullif(trim(to_varchar("TRANSACTION_ID")), '') as transaction_id,
        nullif(trim(to_varchar("UW_FLAG")), '') as uw_flag,
        nullif(trim(to_varchar("UW_LOAD")), '') as uw_load,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("VOLEX_AMT")), '') as volex_amt,
        nullif(trim(to_varchar("VOLEX_PER")), '') as volex_per
    from {{ source('health_raw', 'BJAZ_STARPKG_POL_DTLS') }}

)

select * from source
