{{ config(materialized='view') }}

-- KYC STAGE: BJAZ_T_CKYC_PERSONAL_DTLS + resolved part_id
-- (CKYC_NO -> BJAZ_T_CKYC_SEARCH.CKYC_NUMBER -> SEARCH_ID -> BJAZ_T_KYC_DETAILS).
-- HUB_PARTY_EMIT is false when no part_id resolves; such rows get a NULL PARTY_HKEY in
-- the sat stage and are dropped by sat_multi_source (WHERE src_pk IS NOT NULL).

with src as (select * from {{ ref('stg_partner__bjaz_t_ckyc_personal_dtls') }})
, res as (select * from {{ ref('res_kyc__part_by_ckyc_no') }})

select
    src.*,
    res.part_id,
    res.part_id_n,
    (res.part_id is not null) as hub_party_emit
from src
left join res on upper(trim(src.ckyc_no)) = res.ckyc_no
