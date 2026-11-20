{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_AGREEMENT_PARTY (Agreement Party). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 4 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (cft_mst_contract_id) as AGREEMENT_BK, (cft_mst_comp_ref) as PARTY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (cft_mst_contract_id) is not null and (cft_mst_comp_ref) is not null
union all
    select (cft_mst_contract_id) as AGREEMENT_BK, (payer_part_id) as PARTY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (cft_mst_contract_id) is not null and (payer_part_id) is not null
union all
    select (cft_mst_contract_id) as AGREEMENT_BK, (cft_mst_comp_ref) as PARTY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_PLAN_MST' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_plan_mst') }}
    where (cft_mst_contract_id) is not null and (cft_mst_comp_ref) is not null
union all
    select (contractid) as AGREEMENT_BK, (premiumpayerid) as PARTY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (contractid) is not null and (premiumpayerid) is not null
