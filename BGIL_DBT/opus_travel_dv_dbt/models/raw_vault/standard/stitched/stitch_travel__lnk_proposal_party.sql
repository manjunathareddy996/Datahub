{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch for LNK_PROPOSAL_PARTY (Proposal Party). One SELECT per (source table x hub-key branch
-- combination); every leg's business key is the SAME expression as that branch's hub staging
-- model (stg2_hub_<table>__<branch>.sql, PARENT_BK), so link legs always resolve to a hub row.
-- Both/all legs of a link row come from one source row. 1 branch select(s).
-- Rows where a leg is null (or, for traveller / benefit branches, where the traveller's name /
-- the benefit limit is absent) are not emitted.
    select (payer_part_id) as PARTY_BK, (travel_req_no) as PROPOSAL_BK, INC_JOB_UPDATED_AT, '!OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS' as RECORD_SRC
    from {{ ref('stg_travel__ba_trv_data_policy_dtls') }}
    where (payer_part_id) is not null and (travel_req_no) is not null
