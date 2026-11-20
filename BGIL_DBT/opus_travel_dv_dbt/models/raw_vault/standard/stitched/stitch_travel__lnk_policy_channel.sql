{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_POLICY_CHANNEL (Policy Channel). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 12 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (intermediary_code) as DISTRIBUTION_CHANNEL_BK, (trv_data_no) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (intermediary_code) is not null and (trv_data_no) is not null
union all
    select (partner_id) as DISTRIBUTION_CHANNEL_BK, (trv_data_no) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (partner_id) is not null and (trv_data_no) is not null
union all
    select (subagent_code) as DISTRIBUTION_CHANNEL_BK, (trv_data_no) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (subagent_code) is not null and (trv_data_no) is not null
union all
    select (bagicecode) as DISTRIBUTION_CHANNEL_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (bagicecode) is not null and (policy_ref) is not null
union all
    select (bankecode) as DISTRIBUTION_CHANNEL_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (bankecode) is not null and (policy_ref) is not null
union all
    select (bankrmcode) as DISTRIBUTION_CHANNEL_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (bankrmcode) is not null and (policy_ref) is not null
union all
    select (intermediary) as DISTRIBUTION_CHANNEL_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (intermediary) is not null and (policy_ref) is not null
union all
    select (subimd) as DISTRIBUTION_CHANNEL_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (subimd) is not null and (policy_ref) is not null
union all
    select (dealercode) as DISTRIBUTION_CHANNEL_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (dealercode) is not null and (policynumber) is not null
union all
    select (intermediary) as DISTRIBUTION_CHANNEL_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (intermediary) is not null and (policynumber) is not null
union all
    select (partnerid) as DISTRIBUTION_CHANNEL_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (partnerid) is not null and (policynumber) is not null
union all
    select (subagentcode) as DISTRIBUTION_CHANNEL_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (subagentcode) is not null and (policynumber) is not null
