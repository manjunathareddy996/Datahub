{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_QUOTE_PRODUCT (Quote Product). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 2 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (product_code) as PRODUCT_BK, (quote_no) as QUOTE_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (product_code) is not null and (quote_no) is not null
union all
    select (travel_plan_no) as PRODUCT_BK, (quote_no) as QUOTE_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (travel_plan_no) is not null and (quote_no) is not null
