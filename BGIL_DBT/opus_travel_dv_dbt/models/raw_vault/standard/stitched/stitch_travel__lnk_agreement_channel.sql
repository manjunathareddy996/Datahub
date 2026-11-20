{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_AGREEMENT_CHANNEL (Agreement Channel). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 8 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (cft_mst_contract_id) as AGREEMENT_BK, (intermediary_code) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (cft_mst_contract_id) is not null and (intermediary_code) is not null
union all
    select (cft_mst_contract_id) as AGREEMENT_BK, (partner_id) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (cft_mst_contract_id) is not null and (partner_id) is not null
union all
    select (cft_mst_contract_id) as AGREEMENT_BK, (subagent_code) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (cft_mst_contract_id) is not null and (subagent_code) is not null
union all
    select (contract_id) as AGREEMENT_BK, (marketing_agent) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_DETLS_EXTN' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_detls_extn') }}
    where (contract_id) is not null and (marketing_agent) is not null
union all
    select (contractid) as AGREEMENT_BK, (dealercode) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (contractid) is not null and (dealercode) is not null
union all
    select (contractid) as AGREEMENT_BK, (intermediary) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (contractid) is not null and (intermediary) is not null
union all
    select (contractid) as AGREEMENT_BK, (partnerid) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (contractid) is not null and (partnerid) is not null
union all
    select (contractid) as AGREEMENT_BK, (subagentcode) as DISTRIBUTION_CHANNEL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (contractid) is not null and (subagentcode) is not null
