{{ config(materialized='view') }}

-- KYC STAGE: BJAZ_T_CKYC_SEARCH + resolved part_id (SEARCH_ID -> BJAZ_T_KYC_DETAILS).
-- HUB_PARTY_EMIT is false when no part_id resolves; such rows get a NULL PARTY_HKEY in
-- the sat stage and are dropped by sat_multi_source (WHERE src_pk IS NOT NULL).

with src as (select * from {{ ref('stg_partner__bjaz_t_ckyc_search') }})
, res as (select * from {{ ref('res_kyc__part_by_search_id') }})

select
    src.*,
    res.part_id,
    res.part_id_n,
    (res.part_id is not null) as hub_party_emit
from src
left join res on src.search_id = res.search_id
