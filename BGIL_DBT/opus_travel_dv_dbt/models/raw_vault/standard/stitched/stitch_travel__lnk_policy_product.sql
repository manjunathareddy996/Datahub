{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_POLICY_PRODUCT (Policy Product). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 6 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (trv_data_no) as POLICY_BK, (product_code) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (trv_data_no) is not null and (product_code) is not null
union all
    select (trv_data_no) as POLICY_BK, (travel_plan_no) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (trv_data_no) is not null and (travel_plan_no) is not null
union all
    select (policy_ref) as POLICY_BK, (plan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (policy_ref) is not null and (plan) is not null
union all
    select (policynumber) as POLICY_BK, (planid) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (policynumber) is not null and (planid) is not null
union all
    select (policynumber) as POLICY_BK, (product) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (policynumber) is not null and (product) is not null
union all
    select (policynumber) as POLICY_BK, (travelplan) as PRODUCT_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (policynumber) is not null and (travelplan) is not null
