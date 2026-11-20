{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_POLICY_ORG_UNIT (Policy Org Unit). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 5 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (co_org_unit) as ORG_UNIT_BK, (trv_data_no) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (co_org_unit) is not null and (trv_data_no) is not null
union all
    select (location_code) as ORG_UNIT_BK, (trv_data_no) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (location_code) is not null and (trv_data_no) is not null
union all
    select (location) as ORG_UNIT_BK, (policy_ref) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_data') }}
    where (location) is not null and (policy_ref) is not null
union all
    select (coorgunit) as ORG_UNIT_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (coorgunit) is not null and (policynumber) is not null
union all
    select (locationcode) as ORG_UNIT_BK, (policynumber) as POLICY_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BJAZ_TRV_LOADER_LOG_TABLE' as RECORD_SRC
    from {{ ref('stg_travel__bjaz_trv_loader_log_table') }}
    where (locationcode) is not null and (policynumber) is not null
