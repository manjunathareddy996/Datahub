{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_PARTY_ROLE (Party Plays Role). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 3 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (payer_part_id) as PARTY_BK, 'premium-payer' as ROLE_TYPE_CODE, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (payer_part_id) is not null
union all
    select (premiumpayerid) as PARTY_BK, 'premium-payer' as ROLE_TYPE_CODE, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (premiumpayerid) is not null
union all
    select (premiumpayerid) as PARTY_BK, 'premium-payer' as ROLE_TYPE_CODE, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (premiumpayerid) is not null
